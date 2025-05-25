import SwiftUI
import MapKit

// MARK: - Home View
/// Main dashboard view that displays pharmacies on a map
/// Features:
/// - Interactive map with pharmacy annotations
/// - Pharmacy detail sheets
/// - Location-based services
/// - Real-time data from backend API
struct HomeView: View {
    // MARK: - Properties
    @Binding var showAddMedicationSheet: Bool
    
    // MARK: - State Management
    @StateObject private var locationManager = LocationManager()
    @StateObject private var pharmacyViewModel = PharmacyViewModel()
    @State private var mapRegion = MKCoordinateRegion(
        center: AppConstants.Map.defaultCenter,
        span: AppConstants.Map.defaultSpan
    )
    @State private var selectedPharmacy: Pharmacy? = nil
    @State private var showPharmacyDetails = false
    @State private var initialLocationSet = false
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            if pharmacyViewModel.isLoading {
                VStack {
                    ProgressView("Eczaneler yükleniyor...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else if let errorMessage = pharmacyViewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                    Button("Tekrar Dene") {
                        Task {
                            await pharmacyViewModel.refreshData()
                        }
                    }
                    .primaryButtonStyle()
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack {
                    // Map Content
                    PharmaciesMapView(
                        pharmacies: pharmacyViewModel.filteredPharmacies,
                        selectedPharmacy: $selectedPharmacy,
                        showPharmacyDetails: $showPharmacyDetails,
                        showAddMedicationSheet: $showAddMedicationSheet,
                        region: $mapRegion
                    )
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
        .navigationTitle("Eczaneler")
        .onAppear {
            setupView()
        }
        .onChange(of: locationManager.location) { _, newLocation in
            // Sadece ilk konum alındığında haritayı güncelle
            if !initialLocationSet, let location = newLocation {
                updateMapRegion(with: location)
                Task {
                    await pharmacyViewModel.loadNearbyPharmacies(location: location)
                }
                initialLocationSet = true
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupView() {
        locationManager.requestLocationPermission()
        
        // Eğer konum izni yoksa veya konum alınamıyorsa tüm eczaneleri yükle
        if locationManager.authorizationStatus == .denied || locationManager.location == nil {
            Task {
                await pharmacyViewModel.loadPharmacies()
            }
        }
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
