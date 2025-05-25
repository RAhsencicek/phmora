import Foundation
import Combine
import CoreLocation

/// PharmacyService: Eczane API isteklerini yöneten servis katmanı
/// Bu servis Pharmora platformu için eczane ile ilgili API çağrılarını yönetir
@MainActor
class PharmacyService: ObservableObject {
    static let shared = PharmacyService()
    
    @Published var pharmacies: [Pharmacy] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - API Methods
    
    /// Tüm eczaneleri getir
    func fetchAllPharmacies() {
        isLoading = true
        errorMessage = nil
        
        let request: AnyPublisher<APIResponse<[Pharmacy]>, APIError> = NetworkManager.shared.performRequest(
            endpoint: "/pharmacies/all",
            method: .GET,
            body: nil,
            requiresAuth: false
        )
        
        request.sink(
            receiveCompletion: { [weak self] (completion: Subscribers.Completion<APIError>) in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("❌ Pharmacy fetch error: \(error)")
                }
            },
            receiveValue: { [weak self] (response: APIResponse<[Pharmacy]>) in
                if let pharmacies = response.data {
                    self?.pharmacies = pharmacies
                    print("✅ Fetched \(pharmacies.count) pharmacies")
                } else {
                    self?.errorMessage = response.message ?? "Eczaneler yüklenemedi"
                    print("⚠️ API Error: \(response.message ?? "Unknown error")")
                }
            }
        )
        .store(in: &cancellables)
    }
    
    /// Konuma göre yakın eczaneleri getir
    func fetchNearbyPharmacies(latitude: Double, longitude: Double, radius: Double = 5000) {
        isLoading = true
        errorMessage = nil
        
        let endpoint = "/pharmacies/nearby?latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)"
        
        let request: AnyPublisher<APIResponse<[Pharmacy]>, APIError> = NetworkManager.shared.performRequest(
            endpoint: endpoint,
            method: .GET,
            body: nil,
            requiresAuth: false
        )
        
        request.sink(
            receiveCompletion: { [weak self] (completion: Subscribers.Completion<APIError>) in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("❌ Nearby pharmacies fetch error: \(error)")
                }
            },
            receiveValue: { [weak self] (response: APIResponse<[Pharmacy]>) in
                if let pharmacies = response.data {
                    self?.pharmacies = pharmacies
                    print("✅ Fetched \(pharmacies.count) nearby pharmacies")
                } else {
                    self?.errorMessage = response.message ?? "Yakın eczaneler bulunamadı"
                    print("⚠️ API Error: \(response.message ?? "Unknown error")")
                }
            }
        )
        .store(in: &cancellables)
    }
    
    /// Şehir ve ilçeye göre eczaneleri getir
    func fetchPharmacies(city: String? = nil, district: String? = nil) {
        isLoading = true
        errorMessage = nil
        
        var endpoint = "/pharmacies/list"
        var queryParams: [String] = []
        
        if let city = city, !city.isEmpty {
            queryParams.append("city=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city)")
        }
        if let district = district, !district.isEmpty {
            queryParams.append("district=\(district.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? district)")
        }
        
        if !queryParams.isEmpty {
            endpoint += "?" + queryParams.joined(separator: "&")
        }
        
        let request: AnyPublisher<APIResponse<[Pharmacy]>, APIError> = NetworkManager.shared.performRequest(
            endpoint: endpoint,
            method: .GET,
            body: nil,
            requiresAuth: false
        )
        
        request.sink(
            receiveCompletion: { [weak self] (completion: Subscribers.Completion<APIError>) in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("❌ Filtered pharmacies fetch error: \(error)")
                }
            },
            receiveValue: { [weak self] (response: APIResponse<[Pharmacy]>) in
                if let pharmacies = response.data {
                    self?.pharmacies = pharmacies
                    print("✅ Fetched \(pharmacies.count) filtered pharmacies")
                } else {
                    self?.errorMessage = response.message ?? "Eczaneler bulunamadı"
                    print("⚠️ API Error: \(response.message ?? "Unknown error")")
                }
            }
        )
        .store(in: &cancellables)
    }
    
    /// Şehir listesini getir
    func fetchCities() -> AnyPublisher<[String], APIError> {
        let request: AnyPublisher<APIResponse<[String]>, APIError> = NetworkManager.shared.performRequest(
            endpoint: "/pharmacies/cities",
            method: .GET,
            body: nil,
            requiresAuth: false
        )
        
        return request
            .compactMap { response in
                response.data
            }
            .eraseToAnyPublisher()
    }
    
    /// Belirli bir eczanenin detaylarını getir
    func fetchPharmacyDetails(id: String) -> AnyPublisher<Pharmacy, APIError> {
        let request: AnyPublisher<APIResponse<Pharmacy>, APIError> = NetworkManager.shared.performRequest(
            endpoint: "/pharmacies/\(id)",
            method: .GET,
            body: nil,
            requiresAuth: false
        )
        
        return request
            .compactMap { response in
                response.data
            }
            .eraseToAnyPublisher()
    }
    
    /// Verileri yenile
    func refreshData() {
        fetchAllPharmacies()
    }
    
    /// Hata mesajını temizle
    func clearError() {
        errorMessage = nil
    }
} 