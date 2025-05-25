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
        fetchPharmacies()
    }
    
    /// Konuma göre yakın eczaneleri getir
    func fetchNearbyPharmacies(latitude: Double, longitude: Double, radius: Double = 10.0) {
        // Yakındaki eczaneleri getir
        fetchPharmacies()
    }
    
    /// Şehir ve ilçeye göre eczaneleri getir
    func fetchPharmacies(city: String? = nil, district: String? = nil) {
        guard let url = URL(string: "https://phamorabackend-production.up.railway.app/api/pharmacies/all") else {
            DispatchQueue.main.async {
                self.errorMessage = "Geçersiz URL"
            }
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Pharmacy].self, decoder: createJSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Eczaneler yüklenirken hata oluştu: \(error.localizedDescription)"
                        print("Pharmacy fetch error: \(error)")
                    }
                },
                receiveValue: { [weak self] pharmacies in
                    self?.pharmacies = pharmacies
                    print("Fetched \(pharmacies.count) pharmacies")
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
        fetchPharmacies()
    }
    
    /// Hata mesajını temizle
    func clearError() {
        errorMessage = nil
    }
    
    func clearData() {
        DispatchQueue.main.async { [weak self] in
            self?.pharmacies = []
            self?.isLoading = false
            self?.errorMessage = nil
            self?.cancellables.removeAll()
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