import Foundation
import Combine
import CoreLocation

// Nöbetçi eczane servis modelleri
struct DutyPharmacyResponse: Codable {
    let status: String
    let message: String
    let messageTR: String
    let systemTime: Int
    let endpoint: String
    let rowCount: Int
    let creditUsed: Int
    let data: [DutyPharmacy]
}

struct DutyPharmacy: Codable, Identifiable {
    let pharmacyID: Int
    let pharmacyName: String
    let address: String
    let city: String
    let district: String
    let town: String?
    let directions: String?
    let phone: String
    let phone2: String?
    let pharmacyDutyStart: String
    let pharmacyDutyEnd: String
    let latitude: Double
    let longitude: Double
    var distanceMt: Double?
    var distanceKm: Double?
    var distanceMil: Double?
    
    var id: Int { pharmacyID }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var formattedPhone: String {
        return phone.isEmpty ? "Telefon bilgisi yok" : phone
    }
    
    var formattedAddress: String {
        return "\(address), \(district)/\(city)"
    }
    
    var formattedDirections: String {
        return directions ?? "Yön tarifi bulunmuyor"
    }
    
    var dutyStartDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: pharmacyDutyStart)
    }
    
    var dutyEndDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: pharmacyDutyEnd)
    }
    
    var isDuty: Bool {
        guard let start = dutyStartDate, let end = dutyEndDate else { return false }
        let now = Date()
        return now >= start && now <= end
    }
}

class PharmacyService {
    static let shared = PharmacyService()
    private let baseURL = "https://phamorabackend-production.up.railway.app/api/pharmacy"
    
    private init() {}
    
    // Geleneksel Combine publisher ile API çağrısı
    func findNearbyPharmacies(latitude: Double, longitude: Double) -> AnyPublisher<[DutyPharmacy], Error> {
        guard let url = URL(string: "\(baseURL)/nearby") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude))
        ]
        
        guard let finalURL = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                if httpResponse.statusCode != 200 {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: DutyPharmacyResponse.self, decoder: JSONDecoder())
            .map { $0.data }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Async/await ile API çağrısı (iOS 18.4 ve Swift 6.0 için)
    func findNearbyPharmaciesAsync(latitude: Double, longitude: Double) async throws -> [DutyPharmacy] {
        guard let url = URL(string: "\(baseURL)/nearby") else {
            throw URLError(.badURL)
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude))
        ]
        
        guard let finalURL = components.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            if httpResponse.statusCode != 200 {
                throw URLError(.badServerResponse)
            }
            
            let decodedResponse = try JSONDecoder().decode(DutyPharmacyResponse.self, from: data)
            return decodedResponse.data
        } catch {
            print("Nöbetçi eczane verisi alınamadı: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Geleneksel Combine publisher ile API çağrısı
    func getPharmaciesByCity(city: String, district: String? = nil) -> AnyPublisher<[DutyPharmacy], Error> {
        guard let url = URL(string: "\(baseURL)/list") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems = [URLQueryItem(name: "city", value: city)]
        
        if let district = district, !district.isEmpty {
            queryItems.append(URLQueryItem(name: "district", value: district))
        }
        
        components.queryItems = queryItems
        
        guard let finalURL = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                if httpResponse.statusCode != 200 {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: DutyPharmacyResponse.self, decoder: JSONDecoder())
            .map { $0.data }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Async/await ile API çağrısı (iOS 18.4 ve Swift 6.0 için)
    func getPharmaciesByCityAsync(city: String, district: String? = nil) async throws -> [DutyPharmacy] {
        guard let url = URL(string: "\(baseURL)/list") else {
            throw URLError(.badURL)
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems = [URLQueryItem(name: "city", value: city)]
        
        if let district = district, !district.isEmpty {
            queryItems.append(URLQueryItem(name: "district", value: district))
        }
        
        components.queryItems = queryItems
        
        guard let finalURL = components.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            if httpResponse.statusCode != 200 {
                throw URLError(.badServerResponse)
            }
            
            let decodedResponse = try JSONDecoder().decode(DutyPharmacyResponse.self, from: data)
            return decodedResponse.data
        } catch {
            print("Şehir bazlı eczane verisi alınamadı: \(error.localizedDescription)")
            throw error
        }
    }
} 