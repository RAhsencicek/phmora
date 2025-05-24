import Foundation
import Combine

// MARK: - Models
struct DrugSearchResponse: Codable {
    let success: Bool
    let total: Int
    let drugs: [Drug]
}

struct Drug: Identifiable, Codable {
    let id: String
    let brandName: String
    let genericName: String
    let manufacturerName: String
    let activeIngredients: [String]?
    let dosageForm: String?
    let route: String?
    let description: String?
}

struct DrugDetailResponse: Codable {
    let success: Bool
    let drug: DrugDetail
}

struct DrugDetail: Identifiable, Codable {
    let id: String
    let brandName: String
    let genericName: String
    let manufacturerName: String
    let activeIngredients: [String]?
    let dosageForm: String?
    let route: String?
    let description: String?
    let indications: [String]?
    let warnings: [String]?
    let contraindications: [String]?
    let adverseReactions: [String]?
    let drugInteractions: [String]?
    let dosageAdministration: [String]?
}

struct AdverseEventResponse: Codable {
    let success: Bool
    let total: Int
    let events: [AdverseEvent]
}

struct AdverseEvent: Identifiable, Codable {
    let reportId: String
    let receiveDate: String
    let seriousness: String
    let patientAge: String?
    let patientSex: String?
    let reactions: [Reaction]
    let drugs: [EventDrug]
    
    var id: String { reportId }
}

struct Reaction: Codable {
    let reactionName: String
    let outcome: String?
}

struct EventDrug: Codable {
    let name: String
    let indication: String?
    let dosage: String?
}

struct DrugRecallResponse: Codable {
    let success: Bool
    let total: Int
    let recalls: [DrugRecall]
}

struct DrugRecall: Identifiable, Codable {
    let recallId: String
    let recallInitiationDate: String
    let product: String
    let reason: String
    let status: String
    let classification: String
    let company: String
    let country: String
    let distributionPattern: String
    
    var id: String { recallId }
}

// MARK: - Service Protocol
protocol OpenFDAServiceProtocol {
    func searchDrugs(query: String, limit: Int) async throws -> DrugSearchResponse
    func getDrugDetails(drugId: String) async throws -> DrugDetailResponse
    func getAdverseEvents(drug: String, limit: Int) async throws -> AdverseEventResponse
    func getDrugRecalls(drug: String?, limit: Int) async throws -> DrugRecallResponse
}

// MARK: - Service Implementation
class OpenFDAService: ObservableObject, OpenFDAServiceProtocol {
    private let baseURL = "https://phamorabackend-production.up.railway.app"
    private var authToken: String?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(authToken: String? = nil) {
        self.authToken = authToken
    }
    
    func searchDrugs(query: String, limit: Int = 10) async throws -> DrugSearchResponse {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        defer { 
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        guard var urlComponents = URLComponents(string: "\(baseURL)/api/fda/drugs") else {
            throw URLError(.badURL)
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: encodedQuery),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        print("API Request URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("API Response Status: \(httpResponse.statusCode)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("API Response Data: \(responseString)")
        }
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            return try decoder.decode(DrugSearchResponse.self, from: data)
        case 400:
            if let errorString = String(data: data, encoding: .utf8) {
                throw NSError(domain: "OpenFDAService", code: 400, userInfo: [NSLocalizedDescriptionKey: errorString])
            }
            throw NSError(domain: "OpenFDAService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Bad Request"])
        case 401:
            throw NSError(domain: "OpenFDAService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized access"])
        case 404:
            throw NSError(domain: "OpenFDAService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Resource not found"])
        case 429:
            throw NSError(domain: "OpenFDAService", code: 429, userInfo: [NSLocalizedDescriptionKey: "API rate limit exceeded"])
        default:
            throw NSError(domain: "OpenFDAService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        }
    }
    
    func getDrugDetails(drugId: String) async throws -> DrugDetailResponse {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        defer { 
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        guard let url = URL(string: "\(baseURL)/api/fda/drugs/\(drugId)") else {
            throw URLError(.badURL)
        }
        
        print("API Request URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("API Response Status: \(httpResponse.statusCode)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("API Response Data: \(responseString)")
        }
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            return try decoder.decode(DrugDetailResponse.self, from: data)
        case 400, 401, 404, 429:
            if let errorString = String(data: data, encoding: .utf8) {
                throw NSError(domain: "OpenFDAService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorString])
            }
            throw NSError(domain: "OpenFDAService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Error \(httpResponse.statusCode)"])
        default:
            throw NSError(domain: "OpenFDAService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        }
    }
    
    func getAdverseEvents(drug: String, limit: Int = 10) async throws -> AdverseEventResponse {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        defer { 
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        guard var urlComponents = URLComponents(string: "\(baseURL)/api/fda/adverse-events") else {
            throw URLError(.badURL)
        }
        
        let encodedDrug = drug.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? drug
        
        urlComponents.queryItems = [
            URLQueryItem(name: "drug", value: encodedDrug),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        print("API Request URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("API Response Status: \(httpResponse.statusCode)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("API Response Data: \(responseString)")
        }
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            return try decoder.decode(AdverseEventResponse.self, from: data)
        case 400, 401, 404, 429:
            if let errorString = String(data: data, encoding: .utf8) {
                throw NSError(domain: "OpenFDAService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorString])
            }
            throw NSError(domain: "OpenFDAService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Error \(httpResponse.statusCode)"])
        default:
            throw NSError(domain: "OpenFDAService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        }
    }
    
    func getDrugRecalls(drug: String? = nil, limit: Int = 10) async throws -> DrugRecallResponse {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        defer { 
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        guard var urlComponents = URLComponents(string: "\(baseURL)/api/fda/drug-recalls") else {
            throw URLError(.badURL)
        }
        
        var queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        if let drug = drug {
            let encodedDrug = drug.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? drug
            queryItems.append(URLQueryItem(name: "drug", value: encodedDrug))
        }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        print("API Request URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("API Response Status: \(httpResponse.statusCode)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("API Response Data: \(responseString)")
        }
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            return try decoder.decode(DrugRecallResponse.self, from: data)
        case 400, 401, 404, 429:
            if let errorString = String(data: data, encoding: .utf8) {
                throw NSError(domain: "OpenFDAService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorString])
            }
            throw NSError(domain: "OpenFDAService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Error \(httpResponse.statusCode)"])
        default:
            throw NSError(domain: "OpenFDAService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        }
    }
}

// MARK: - Mock Implementation for Testing and Previews
class MockOpenFDAService: ObservableObject, OpenFDAServiceProtocol {
    @Published var isLoading = false
    @Published var errorMessage: String?
    var shouldFail = false
    
    func searchDrugs(query: String, limit: Int = 10) async throws -> DrugSearchResponse {
        if shouldFail {
            throw NSError(domain: "MockOpenFDAService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        
        return FDAMockData.mockDrugSearchResponse()
    }
    
    func getDrugDetails(drugId: String) async throws -> DrugDetailResponse {
        if shouldFail {
            throw NSError(domain: "MockOpenFDAService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        
        return FDAMockData.mockDrugDetailResponse()
    }
    
    func getAdverseEvents(drug: String, limit: Int = 10) async throws -> AdverseEventResponse {
        if shouldFail {
            throw NSError(domain: "MockOpenFDAService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        
        return FDAMockData.mockAdverseEventResponse()
    }
    
    func getDrugRecalls(drug: String? = nil, limit: Int = 10) async throws -> DrugRecallResponse {
        if shouldFail {
            throw NSError(domain: "MockOpenFDAService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        
        return FDAMockData.mockDrugRecallResponse()
    }
} 