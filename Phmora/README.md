# Pharmora iOS Projesi

## 📱 Proje Genel Bakış

Pharmora, eczacılar arasında ilaç değişimini kolaylaştıran, stok yönetimini optimize eden ve ilaç israfını azaltmayı hedefleyen iOS uygulamasıdır.

### 🎯 Ana Özellikler
- ✅ Kullanıcı kimlik doğrulama (giriş/kayıt)
- ✅ Eczane haritası görünümü
- ✅ Nöbetçi eczane bulma
- ✅ İlaç arama (FDA API entegrasyonu)
- ✅ Profil yönetimi
- ✅ Bildirimler sistemi
- 🔄 İlaç satış/satın alma (geliştiriliyor)
- 🔄 Teklif sistemi (geliştiriliyor)

## 🏗️ Teknik Mimari

### Platform Gereksinimleri
- **iOS**: 18.4+
- **Swift**: 6.0
- **Xcode**: 16.3
- **Mimari**: MVVM Pattern
- **UI Framework**: SwiftUI
- **State Management**: @StateObject, @Observable, @Environment
- **Async**: async/await pattern
- **Network**: URLSession (third-party kütüphane yok)

### 📁 Dosya Yapısı

```
Phmora/
├── App/                          # Ana uygulama dosyaları
│   ├── PhmoraApp.swift          # App entry point
│   └── Info.plist               # App configuration
├── Core/                        # Temel işlevler
│   ├── Models/                  # Veri modelleri
│   │   └── Models.swift         # Pharmacy, Medication, User modelleri
│   ├── Services/                # API servisleri
│   │   ├── AuthService.swift    # Kimlik doğrulama
│   │   ├── PharmacyService.swift # Eczane API'leri
│   │   ├── OpenFDAService.swift # FDA API entegrasyonu
│   │   └── LocationManager.swift # Konum servisleri
│   └── Utils/                   # Yardımcı dosyalar
│       ├── AppConstants.swift   # Sabit değerler
│       └── Extensions.swift     # Swift extensions
├── Features/                    # Özellik modülleri
│   ├── Auth/                    # Giriş/Kayıt
│   │   └── ContentView.swift    # Login/Register UI
│   ├── Home/                    # Ana ekran
│   │   ├── HomeView.swift       # Dashboard + Map
│   │   └── MainView.swift       # Tab navigation
│   ├── Search/                  # Arama özellikleri
│   │   ├── SearchView.swift     # İlaç arama
│   │   └── FDADrugSearchView.swift # FDA arama
│   ├── Pharmacy/                # Eczane işlemleri
│   │   ├── DutyPharmacyView.swift # Nöbetçi eczaneler
│   │   └── AddMedicationView.swift # İlaç ekleme
│   ├── Profile/                 # Profil yönetimi
│   ├── Notifications/           # Bildirimler
│   ├── Offers/                  # Teklif sistemi
│   └── Purchase/                # Satın alma işlemleri
└── Resources/                   # Görseller ve assets
    ├── Assets.xcassets/
    └── Images/
```

## 🔧 Ana Bileşenler

### 1. Authentication (Kimlik Doğrulama)
- **Dosya**: `Features/Auth/ContentView.swift`
- **Servis**: `Core/Services/AuthService.swift`
- **API**: Backend login/register endpoints
- **Durum**: ✅ Çalışıyor

### 2. Home Dashboard
- **Dosya**: `Features/Home/HomeView.swift` (541 satır - refactoring gerekli)
- **Özellikler**:
  - İnteraktif harita görünümü
  - Eczane annotations
  - Toggle: Normal eczaneler / Nöbetçi eczaneler
  - Eczane detay sheet'leri
- **Durum**: ✅ Çalışıyor, Mock veriler kullanılıyor

### 3. Nöbetçi Eczane Sistemi
- **Dosya**: `Features/Pharmacy/DutyPharmacyView.swift`
- **API**: Gerçek backend entegrasyonu mevcut
- **Özellikler**: Konum bazlı arama, harita görünümü
- **Durum**: ✅ Çalışıyor

### 4. FDA İlaç Arama
- **Dosya**: `Features/Search/FDADrugSearchView.swift`
- **API**: OpenFDA public API
- **Servis**: `Core/Services/OpenFDAService.swift`
- **Durum**: ✅ Çalışıyor

## 🎨 UI/UX Design System

### Renk Paleti
```swift
// AppConstants.Colors
static let primary = Color(red: 0.4, green: 0.5, blue: 0.4)     // Yeşil ton
static let secondary = Color(red: 0.85, green: 0.5, blue: 0.2)  // Turuncu ton
static let background = Color(red: 0.95, green: 0.97, blue: 0.95) // Açık yeşil
```

### Animasyonlar
- Spring animations (response: 0.3, damping: 0.7)
- Pulse effects for selections
- Smooth transitions between views

## 🔗 API Entegrasyonları

### 1. Backend API
- **Base URL**: `https://phamorabackend-production.up.railway.app/api`
- **Endpoints**:
  - `POST /auth/login` - Kullanıcı girişi
  - `GET /pharmacy/nearby` - Yakındaki eczaneler
  - `GET /pharmacy/list` - Şehir bazlı eczaneler

### 2. OpenFDA API
- **Purpose**: İlaç bilgileri ve yan etkiler
- **Implementation**: `Core/Services/OpenFDAService.swift`
- **Status**: ✅ Aktif

## 🧪 Test Coverage

- **Unit Tests**: `PhmoraTests/`
- **UI Tests**: `PhmoraUITests/`
- **Current Coverage**: Minimal (geliştirme gerekli)

## 🚀 Geliştirme Notları

### Öncelikli İyileştirmeler
1. **HomeView Refactoring**: 541 satır çok büyük, parçalara bölünmeli
2. **MVVM Consistency**: ViewModel pattern'ı tüm feature'larda tutarlı uygulanmalı
3. **Error Handling**: Daha kapsamlı hata yönetimi
4. **Constants Organization**: Hard-coded değerler AppConstants'a taşınmalı
5. **Documentation**: Tüm public API'ler dokümante edilmeli

### Eksik Özellikler
- [ ] Firebase entegrasyonu (Auth, Firestore, Storage)
- [ ] Push notification sistemi
- [ ] Gerçek zamanlı veri senkronizasyonu
- [ ] Admin paneli
- [ ] Kapsamlı unit testler
- [ ] Dark mode tam desteği
- [ ] Accessibility features

### Bilinen Sorunlar
- HomeView çok büyük (541 satır)
- Mock veriler hardcoded
- MVVM pattern tutarsız
- Error handling eksik

## 📝 Kod Standartları

### Swift Conventions
- MARK comments kullanımı
- Documentation comments (///)
- Modern Swift 6.0 features
- Async/await pattern preference

### SwiftUI Best Practices
- @StateObject for ViewModels
- @Published for reactive properties
- Computed properties for derived state
- ViewBuilder for conditional views

## 🔍 Debugging İpuçları

### Xcode Ayarları
- Build Settings → Info.plist File: "Phmora/App/Info.plist"
- Generate Info.plist File: NO
- iOS Deployment Target: 18.4

### Common Issues
1. **Info.plist conflicts**: Build Settings kontrol et
2. **Location permissions**: Info.plist'te tanımlı
3. **API timeouts**: NetworkService timeout ayarları

## 🤝 Katkı Rehberi

### Yeni Feature Ekleme
1. `Features/` altında yeni klasör oluştur
2. MVVM pattern'ı takip et
3. Constants'ı `AppConstants`'a ekle
4. Unit testler yaz
5. Documentation ekle

### Code Review Checklist
- [ ] MARK comments eklendi
- [ ] Documentation yazıldı
- [ ] Constants kullanıldı
- [ ] Error handling eklendi
- [ ] Unit testler yazıldı

---

## 📞 İletişim

- **Proje**: Pharmora iOS
- **Platform**: iOS 18.4+
- **Framework**: SwiftUI + MVVM
- **Durum**: Active Development

> **Not**: Bu dokümantasyon, Cursor AI assistant'ın projeyi daha iyi anlaması için hazırlanmıştır. 