import SwiftUI
import MapKit

// MARK: - Home View
/// Main dashboard view that displays pharmacies and duty pharmacies on a map
/// Features:
/// - Interactive map with pharmacy annotations
/// - Toggle between regular pharmacies and duty pharmacies
/// - Pharmacy detail sheets
/// - Location-based services
struct HomeView: View {
    // MARK: - Properties
    @Binding var showAddMedicationSheet: Bool
    
    // MARK: - State Management
    @StateObject private var locationManager = LocationManager()
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.6748, longitude: 39.2225), // Elazığ merkez koordinatları
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var selectedPharmacy: Pharmacy? = nil
    @State private var showPharmacyDetails = false
    @State private var currentUserPharmacyIndex = 0 // Kullanıcının kendi eczanesinin indeksi
    @State private var selectedView: MapViewType = .pharmacies
    
    // MARK: - Mock Data (TODO: Replace with API data)
    @State private var pharmacies: [Pharmacy] = SampleData.pharmacies
    
    // MARK: - Supporting Types
    /// Type of map view to display
    enum MapViewType {
        case pharmacies      // Regular pharmacy sales
        case dutyPharmacies  // Duty pharmacies
    }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                // View Toggle
                viewTogglePicker
                
                // Map Content
                if selectedView == .pharmacies {
                    PharmaciesMapView(
                        pharmacies: pharmacies,
                        selectedPharmacy: $selectedPharmacy,
                        showPharmacyDetails: $showPharmacyDetails,
                        showAddMedicationSheet: $showAddMedicationSheet,
                        region: $mapRegion
                    )
                } else {
                    DutyPharmacyView()
                }
            }
        }
        .sheet(isPresented: $showPharmacyDetails, onDismiss: {
            selectedPharmacy = nil
        }) {
            if let pharmacy = selectedPharmacy {
                PharmacyDetailView(pharmacy: pharmacy)
                    .presentationDetents([.height(200), .medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .navigationTitle(selectedView == .pharmacies ? "Eczaneler" : "Nöbetçi Eczaneler")
        .onAppear {
            setupView()
        }
        .onChange(of: locationManager.location) { _, newLocation in
            updateMapRegion(with: newLocation)
        }
    }
    
    // MARK: - View Components
    private var viewTogglePicker: some View {
        Picker("Görünüm", selection: $selectedView) {
            Text("İlaç Satışları").tag(MapViewType.pharmacies)
            Text("Nöbetçi Eczaneler").tag(MapViewType.dutyPharmacies)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Private Methods
    private func setupView() {
        locationManager.requestLocationPermission()
    }
    
    private func updateMapRegion(with location: CLLocation?) {
        if let location = location {
            mapRegion = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
}

// MARK: - Sample Data
/// Sample pharmacy data for development
private struct SampleData {
    static let pharmacies: [Pharmacy] = [
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
        )
    ]
}

// MARK: - Preview
#Preview {
    NavigationView {
        HomeView(showAddMedicationSheet: .constant(false))
    }
} 
