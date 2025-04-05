import SwiftUI
import MapKit

struct Pharmacy: Identifiable {
    var id = UUID()
    let name: String
    let address: String
    let phone: String
    let coordinate: CLLocationCoordinate2D
    var availableMedications: [Medication]
}

struct Medication: Identifiable {
    var id = UUID()
    let name: String
    let description: String
    let price: Double
    let quantity: Int
    let expiryDate: Date?
    let imageURL: String?
    let status: MedicationStatus
}

enum MedicationStatus: String, CaseIterable {
    case available = "Mevcut"
    case forSale = "Satılık"
    case reserved = "Rezerve"
    case sold = "Satıldı"
} 