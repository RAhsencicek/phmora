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