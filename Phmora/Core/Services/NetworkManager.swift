import Foundation
import Combine

// MARK: - Network Manager
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    private let baseURL = "https://phamorabackend-production.up.railway.app/api"
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // Generic request method for APIResponse format
    func performRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: [String: Any]? = nil,
        requiresAuth: Bool = false
    ) -> AnyPublisher<APIResponse<T>, APIError> {
        
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            return Fail(error: APIError(message: "Geçersiz URL", errors: nil))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Auth header ekle (gerekirse)
        if requiresAuth {
            if let pharmacistId = UserDefaults.standard.string(forKey: "pharmacistId") {
                request.setValue(pharmacistId, forHTTPHeaderField: "pharmacistId")
            }
        }
        
        // Body ekle
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                return Fail(error: APIError(message: "JSON serileştirme hatası", errors: nil))
                    .eraseToAnyPublisher()
            }
        }
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError(message: "Geçersiz sunucu yanıtı", errors: nil)
                }
                
                // Debug için response'u yazdır
                if let responseString = String(data: data, encoding: .utf8) {
                    print("🌐 API Response: \(responseString)")
                }
                
                // Hata durumları
                if httpResponse.statusCode >= 400 {
                    let decoder = JSONDecoder()
                    if let apiError = try? decoder.decode(APIError.self, from: data) {
                        throw apiError
                    } else {
                        throw APIError(message: "HTTP \(httpResponse.statusCode) hatası", errors: nil)
                    }
                }
                
                return data
            }
            .tryMap { data in
                let decoder = JSONDecoder()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .formatted(formatter)
                
                // Backend'den gelen format: { success: true, data: [...], pagination: {...} }
                if let apiResponse = try? decoder.decode(APIResponse<T>.self, from: data) {
                    return apiResponse
                }
                
                // Eğer APIResponse formatında değilse, direkt data'yı decode et
                if let directData = try? decoder.decode(T.self, from: data) {
                    return APIResponse<T>(success: true, message: nil, data: directData, pagination: nil)
                }
                
                // JSON string'i debug için yazdır
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 Failed to decode JSON: \(jsonString)")
                }
                
                // Hiçbiri çalışmazsa hata fırlat
                throw APIError(message: "Veri formatı tanınmıyor", errors: nil)
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                } else {
                    return APIError(message: error.localizedDescription, errors: nil)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
} 