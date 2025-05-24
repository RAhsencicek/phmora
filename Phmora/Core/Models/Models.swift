import SwiftUI
import MapKit
import Foundation

struct Pharmacy: Identifiable, Equatable {
    var id = UUID()
    let name: String
    let address: String
    let phone: String
    let coordinate: CLLocationCoordinate2D
    var availableMedications: [Medication]
    
    static func == (lhs: Pharmacy, rhs: Pharmacy) -> Bool {
        return lhs.id == rhs.id
    }
}

// Medication Models
enum MedicationStatus: String, Codable, CaseIterable {
    case available = "Mevcut"
    case forSale = "Satılık"
    case reserved = "Rezerve"
    case sold = "Satıldı"
}

struct Medication: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let price: Double
    let quantity: Int
    let expiryDate: Date?
    let imageURL: URL?
    let status: MedicationStatus
}

// Auth Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let message: String
    let token: String
    let user: UserResponse
}

struct UserResponse: Codable {
    let id: String
    let pharmacistId: String
    let name: String
    let email: String
    let role: String
}

struct APIError: LocalizedError, Codable {
    let message: String?
    let errors: [ValidationError]?
    
    var errorDescription: String? {
        if let validationErrors = errors {
            return validationErrors.map { $0.msg }.joined(separator: "\n")
        }
        return message ?? "Bilinmeyen bir hata oluştu"
    }
}

struct ValidationError: Codable {
    let type: String
    let msg: String
    let path: String
    let location: String
}

// MARK: - API Response Models
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let message: String?
    let data: T?
    let pagination: PaginationInfo?
}

struct PaginationInfo: Codable {
    let current: Int
    let total: Int
    let count: Int
    let totalItems: Int
    
    // Computed properties for compatibility
    var currentPage: Int { current }
    var totalPages: Int { total }
    var hasNext: Bool { current < total }
    var hasPrev: Bool { current > 1 }
}

// MARK: - Backend Medicine Models
struct Medicine: Identifiable, Codable {
    let _id: String
    let name: String
    let genericName: String?
    let manufacturer: String
    let dosageForm: String
    let strength: String?
    let packageSize: String?
    let description: String?
    let price: MedicinePrice?
    let barcode: String?
    let prescriptionRequired: Bool?
    let isActive: Bool?
    let createdAt: String
    let updatedAt: String
    
    // Identifiable protokolü için computed property
    var id: String { _id }
    
    enum CodingKeys: String, CodingKey {
        case _id
        case name, genericName, manufacturer, dosageForm
        case strength, packageSize, description, price, barcode
        case prescriptionRequired, isActive, createdAt, updatedAt
    }
}

struct MedicinePrice: Codable {
    let amount: Double
    let currency: String
    
    var formattedPrice: String {
        return String(format: "%.2f %@", amount, currency)
    }
}

enum DosageForm: String, Codable, CaseIterable {
    case tablet = "tablet"
    case capsule = "capsule"
    case syrup = "syrup"
    case injection = "injection"
    case cream = "cream"
    case drops = "drops"
    case spray = "spray"
    case powder = "powder"
    case solution = "solution"
    case ointment = "ointment"
    
    var displayName: String {
        switch self {
        case .tablet: return "Tablet"
        case .capsule: return "Kapsül"
        case .syrup: return "Şurup"
        case .injection: return "Enjeksiyon"
        case .cream: return "Krem"
        case .drops: return "Damla"
        case .spray: return "Sprey"
        case .powder: return "Toz"
        case .solution: return "Solüsyon"
        case .ointment: return "Merhem"
        }
    }
}

struct MedicineSearchParams {
    let query: String?
    let manufacturer: String?
    let dosageForm: DosageForm?
    let page: Int
    let limit: Int
    
    func toQueryParams() -> [String] {
        var params: [String] = []
        
        if let query = query, !query.isEmpty {
            params.append("search=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        }
        
        if let manufacturer = manufacturer, !manufacturer.isEmpty {
            params.append("manufacturer=\(manufacturer.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        }
        
        if let dosageForm = dosageForm {
            params.append("dosage_form=\(dosageForm.rawValue)")
        }
        
        params.append("page=\(page)")
        params.append("limit=\(limit)")
        
        return params
    }
}

// MARK: - Medicine Extensions
extension Medicine {
    /// Convert to local Medication model for compatibility
    func toMedication() -> Medication {
        return Medication(
            name: name,
            description: description ?? "\(manufacturer) - \(dosageForm.capitalized)",
            price: price?.amount ?? 0.0,
            quantity: 1,
            expiryDate: nil,
            imageURL: nil,
            status: .available
        )
    }
    
    /// Display name for dosage form
    var dosageFormDisplayName: String {
        switch dosageForm.lowercased() {
        case "tablet": return "Tablet"
        case "capsule": return "Kapsül"
        case "syrup": return "Şurup"
        case "injection": return "Enjeksiyon"
        case "cream": return "Krem"
        case "drops": return "Damla"
        case "spray": return "Sprey"
        case "powder": return "Toz"
        case "solution": return "Solüsyon"
        case "ointment": return "Merhem"
        default: return dosageForm.capitalized
        }
    }
}