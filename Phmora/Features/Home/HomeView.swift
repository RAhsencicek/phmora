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
    @State private var pharmacies: [Pharmacy] = PharmacyMockData.pharmacies
    
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

// MARK: - Preview
#Preview {
    NavigationView {
        HomeView(showAddMedicationSheet: .constant(false))
    }
} 
