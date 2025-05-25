import SwiftUI
import MapKit

// MARK: - Animated Background View
/// Hareketli arka plan bileşeni
struct AnimatedBackgroundView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Ana gradient arka plan
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 0.98),
                    Color.blue.opacity(0.05)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Hareketli daireler
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.1),
                                Color.green.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat.random(in: 50...120))
                    .position(
                        x: animate ? CGFloat.random(in: 50...350) : CGFloat.random(in: 50...350),
                        y: animate ? CGFloat.random(in: 100...600) : CGFloat.random(in: 100...600)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.5),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Logo Overlay View
/// Harita üzerinde gösterilecek logo bileşeni
struct LogoOverlayView: View {
    var body: some View {
        VStack {
            ZStack {
                // Logo arka planı
                
                
            }
            
            
        }
        .padding(.top, 20)
    }
}

// MARK: - Home View
/// Modern dashboard view that displays pharmacies on a map with beautiful UI
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
    @State private var showLocationAlert = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Hareketli arka plan
            AnimatedBackgroundView()
                .ignoresSafeArea()
            
            if pharmacyViewModel.isLoading {
                // Modern Loading State
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.blue, Color.green],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: pharmacyViewModel.isLoading)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Eczaneler Yükleniyor")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Yakınınızdaki eczaneler aranıyor...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.opacity(0.9))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10)
                .padding()
                
            } else if let errorMessage = pharmacyViewModel.errorMessage {
                // Modern Error State
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.red)
                    }
                    
                    VStack(spacing: 12) {
                        Text("Bir Sorun Oluştu")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(errorMessage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        Task {
                            await pharmacyViewModel.refreshData()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Tekrar Dene")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(width: 160, height: 48)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.opacity(0.9))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10)
                .padding()
                
            } else {
                // Map Content with Logo Overlay
                ZStack {
                    PharmaciesMapView(
                        pharmacies: pharmacyViewModel.filteredPharmacies,
                        selectedPharmacy: $selectedPharmacy,
                        showPharmacyDetails: $showPharmacyDetails,
                        showAddMedicationSheet: $showAddMedicationSheet,
                        region: $mapRegion
                    )
                    .cornerRadius(40)
                    .shadow(color: .black.opacity(0.5), radius: 8)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Logo overlay
                    VStack {
                        LogoOverlayView()
                        Spacer()
                    }
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
        .alert("Konum Bilgisi", isPresented: $showLocationAlert) {
            Button("Tamam") { }
        } message: {
            Text("Daha doğru sonuçlar için konum izni vermenizi öneririz.")
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupView()
        }
        .onChange(of: locationManager.location) { _, newLocation in
            if !initialLocationSet, let location = newLocation {
                withAnimation(.easeInOut(duration: 1.0)) {
                    updateMapRegion(with: location)
                }
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
