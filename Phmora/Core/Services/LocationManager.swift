import Foundation
import CoreLocation
import Combine

@MainActor
class LocationManager: NSObject, ObservableObject {
    // CLLocationManager nesnesi
    private let locationManager = CLLocationManager()
    
    // Yayınlanan değerler
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var location: CLLocation?
    @Published var error: Error?
    
    // Konum servisi durumunu kontrol et
    var isLocationServicesEnabled: Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    override init() {
        super.init()
        
        // Delegate'i ayarla
        locationManager.delegate = self
        
        // Konum ayarlarını yapılandır
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50 // 50 metre
        
        // Mevcut izin durumunu ayarla
        authorizationStatus = locationManager.authorizationStatus
        
        print("LocationManager başlatıldı, mevcut izin durumu: \(authorizationStatus.rawValue)")
    }
    
    // Konum izni isteme
    func requestLocationPermission() {
        print("Konum izni isteniyor...")
        
        let authorizationStatus = locationManager.authorizationStatus
        print("Mevcut izin durumu: \(authorizationStatus.rawValue)")
        
        // Şu anki izin durumuna göre işlem yap
        switch authorizationStatus {
        case .notDetermined:
            // Kullanıcıdan henüz izin istenmemiş, iste
            print("Konum izni isteniyor (notDetermined)...")
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted, .denied:
            // İzin reddedilmiş, kullanıcıyı ayarlara yönlendir
            print("Konum izni reddedilmiş veya kısıtlanmış")
            error = NSError(
                domain: "LocationManager",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Konum izni reddedildi. Ayarlar > Gizlilik ve Güvenlik > Konum Servisleri > Pharmora yolunu izleyerek konum iznini etkinleştirin."
                ]
            )
            
        case .authorizedWhenInUse, .authorizedAlways:
            // İzin zaten verilmiş, konum al
            print("Konum izni mevcut, konum isteniyor...")
            Task {
                await requestLocationAsync()
            }
            
        @unknown default:
            break
        }
    }
    
    // Async konum alma - UI unresponsiveness'ı önler
    private func requestLocationAsync() async {
        await Task { @MainActor in
            print("Async konum isteniyor...")
            
            if CLLocationManager.locationServicesEnabled() {
                if isAuthorized {
                    print("Konum servisleri açık ve izin verilmiş, konum isteniyor...")
                    // Background thread'de location request yap
                    Task.detached { [weak self] in
                        await self?.performLocationRequest()
                    }
                    
                    // iOS 14+ için hassas konum doğruluğunu kontrol et
                    if #available(iOS 14.0, *), locationManager.accuracyAuthorization == .reducedAccuracy {
                        print("Hassas konum izni isteniyor...")
                        locationManager.requestTemporaryFullAccuracyAuthorization(
                            withPurposeKey: "NearbyPharmaciesAccuracy"
                        )
                    }
                } else {
                    print("Konum servisleri açık fakat izin verilmemiş, izin isteniyor...")
                    requestLocationPermission()
                }
            } else {
                // Konum servisleri kapalıysa hata bildir
                print("Konum servisleri kapalı")
                error = NSError(
                    domain: "LocationManager",
                    code: 2,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Konum servisleri kapalı. Lütfen Ayarlar > Gizlilik ve Güvenlik > Konum Servisleri bölümünden konum servislerini açın."
                    ]
                )
            }
        }.value
    }
    
    // Background thread'de location request - UI blocking'i önler
    private func performLocationRequest() async {
        await MainActor.run {
            locationManager.requestLocation()
        }
    }
    
    // Tek seferlik konum alma - Public interface
    func requestLocation() {
        Task {
            await requestLocationAsync()
        }
    }
    
    // Sürekli konum güncellemelerini başlatma
    func startUpdatingLocation() {
        if isAuthorized {
            locationManager.startUpdatingLocation()
        } else {
            requestLocationPermission()
        }
    }
    
    // Konum güncellemelerini durdurma
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // Konum izni kontrolü
    var isAuthorized: Bool {
        let status = locationManager.authorizationStatus
        return status == .authorizedAlways || status == .authorizedWhenInUse
    }
    
    // Hassas konum izni kontrolü
    @available(iOS 14, *)
    var hasFullAccuracy: Bool {
        return locationManager.accuracyAuthorization == .fullAccuracy
    }
}

// CLLocationManagerDelegate uygulaması
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Konum izni durumu değişti: \(manager.authorizationStatus.rawValue)")
        
        // Ana thread'de güncelle
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                print("Konum izni verildi, konum isteniyor...")
                self.error = nil
                // Authorization callback'inden sonra location request yap
                Task {
                    await self.requestLocationAsync()
                }
                
            case .denied, .restricted:
                print("Konum izni reddedildi veya kısıtlandı")
                self.error = NSError(
                    domain: "LocationManager",
                    code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Konum izni verilmedi. Ayarlar > Gizlilik ve Güvenlik > Konum Servisleri > Pharmora yolunu izleyerek 'Uygulamayı kullanırken' seçeneğini seçin."
                    ]
                )
                
            case .notDetermined:
                print("Konum izni henüz belirlenmedi")
                
            @unknown default:
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Konum güncellendi: \(locations.count) lokasyon alındı")
        
        Task { @MainActor in
            // En son ve en doğru konumu al
            if let location = locations.last {
                print("Konum alındı: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                self.location = location
                self.error = nil
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum alınamadı: \(error.localizedDescription)")
        
        Task { @MainActor in
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    self.error = NSError(
                        domain: "LocationManager",
                        code: 1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Konum hizmeti reddedildi. Ayarlar > Gizlilik ve Güvenlik > Konum Servisleri > Pharmora yolunu izleyerek 'Uygulamayı kullanırken' seçeneğini seçin."
                        ]
                    )
                    
                case .locationUnknown:
                    self.error = NSError(
                        domain: "LocationManager",
                        code: 3,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Konumunuz geçici olarak belirlenemedi. Lütfen tekrar deneyin."
                        ]
                    )
                    
                default:
                    self.error = error
                }
            } else {
                self.error = error
            }
        }
    }
    
    // iOS 14+ için konum doğruluğu değişikliği
    @available(iOS 14.0, *)
    func locationManagerDidChangeAccuracyAuthorization(_ manager: CLLocationManager) {
        print("Konum doğruluğu değişti: \(manager.accuracyAuthorization.rawValue)")
        
        Task { @MainActor in
            if manager.accuracyAuthorization == .reducedAccuracy {
                print("Hassas konum izni yok, isteniyor...")
                self.locationManager.requestTemporaryFullAccuracyAuthorization(
                    withPurposeKey: "NearbyPharmaciesAccuracy"
                )
            }
        }
    }
} 