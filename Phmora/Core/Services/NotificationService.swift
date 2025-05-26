import Foundation
import Combine

@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var notifications: [NotificationModel] = []
    @Published var unreadCount: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkManager = NetworkManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Fetch Notifications
    
    func fetchNotifications(
        page: Int = 1,
        limit: Int = 20,
        isRead: Bool? = nil,
        type: NotificationTypeModel? = nil
    ) {
        isLoading = true
        errorMessage = nil
        
        var queryParams: [String] = [
            "page=\(page)",
            "limit=\(limit)"
        ]
        
        if let isRead = isRead {
            queryParams.append("isRead=\(isRead)")
        }
        
        if let type = type {
            queryParams.append("type=\(type.rawValue)")
        }
        
        let queryString = queryParams.joined(separator: "&")
        
        // Direct API call instead of using NetworkManager
        Task {
            do {
                guard let url = URL(string: "https://phamorabackend-production.up.railway.app/api/notifications?\(queryString)") else {
                    throw APIError(message: "Geçersiz URL", errors: nil)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                
                if let pharmacistId = UserDefaults.standard.string(forKey: "pharmacistId") {
                    request.setValue(pharmacistId, forHTTPHeaderField: "pharmacistid")
                }
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                // Response'u debug et
                if let responseString = String(data: data, encoding: .utf8) {
                    print("🌐 Notification API Response: \(responseString)")
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 400 {
                        if let errorResponse = try? JSONDecoder().decode(APIError.self, from: data) {
                            throw errorResponse
                        } else {
                            throw APIError(message: "HTTP Error: \(httpResponse.statusCode)", errors: nil)
                        }
                    }
                }
                
                // Backend'den gelen format: { success: true, data: [...], pagination: {...} }
                struct NotificationResponse: Codable {
                    let success: Bool
                    let data: [NotificationModel]
                    let pagination: NotificationPagination?
                }
                
                struct NotificationPagination: Codable {
                    let current: Int
                    let total: Int
                    let count: Int
                    let totalItems: Int
                    let unreadCount: Int
                }
                
                let decoder = JSONDecoder()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .formatted(formatter)
                
                let notificationResponse = try decoder.decode(NotificationResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    if notificationResponse.success {
                        self.notifications = notificationResponse.data
                        self.unreadCount = notificationResponse.pagination?.unreadCount ?? notificationResponse.data.filter { !$0.isRead }.count
                    } else {
                        self.errorMessage = "Bildirimler yüklenemedi"
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    print("❌ Notification fetch error: \(error)")
                }
            }
        }
    }
    
    // MARK: - Fetch Unread Notifications
    
    func fetchUnreadNotifications() {
        fetchNotifications(limit: 50, isRead: false)
    }
    
    // MARK: - Mark as Read
    
    func markAsRead(_ notificationId: String) {
        let publisher: AnyPublisher<APIResponse<String>, APIError> = networkManager.performRequest(
            endpoint: "/notifications/\(notificationId)/read",
            method: .PATCH,
            body: nil,
            requiresAuth: true
        )
        
        publisher
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    print("❌ Mark as read error: \(error)")
                }
            },
            receiveValue: { response in
                if response.success {
                    // Update local state
                    if let index = self.notifications.firstIndex(where: { $0.id == notificationId }) {
                        let updatedNotification = self.notifications[index]
                        self.notifications[index] = NotificationModel(
                            id: updatedNotification.id,
                            title: updatedNotification.title,
                            message: updatedNotification.message,
                            type: updatedNotification.type,
                            isRead: true,
                            date: updatedNotification.date,
                            data: updatedNotification.data
                        )
                        
                        if !updatedNotification.isRead {
                            self.unreadCount = max(0, self.unreadCount - 1)
                        }
                    }
                }
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - Mark All as Read
    
    func markAllAsRead() {
        let publisher: AnyPublisher<APIResponse<String>, APIError> = networkManager.performRequest(
            endpoint: "/notifications/read-all",
            method: .PATCH,
            body: nil,
            requiresAuth: true
        )
        
        publisher
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    print("❌ Mark all as read error: \(error)")
                }
            },
            receiveValue: { response in
                if response.success {
                    // Update local state
                    for i in self.notifications.indices {
                        let notification = self.notifications[i]
                        self.notifications[i] = NotificationModel(
                            id: notification.id,
                            title: notification.title,
                            message: notification.message,
                            type: notification.type,
                            isRead: true,
                            date: notification.date,
                            data: notification.data
                        )
                    }
                    self.unreadCount = 0
                }
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - Delete Notification
    
    func deleteNotification(_ notificationId: String) {
        let publisher: AnyPublisher<APIResponse<String>, APIError> = networkManager.performRequest(
            endpoint: "/notifications/\(notificationId)",
            method: .DELETE,
            body: nil,
            requiresAuth: true
        )
        
        publisher
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    print("❌ Delete notification error: \(error)")
                }
            },
            receiveValue: { response in
                if response.success {
                    // Update local state
                    if let index = self.notifications.firstIndex(where: { $0.id == notificationId }) {
                        let notification = self.notifications[index]
                        self.notifications.remove(at: index)
                        
                        if !notification.isRead {
                            self.unreadCount = max(0, self.unreadCount - 1)
                        }
                    }
                }
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - Delete Multiple Notifications
    
    func deleteNotifications(_ notificationIds: [String]) {
        let requestBody = ["notificationIds": notificationIds]
        
        let publisher: AnyPublisher<APIResponse<String>, APIError> = networkManager.performRequest(
            endpoint: "/notifications",
            method: .DELETE,
            body: requestBody,
            requiresAuth: true
        )
        
        publisher
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    print("❌ Delete multiple notifications error: \(error)")
                }
            },
            receiveValue: { response in
                if response.success {
                    // Update local state
                    let deletedNotifications = self.notifications.filter { notificationIds.contains($0.id) }
                    let unreadDeletedCount = deletedNotifications.filter { !$0.isRead }.count
                    
                    self.notifications.removeAll { notificationIds.contains($0.id) }
                    self.unreadCount = max(0, self.unreadCount - unreadDeletedCount)
                }
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - Fetch Notification Stats
    
    func fetchNotificationStats(completion: @escaping (NotificationStats?) -> Void) {
        let publisher: AnyPublisher<APIResponse<NotificationStatsResponse>, APIError> = networkManager.performRequest(
            endpoint: "/notifications/stats",
            method: .GET,
            body: nil,
            requiresAuth: true
        )
        
        publisher
        .sink(
            receiveCompletion: { completionResult in
                if case .failure(let error) = completionResult {
                    self.errorMessage = error.localizedDescription
                    print("❌ Notification stats error: \(error)")
                    completion(nil)
                }
            },
            receiveValue: { response in
                if response.success, let statsResponse = response.data {
                    completion(statsResponse.data)
                } else {
                    completion(nil)
                }
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    
    func clearError() {
        errorMessage = nil
    }
    
    func refreshNotifications() {
        fetchNotifications()
    }
    
    // MARK: - Real-time Updates (Future Enhancement)
    
    func startListeningForUpdates() {
        // WebSocket veya Server-Sent Events ile gerçek zamanlı güncellemeler
        // Şimdilik polling ile simüle edebiliriz
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchUnreadNotifications()
            }
            .store(in: &cancellables)
    }
    
    func stopListeningForUpdates() {
        cancellables.removeAll()
    }
} 