import Foundation
import Combine

class AuthService: ObservableObject {
    static let shared = AuthService()
    private let baseURL = "https://phamorabackend-production.up.railway.app/api"
    
    @Published var currentUser: UserResponse?
    @Published var currentPharmacy: Pharmacy?
    @Published var isLoggedIn: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // Computed property for pharmacistId
    var currentUserPharmacistId: String? {
        return currentUser?.pharmacistId
    }
    
    var currentUserId: String? {
        return currentUser?.id
    }
    
    var currentPharmacyId: String? {
        return currentPharmacy?.id
    }
    
    private init() {}
    
    func login(pharmacistId: String, password: String) -> AnyPublisher<LoginResponse, Error> {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        let loginRequest = LoginRequest(pharmacistId: pharmacistId, password: password)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(loginRequest)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: LoginResponse.self, decoder: JSONDecoder())
            .handleEvents(receiveOutput: { [weak self] response in
                DispatchQueue.main.async {
                    self?.currentUser = response.user
                    self?.isLoggedIn = true
                    
                    // UserDefaults'a kullanıcı bilgilerini kaydet
                    UserDefaults.standard.set(response.user.pharmacistId, forKey: "pharmacistId")
                    UserDefaults.standard.set(response.user.id, forKey: "userId")
                    
                    // Kullanıcının eczane bilgilerini al
                    self?.fetchUserPharmacy()
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func fetchUserPharmacy() {
        guard let pharmacistId = currentUser?.pharmacistId else { return }
        
        // Tüm eczaneleri al ve kullanıcının eczanesini bul
        guard let url = URL(string: "\(baseURL)/pharmacies/all") else { return }
        
        var request = URLRequest(url: url)
        request.setValue(pharmacistId, forHTTPHeaderField: "pharmacistid")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [Pharmacy].self, decoder: createJSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ Pharmacy fetch error: \(error)")
                    }
                },
                receiveValue: { [weak self] (pharmacies: [Pharmacy]) in
                    // Kullanıcının eczanesini bul
                    if let userPharmacy = pharmacies.first(where: { $0.owner?.pharmacistId == pharmacistId }) {
                        self?.currentPharmacy = userPharmacy
                        UserDefaults.standard.set(userPharmacy.id, forKey: "pharmacyId")
                        print("✅ User pharmacy found: \(userPharmacy.name) (ID: \(userPharmacy.id))")
                    } else {
                        print("⚠️ No pharmacy found for user: \(pharmacistId)")
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func logout() {
        DispatchQueue.main.async { [weak self] in
            // Kullanıcı bilgilerini temizle
            self?.currentUser = nil
            self?.currentPharmacy = nil
            self?.isLoggedIn = false
            
            // UserDefaults'tan tüm kullanıcı verilerini temizle
            UserDefaults.standard.clearUserData()
            UserDefaults.standard.synchronize()
            
            // Diğer servisleri de temizle
            PharmacyService.shared.clearData()
        }
    }
    
    func checkLoginStatus() {
        if let savedPharmacistId = UserDefaults.standard.string(forKey: "pharmacistId") {
            // Burada normalde token doğrulaması yapılabilir
            // Şimdilik basit bir kontrol yapıyoruz
            DispatchQueue.main.async { [weak self] in
                self?.isLoggedIn = true
            }
        }
    }
    
    private func createJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }
} 
