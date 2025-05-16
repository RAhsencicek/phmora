import SwiftUI
import MapKit
import Combine
import Observation

struct DutyPharmacyView: View {
    @StateObject private var viewModel = DutyPharmacyViewModel()
    @State private var selectedPharmacy: DutyPharmacy?
    @State private var showPharmacyDetails = false
    @State private var showingLocationPermissionAlert = false
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Harita görünümü - Karmaşık ifadeyi basitleştirdim
            mapView
            
            // Durum ve bilgi görünümü
            statusView
            
            // Konum izni isteme yönetimi
            locationPermissionView
            
            // Eczane listesi
            if !viewModel.dutyPharmacies.isEmpty {
                pharmacyListButton
            }
        }
        .sheet(isPresented: $showPharmacyDetails, onDismiss: {
            selectedPharmacy = nil
        }) {
            if let pharmacy = selectedPharmacy {
                DutyPharmacyDetailView(pharmacy: pharmacy)
                    .presentationDetents([.height(300), .medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            viewModel.checkLocationPermission()
        }
        .onChange(of: viewModel.location) { newLocation in
            if let newLocation = newLocation {
                // Konum değiştiğinde harita merkezini güncelle
                mapRegion = MKCoordinateRegion(
                    center: newLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }
        .alert("Konum İzni Gerekli", isPresented: $showingLocationPermissionAlert) {
            Button("İptal", role: .cancel) { }
            Button("Ayarlar'a Git") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Nöbetçi eczaneleri görebilmek için 'Ayarlar > Gizlilik ve Güvenlik > Konum Servisleri > Pharmora' yolunu izleyerek 'Uygulamayı kullanırken' seçeneğini seçin.")
        }
        .onChange(of: viewModel.showLocationPermissionAlert) { shouldShow in
            if shouldShow {
                // SwiftUI alert kullanımı için ayrı bir state değişkeni
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showingLocationPermissionAlert = true
                }
            }
        }
        .navigationTitle("Nöbetçi Eczaneler")
    }
    
    // MARK: - Alt görünümler
    
    // Harita görünümünü ayrı bir hesaplanmış özellik olarak tanımladım
    private var mapView: some View {
        Map(coordinateRegion: .constant(mapRegion), annotationItems: viewModel.dutyPharmacies) { pharmacy in
            MapMarker(coordinate: pharmacy.coordinate, tint: .red)
        }
        .mapStyle(.standard)
        .mapControls {
            MapCompass()
            MapUserLocationButton()
            MapScaleView()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Harita üzerindeki genel dokunma işlemine yanıt vermek için
            // kullanılabilir ama şu an için boş bırakalım
        }
    }
    
    // Durum bilgisi görünümü
    private var statusView: some View {
        VStack {
            // Durum bilgisi
            if viewModel.isLoading {
                LoadingView(text: "Nöbetçi eczaneler aranıyor...")
                    .padding(.bottom, 10)
            } else if let error = viewModel.error {
                ErrorView(message: error.localizedDescription) {
                    viewModel.findNearbyPharmacies()
                }
                .padding(.bottom, 10)
            } else if viewModel.dutyPharmacies.isEmpty {
                InformationView(message: "Yakınınızda nöbetçi eczane bulunamadı")
                    .padding(.bottom, 10)
            }
        }
        .padding()
    }
    
    // Konum izni görünümü
    private var locationPermissionView: some View {
        Group {
            if viewModel.showLocationPermissionAlert {
                VStack {
                    Spacer()
                    
                    LocationPermissionView(viewModel: viewModel)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: viewModel.showLocationPermissionAlert)
            }
        }
    }
    
    // Eczane listesi görünümü için buton
    private var pharmacyListButton: some View {
        VStack {
            Spacer()
            
            Button(action: {
                showPharmacyDetails = true
                if !viewModel.dutyPharmacies.isEmpty {
                    selectedPharmacy = viewModel.dutyPharmacies.first
                }
            }) {
                HStack {
                    Image(systemName: "list.bullet")
                    Text("Nöbetçi Eczaneleri Görüntüle")
                    Image(systemName: "chevron.right")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .foregroundColor(.blue)
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding()
            }
        }
    }
}

// ViewModel
@MainActor
class DutyPharmacyViewModel: ObservableObject {
    @Published var dutyPharmacies: [DutyPharmacy] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var location: CLLocation?
    @Published var showLocationPermissionAlert = false
    
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Konum yöneticisinden gelen değişiklikleri dinle
        locationManager.$authorizationStatus
            .sink { [weak self] status in
                self?.handleAuthorizationStatus(status)
            }
            .store(in: &cancellables)
        
        locationManager.$location
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.location = location
                self?.findNearbyPharmacies()
            }
            .store(in: &cancellables)
        
        locationManager.$error
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.error = error
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    // Konum iznini kontrol et
    func checkLocationPermission() {
        if locationManager.isAuthorized {
            locationManager.requestLocation()
        } else {
            showLocationPermissionAlert = true
        }
    }
    
    // Konum izni iste
    func requestLocationPermission() {
        locationManager.requestLocationPermission()
        showLocationPermissionAlert = false
    }
    
    // Konum izni durumunu yönet
    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            showLocationPermissionAlert = false
            locationManager.requestLocation()
        case .denied, .restricted:
            showLocationPermissionAlert = true
            error = NSError(domain: "DutyPharmacyViewModel", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Konum izni verilmedi. Nöbetçi eczaneleri görebilmek için konum izni vermeniz gerekiyor."])
        case .notDetermined:
            showLocationPermissionAlert = true
        @unknown default:
            break
        }
    }
    
    // Yakındaki nöbetçi eczaneleri bul
    func findNearbyPharmacies() {
        guard let location = location else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let pharmacies = try await PharmacyService.shared.findNearbyPharmaciesAsync(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                
                self.dutyPharmacies = pharmacies
                self.isLoading = false
            } catch {
                self.error = error
                self.isLoading = false
            }
        }
    }
}

// Yardımcı görünümler
struct LoadingView: View {
    let text: String
    
    var body: some View {
        HStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .padding(.trailing, 8)
            Text(text)
                .font(.subheadline)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
                Text("Hata")
                    .font(.headline)
                    .foregroundColor(.red)
            }
            
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
            
            Button("Tekrar Dene") {
                retryAction()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct InformationView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundColor(.blue)
            Text(message)
                .font(.subheadline)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct LocationPermissionView: View {
    var viewModel: DutyPharmacyViewModel
    @State private var isRequestingPermission = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "location.circle")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
            
            Text("Konum İzni Gerekli")
                .font(.headline)
            
            Text("Nöbetçi eczaneleri görüntüleyebilmek için konum izni vermeniz gerekmektedir.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
            
            VStack(spacing: 10) {
                Button("Konum İzni İste") {
                    // State'i önce değiştir, sonra işlemi yap
                    isRequestingPermission = true
                    
                    // İzin isteğini yap
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        viewModel.requestLocationPermission()
                        
                        // 1 saniye sonra butonları tekrar aktif et
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isRequestingPermission = false
                        }
                    }
                }
                .disabled(isRequestingPermission)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(isRequestingPermission ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .frame(maxWidth: .infinity)
                
                Button("Ayarlar'a Git") {
                    isRequestingPermission = true
                    
                    // Ayarlar'a yönlendir
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                        
                        // 1 saniye sonra butonları tekrar aktif et  
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isRequestingPermission = false
                        }
                    }
                }
                .disabled(isRequestingPermission)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color(red: 0.3, green: 0.3, blue: 0.3))
                .foregroundColor(.white)
                .cornerRadius(8)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct DutyPharmacyDetailView: View {
    let pharmacy: DutyPharmacy
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(pharmacy.pharmacyName)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.red)
            
            // İletişim bilgileri
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.gray)
                    Text(pharmacy.formattedAddress)
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.gray)
                    Text(pharmacy.formattedPhone)
                        .font(.subheadline)
                }
                
                if let directions = pharmacy.directions, !directions.isEmpty {
                    HStack {
                        Image(systemName: "signpost.right.fill")
                            .foregroundColor(.gray)
                        Text(directions)
                            .font(.subheadline)
                    }
                }
                
                // Nöbet bilgileri
                if let startDate = pharmacy.dutyStartDate, let endDate = pharmacy.dutyEndDate {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.gray)
                        Text("Nöbet: \(formattedDate(startDate)) - \(formattedDate(endDate))")
                            .font(.subheadline)
                    }
                }
                
                if let distanceKm = pharmacy.distanceKm {
                    HStack {
                        Image(systemName: "arrow.triangle.swap")
                            .foregroundColor(.gray)
                        Text("Uzaklık: \(String(format: "%.2f", distanceKm)) km")
                            .font(.subheadline)
                    }
                }
            }
            
            Divider()
            
            // Haritalara yönlendirme butonları
            HStack {
                Button(action: {
                    openInAppleMaps()
                }) {
                    VStack {
                        Image(systemName: "map.fill")
                            .font(.system(size: 24))
                        Text("Apple Harita")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    openInGoogleMaps()
                }) {
                    VStack {
                        Image(systemName: "globe")
                            .font(.system(size: 24))
                        Text("Google Harita")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    callPharmacy()
                }) {
                    VStack {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 24))
                        Text("Ara")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                    .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func openInAppleMaps() {
        let coordinate = pharmacy.coordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = pharmacy.pharmacyName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    private func openInGoogleMaps() {
        let coordinate = pharmacy.coordinate
        let urlString = "https://www.google.com/maps/dir/?api=1&destination=\(coordinate.latitude),\(coordinate.longitude)&travelmode=driving"
        
        if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
            UIApplication.shared.open(url)
        }
    }
    
    private func callPharmacy() {
        let phone = pharmacy.formattedPhone.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(phone)") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    NavigationView {
        DutyPharmacyView()
    }
} 