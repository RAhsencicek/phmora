import Foundation
import Combine

// MARK: - Medicine Service
class MedicineService: ObservableObject {
    private let networkManager = NetworkManager.shared
    
    @Published var medicines: [Medicine] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    
    /// Tüm ilaçları getir
    func getAllMedicines(
        page: Int = 1,
        limit: Int = 20,
        search: String? = nil
    ) -> AnyPublisher<APIResponse<[Medicine]>, APIError> {
        
        let searchParams = MedicineSearchParams(
            query: search,
            manufacturer: nil,
            dosageForm: nil,
            page: page,
            limit: limit
        )
        
        let queryString = searchParams.toQueryParams().isEmpty ? "" : "?" + searchParams.toQueryParams().joined(separator: "&")
        
        return networkManager.performRequest(
            endpoint: "/medicines\(queryString)",
            requiresAuth: false
        )
    }
    
    /// Barkod ile ilaç getir
    func getMedicineByBarcode(_ barcode: String) -> AnyPublisher<APIResponse<Medicine>, APIError> {
        return networkManager.performRequest(
            endpoint: "/medicines/barcode/\(barcode)",
            requiresAuth: false
        )
    }
    
    /// İlaç ara (üretici bazında)
    func searchMedicines(
        query: String,
        manufacturer: String? = nil,
        dosageForm: DosageForm? = nil,
        page: Int = 1,
        limit: Int = 20
    ) -> AnyPublisher<APIResponse<[Medicine]>, APIError> {
        
        let searchParams = MedicineSearchParams(
            query: query,
            manufacturer: manufacturer,
            dosageForm: dosageForm,
            page: page,
            limit: limit
        )
        
        let queryString = "?" + searchParams.toQueryParams().joined(separator: "&")
        
        return networkManager.performRequest(
            endpoint: "/medicines\(queryString)",
            requiresAuth: false
        )
    }
    
    // MARK: - Convenience Methods
    
    /// Async/await wrapper for getAllMedicines
    func loadMedicines(page: Int = 1, limit: Int = 20, search: String? = nil) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let response = try await getAllMedicines(page: page, limit: limit, search: search)
                .async()
            
            await MainActor.run {
                if response.success {
                    self.medicines = response.data ?? []
                    self.errorMessage = nil
                } else {
                    self.errorMessage = response.message ?? "Bilinmeyen hata"
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    /// Test fonksiyonu - Backend bağlantısını test et
    func testConnection() -> AnyPublisher<APIResponse<[Medicine]>, APIError> {
        return getAllMedicines(limit: 3) // Sadece 3 ilaç getir
    }
}

// MARK: - Publisher Extension for async/await
extension AnyPublisher {
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = first()
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                        cancellable?.cancel()
                    }
                )
        }
    }
} 