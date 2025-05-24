# Pharmora - Eczaneler Arası İlaç Ticaret Platformu

Pharmora, eczaneler arasında ilaç alım-satımı ve takasını kolaylaştıran modern bir iOS uygulamasıdır.

## 🎯 Ana Özellikler

- 🏥 **Eczane Ağı**: Eczaneleri haritada görüntüleme ve keşfetme
- 💊 **İlaç Envanteri**: Mevcut ilaçları listeleme ve yönetme
- 🤝 **Ticaret Sistemi**: Eczaneler arası ilaç alım-satımı
- 📊 **Stok Yönetimi**: İlaç stoklarını takip etme
- 🔍 **Arama ve Filtreleme**: İhtiyaç duyulan ilaçları kolayca bulma
- 📱 **Modern Arayüz**: SwiftUI ile geliştirilmiş kullanıcı dostu tasarım

## 🏗️ Teknik Mimari

### Katmanlar

1. **PharmacyService**: API isteklerini yöneten servis katmanı
2. **LocationManager**: Konum izinleri ve konum bilgisi yönetimi
3. **Models**: Eczane, İlaç ve diğer veri modelleri
4. **ViewModels**: MVVM mimarisi ile state yönetimi
5. **Views**: SwiftUI ile geliştirilmiş kullanıcı arayüzleri

### Teknoloji Stack

- **Platform**: iOS 18.4+
- **Dil**: Swift 6.0
- **Geliştirme Ortamı**: Xcode 16.3
- **UI Framework**: SwiftUI
- **Mimari**: MVVM
- **Async Operations**: Swift Concurrency (async/await)
- **Harita**: MapKit
- **Database**: SwiftData (planlanan)
- **Backend**: Firebase (planlanan)

## 📁 Proje Yapısı

```
Phmora/
├── App/                          # Ana uygulama dosyaları
├── Core/                         # Temel bileşenler
│   ├── Models/                   # Veri modelleri
│   ├── Services/                 # API servisleri
│   ├── Utils/                    # Yardımcı sınıflar
│   └── MockData/                 # Test veriler
├── Features/                     # Özellik bazlı modüller
│   ├── Auth/                     # Kimlik doğrulama
│   ├── Home/                     # Ana sayfa
│   ├── Search/                   # Arama özellikleri
│   └── Pharmacy/                 # Eczane yönetimi
└── Resources/                    # Görseller ve kaynaklar
```

## 🚀 Kurulum ve Çalıştırma

1. Projeyi klonlayın:
```bash
git clone https://github.com/RAhsencicek/phmora.git
cd phmora
```

2. Xcode ile açın:
```bash
open Phmora.xcodeproj
```

3. Projeyi çalıştırın (⌘+R)

## 🔮 Gelecek Özellikler

- [ ] Firebase entegrasyonu
- [ ] Gerçek zamanlı bildirimler
- [ ] Ödeme sistemi entegrasyonu
- [ ] Analitik ve raporlama
- [ ] Admin paneli
- [ ] Çoklu dil desteği

## 🤝 Katkıda Bulunma

1. Projeyi fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. 