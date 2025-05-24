import Foundation
import Combine
import CoreLocation

/// PharmacyService: Eczane API isteklerini yöneten servis katmanı
/// Bu servis Pharmora platformu için eczane ile ilgili API çağrılarını yönetir
class PharmacyService {
    static let shared = PharmacyService()
    private let baseURL = "https://phamorabackend-production.up.railway.app/api/pharmacy"
    
    private init() {}
    
    // MARK: - Future API Methods
    // TODO: Implement medication trading API methods
    // TODO: Implement pharmacy profile API methods
    // TODO: Implement offer management API methods
    
    /*
    Example future methods:
    
    func getPharmacyMedications(pharmacyId: String) async throws -> [Medication] {
        // Implementation for getting pharmacy medications
    }
    
    func sendOfferToPharmacy(offer: MedicationOffer) async throws -> OfferResponse {
        // Implementation for sending medication offers
    }
    
    func getPharmacyProfile(pharmacyId: String) async throws -> PharmacyProfile {
        // Implementation for getting pharmacy details
    }
    */
} 