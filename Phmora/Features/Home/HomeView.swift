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
        center: CLLocationCoordinate2D(latitude: 39.0, longitude: 35.0), // Türkiye merkezi (Ankara yakını)
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0) // Geniş görünüm
    )
    @State private var selectedPharmacy: Pharmacy? = nil
    @State private var showPharmacyDetails = false
    @State private var currentUserPharmacyIndex = 0 // Kullanıcının kendi eczanesinin indeksi
    
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
            updateMapRegion(with: newLocation)
        }
    }
    
    // MARK: - Private Methods
    private func setupView() {
        locationManager.requestLocationPermission()
    }
    
    private func updateMapRegion(with location: CLLocation?) {
        if let location = location {
            mapRegion = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02) // Kullanıcı konumunda yakın görünüm
            )
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        HomeView(showAddMedicationSheet: .constant(false))
    }
} 
