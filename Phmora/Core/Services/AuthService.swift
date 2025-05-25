import Foundation
import Combine

class AuthService: ObservableObject {
    static let shared = AuthService()
    private let baseURL = "https://phamorabackend-production.up.railway.app/api"
    
    @Published var currentUser: UserResponse?
    @Published var isLoggedIn: Bool = false
    
    // Computed property for pharmacistId
    var currentUserPharmacistId: String? {
        return currentUser?.pharmacistId
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
                    // UserDefaults'a kaydet
                    UserDefaults.standard.set(response.user.pharmacistId, forKey: "pharmacistId")
                }
            })
            .eraseToAnyPublisher()
    }
    
    func logout() {
        DispatchQueue.main.async { [weak self] in
            // Kullanıcı bilgilerini temizle
            self?.currentUser = nil
            self?.isLoggedIn = false
            
            // UserDefaults'tan tüm kullanıcı verilerini temizle
            UserDefaults.standard.removeObject(forKey: "pharmacistId")
            UserDefaults.standard.removeObject(forKey: "userToken")
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
} 
