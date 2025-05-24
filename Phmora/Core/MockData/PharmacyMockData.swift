import Foundation
import MapKit

// Import our custom models
// Note: In Xcode projects, we can import types from the same module directly
// This ensures Pharmacy and Medication types are available

/// Mock data for pharmacies used in development and testing
/// This structure matches the backend API response format for easy migration
struct PharmacyMockData {
    
    /// Sample pharmacies worldwide for testing
    /// TODO: Replace with real API data from backend
    static let pharmacies: [Pharmacy] = [
        // GLOBAL TEST PHARMACIES FOR DEBUG
        Pharmacy(
            name: "San Francisco Pharmacy",
            address: "Market St, San Francisco, CA",
            phone: "+1 415 123 4567",
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            availableMedications: [
                Medication(name: "Test Medicine SF", description: "Test için", price: 25.90, quantity: 10, expiryDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()), imageURL: nil, status: .forSale)
            ]
        ),
        Pharmacy(
            name: "New York Pharmacy",
            address: "Times Square, New York, NY",
            phone: "+1 212 123 4567", 
            coordinate: CLLocationCoordinate2D(latitude: 40.7589, longitude: -73.9851),
            availableMedications: [
                Medication(name: "Test Medicine NY", description: "Test için", price: 32.50, quantity: 15, expiryDate: Calendar.current.date(byAdding: .month, value: 8, to: Date()), imageURL: nil, status: .forSale)
            ]
        ),
        Pharmacy(
            name: "London Pharmacy",
            address: "Oxford Street, London, UK",
            phone: "+44 20 1234 5678",
            coordinate: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
            availableMedications: [
                Medication(name: "Test Medicine London", description: "Test için", price: 18.75, quantity: 20, expiryDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()), imageURL: nil, status: .forSale)
            ]
        ),
        
        // Original Elazığ pharmacies
        Pharmacy(
            name: "Merkez Eczanesi",
            address: "Çarşı Mah. Gazi Cad. No:84, Merkez/Elazığ",
            phone: "0424 218 1001",
            coordinate: CLLocationCoordinate2D(latitude: 38.6741, longitude: 39.2237),
            availableMedications: [
                Medication(name: "Parol", description: "Ağrı kesici", price: 25.90, quantity: 10, expiryDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()), imageURL: nil, status: .forSale),
                Medication(name: "Majezik", description: "Ağrı kesici", price: 32.50, quantity: 15, expiryDate: Calendar.current.date(byAdding: .month, value: 8, to: Date()), imageURL: nil, status: .forSale)
            ]
        ),
        Pharmacy(
            name: "Fırat Eczanesi",
            address: "İzzetpaşa Mah. Şehit Polis M.Fevzi Yalçın Cad. No:14/C, Merkez/Elazığ",
            phone: "0424 237 8787",
            coordinate: CLLocationCoordinate2D(latitude: 38.6728, longitude: 39.2198),
            availableMedications: [
                Medication(name: "Aspirin", description: "Ağrı kesici", price: 18.75, quantity: 20, expiryDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()), imageURL: nil, status: .forSale),
                Medication(name: "B12 Vitamini", description: "Vitamin takviyesi", price: 45.90, quantity: 8, expiryDate: Calendar.current.date(byAdding: .month, value: 12, to: Date()), imageURL: nil, status: .available)
            ]
        ),
        Pharmacy(
            name: "Yıldız Eczanesi",
            address: "Rızaiye Mah. Şehit Polis Ali Gaffar Okkan Cad. No:38/A, Merkez/Elazığ",
            phone: "0424 238 3434",
            coordinate: CLLocationCoordinate2D(latitude: 38.6756, longitude: 39.2256),
            availableMedications: [
                Medication(name: "Augmentin", description: "Antibiyotik", price: 65.30, quantity: 5, expiryDate: Calendar.current.date(byAdding: .month, value: 2, to: Date()), imageURL: nil, status: .forSale),
                Medication(name: "Zinc", description: "Mineral takviyesi", price: 38.25, quantity: 12, expiryDate: Calendar.current.date(byAdding: .month, value: 10, to: Date()), imageURL: nil, status: .available)
            ]
        ),
        Pharmacy(
            name: "Sağlık Eczanesi",
            address: "Cumhuriyet Mah. Malatya Cad. No:78/B, Merkez/Elazığ",
            phone: "0424 233 1212",
            coordinate: CLLocationCoordinate2D(latitude: 38.6734, longitude: 39.2211),
            availableMedications: []
        ),
        Pharmacy(
            name: "Şifa Eczanesi",
            address: "Olgunlar Mah. Gazi Cad. No:132/A, Merkez/Elazığ",
            phone: "0424 218 5656",
            coordinate: CLLocationCoordinate2D(latitude: 38.6747, longitude: 39.2242),
            availableMedications: []
        ),
        
        // Additional 15 pharmacies (keeping some of the originals)
        Pharmacy(
            name: "Doğan Eczanesi",
            address: "Mustafapaşa Mah. Hürriyet Cad. No:45, Merkez/Elazığ",
            phone: "0424 212 3456",
            coordinate: CLLocationCoordinate2D(latitude: 38.6780, longitude: 39.2290),
            availableMedications: [
                Medication(name: "Panadol", description: "Ateş düşürücü", price: 22.50, quantity: 25, expiryDate: Calendar.current.date(byAdding: .month, value: 4, to: Date()), imageURL: nil, status: .forSale),
                Medication(name: "Voltaren", description: "Kas ağrısı", price: 28.90, quantity: 12, expiryDate: Calendar.current.date(byAdding: .month, value: 7, to: Date()), imageURL: nil, status: .available)
            ]
        ),
        Pharmacy(
            name: "Güven Eczanesi",
            address: "Atatürk Bulvarı No:156/B, Merkez/Elazığ",
            phone: "0424 224 7890",
            coordinate: CLLocationCoordinate2D(latitude: 38.6695, longitude: 39.2180),
            availableMedications: [
                Medication(name: "Nexium", description: "Mide koruyucu", price: 78.40, quantity: 8, expiryDate: Calendar.current.date(byAdding: .month, value: 5, to: Date()), imageURL: nil, status: .forSale)
            ]
        ),
        Pharmacy(
            name: "Umut Eczanesi",
            address: "Kültür Mah. Eğitim Cad. No:67, Merkez/Elazığ",
            phone: "0424 235 4567",
            coordinate: CLLocationCoordinate2D(latitude: 38.6820, longitude: 39.2310),
            availableMedications: [
                Medication(name: "Calpol", description: "Çocuk ateş düşürücü", price: 19.75, quantity: 18, expiryDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()), imageURL: nil, status: .available),
                Medication(name: "Probiyotik", description: "Bağırsak sağlığı", price: 55.60, quantity: 7, expiryDate: Calendar.current.date(byAdding: .month, value: 8, to: Date()), imageURL: nil, status: .forSale)
            ]
        ),
        Pharmacy(
            name: "Modern Eczanesi",
            address: "Çaydaçıra Mah. Yeşil Cad. No:34, Merkez/Elazığ",
            phone: "0424 225 6789",
            coordinate: CLLocationCoordinate2D(latitude: 38.6785, longitude: 39.2275),
            availableMedications: [
                Medication(name: "Brufen", description: "Ağrı ve ateş kesici", price: 26.80, quantity: 22, expiryDate: Calendar.current.date(byAdding: .month, value: 5, to: Date()), imageURL: nil, status: .forSale),
                Medication(name: "Vitamin D3", description: "Kemik sağlığı", price: 35.50, quantity: 9, expiryDate: Calendar.current.date(byAdding: .month, value: 14, to: Date()), imageURL: nil, status: .available)
            ]
        ),
        Pharmacy(
            name: "Türkiye Eczanesi",
            address: "Ulukent Mah. Cumhuriyet Cad. No:112, Merkez/Elazığ",
            phone: "0424 242 9012",
            coordinate: CLLocationCoordinate2D(latitude: 38.6800, longitude: 39.2250),
            availableMedications: [
                Medication(name: "Losec", description: "Reflü ilacı", price: 89.50, quantity: 4, expiryDate: Calendar.current.date(byAdding: .month, value: 2, to: Date()), imageURL: nil, status: .forSale)
            ]
        )
    ]
    
    /// Get pharmacy by name for testing purposes
    static func pharmacy(named name: String) -> Pharmacy? {
        return pharmacies.first { $0.name == name }
    }
    
    /// Get pharmacies within a specific region
    static func pharmacies(in region: MKCoordinateRegion) -> [Pharmacy] {
        return pharmacies.filter { pharmacy in
            let latDiff = abs(pharmacy.coordinate.latitude - region.center.latitude)
            let lonDiff = abs(pharmacy.coordinate.longitude - region.center.longitude)
            return latDiff <= region.span.latitudeDelta/2 && lonDiff <= region.span.longitudeDelta/2
        }
    }
    
    /// Get pharmacies that have available medications
    static var pharmaciesWithMedications: [Pharmacy] {
        return pharmacies.filter { !$0.availableMedications.isEmpty }
    }
} 