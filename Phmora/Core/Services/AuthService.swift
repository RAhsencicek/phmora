import Foundation
import Combine

class AuthService {
    static let shared = AuthService()
    private let baseURL = "https://phamorabackend-production.up.railway.app/api"
    
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
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseString)")
                }
                
                if httpResponse.statusCode != 200 {
                    let decoder = JSONDecoder()
                    let apiError = try decoder.decode(APIError.self, from: data)
                    
                    switch httpResponse.statusCode {
                    case 400:
                        throw apiError
                    case 401:
                        throw apiError
                    case 403:
                        throw apiError
                    case 500:
                        throw apiError
                    default:
                        throw apiError
                    }
                }
                
                return data
            }
            .decode(type: LoginResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
} 
