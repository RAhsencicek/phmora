import SwiftUI
import MapKit
import Combine
import Observation

struct DutyPharmacyView: View {
    @State private var viewModel = DutyPharmacyViewModel()
    @State private var selectedPharmacy: DutyPharmacy?
    @State private var showPharmacyDetails = false
    @State private var showingLocationPermissionAlert = false
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Harita görünümü
            Map(initialPosition: .region(mapRegion)) {
                ForEach(viewModel.dutyPharmacies) { pharmacy in
                    Marker(coordinate: pharmacy.coordinate) {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 40, height: 40)
                                .shadow(radius: 2)
                            
                            Image(systemName: "cross.fill")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(Color.red)
                        }
                    }
                    .tag(pharmacy)
                    .annotationTitles(.hidden)
                }
                
                UserAnnotation()
            }
            .mapStyle(.standard)
            .mapControls {
                MapCompass()
                MapUserLocationButton()
                MapScaleView()
            }
            .onTapGesture { location in
                guard let pharmacy = viewModel.dutyPharmacies.first(where: { marker in
                    // Basit bir mesafe hesabı
                    let mapLocation = location
                    let pharmacyLocation = MKMapPoint(pharmacy.coordinate)
                    return MKMapPoint.distance(mapLocation, pharmacyLocation) < 30000 // Piksel bazlı
                }) else { return }
                
                selectedPharmacy = pharmacy
                showPharmacyDetails = true
            }
            
            // Durum ve bilgi görünümü
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
            
            // Konum izni isteme yönetimi
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
        .onChange(of: viewModel.location) { _, newLocation in
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
        .onChange(of: viewModel.showLocationPermissionAlert) { _, shouldShow in
            if shouldShow {
                // SwiftUI alert kullanımı için ayrı bir state değişkeni
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showingLocationPermissionAlert = true
                }
            }
        }
        .navigationTitle("Nöbetçi Eczaneler")
    }
}

// ViewModel
@Observable
class DutyPharmacyViewModel {
    var dutyPharmacies: [DutyPharmacy] = []
    var isLoading = false
    var error: Error?
    var location: CLLocation?
    var showLocationPermissionAlert = false
    
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // iOS 18'de @Observable ile değişkenleri dinleme
        Task {
            // @Observable değişikliklerini dinle (iOS 18.4)
            for await _ in Observation.Notifications.updates(for: locationManager) {
                await MainActor.run {
                    handleAuthorizationStatus(locationManager.authorizationStatus)
                    
                    // Konum veya hata değişimini kontrol et
                    if let location = locationManager.location {
                        self.location = location
                        findNearbyPharmacies()
                    }
                    
                    if let error = locationManager.error {
                        self.error = error
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    // Konum iznini kontrol et
    func checkLocationPermission() {
        Task { @MainActor in
            if locationManager.isAuthorized {
                locationManager.requestLocation()
            } else {
                showLocationPermissionAlert = true
            }
        }
    }
    
    // Konum izni iste
    func requestLocationPermission() {
        Task { @MainActor in
            locationManager.requestLocationPermission()
            showLocationPermissionAlert = false
        }
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
                
                await MainActor.run {
                    self.dutyPharmacies = pharmacies
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
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