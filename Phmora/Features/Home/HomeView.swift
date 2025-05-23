import SwiftUI
import MapKit

// MARK: - Home View
/// Main dashboard view that displays pharmacies on a map
/// Features:
/// - Interactive map with pharmacy annotations
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
    @State private var initialLocationSet = false
    
    // MARK: - Mock Data (TODO: Replace with API data)
    @State private var pharmacies: [Pharmacy] = PharmacyMockData.pharmacies
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                // Map Content
                    PharmaciesMapView(
                        pharmacies: pharmacies,
                        selectedPharmacy: $selectedPharmacy,
                        showPharmacyDetails: $showPharmacyDetails,
                        showAddMedicationSheet: $showAddMedicationSheet,
                        region: $mapRegion
                    )
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
        .navigationTitle("Eczaneler")
        .onAppear {
            setupView()
        }
        .onChange(of: locationManager.location) { _, newLocation in
            // Sadece ilk konum alındığında haritayı güncelle
            if !initialLocationSet, let location = newLocation {
                updateMapRegion(with: location)
                initialLocationSet = true
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupView() {
        locationManager.requestLocationPermission()
    }
    
    private func updateMapRegion(with location: CLLocation) {
        mapRegion = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        HomeView(showAddMedicationSheet: .constant(false))
    }
} 
