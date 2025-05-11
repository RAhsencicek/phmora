# Nöbetçi Eczane Modülü Geliştirmesi

Bu geliştirme, Pharmora uygulamasına nöbetçi eczane görüntüleme özelliği eklemektedir.

## Eklenen Özellikler

- 📍 Konum tabanlı nöbetçi eczane bulma
- 🗺 Haritada nöbetçi eczaneleri görüntüleme 
- 🔍 Eczane detaylarını inceleme (ad, adres, telefon, adres tarifi)
- 🧭 Apple Harita ve Google Harita ile yol tarifi alma
- 📱 Doğrudan eczaneyi arama

## Teknik Detaylar

### Katmanlar

1. **PharmacyService**: API isteklerini yöneten servis katmanı
2. **LocationManager**: Konum izinleri ve konum bilgisi yönetimi
3. **DutyPharmacyViewModel**: Nöbetçi eczane verilerini ve işlemleri yöneten ViewModel
4. **DutyPharmacyView**: Nöbetçi eczaneleri gösteren arayüz bileşeni
5. **DutyPharmacyDetailView**: Eczane detaylarını gösteren arayüz bileşeni

### Kullanılan API

Nöbetçi eczane verileri, aşağıdaki API endpointinden alınmaktadır:
- API URL: `https://phamorabackend-production.up.railway.app/api/pharmacy`
- Endpointler:
  - `/nearby`: Yakındaki eczaneleri bulmak için
  - `/list`: İl ve ilçeye göre eczaneleri listelemek için

### Konum İzinleri

Uygulama, kullanıcının konumuna erişebilmek için gerekli izinleri ister. Bu izinler Info.plist dosyasında tanımlanmıştır:
- `NSLocationWhenInUseUsageDescription`: Uygulama kullanılırken konum erişimi için
- `NSLocationTemporaryUsageDescriptionDictionary`: Tam konum erişimi için

## Kullanım

1. Ana ekrandaki segmentli kontrolde "Nöbetçi Eczaneler" seçeneğine tıklayın
2. İstenirse konum izni verin
3. Haritada kırmızı ikonlarla gösterilen nöbetçi eczaneleri görüntüleyin
4. Eczane bilgilerini görmek için eczane ikonuna tıklayın
5. Detaylar sayfasından yol tarifi alın veya eczaneyi arayın

## Geliştirme ve Test Ortamı

- iOS 18.4
- Swift 6.0
- Xcode 16.3
- SwiftUI
- Swift Concurrency
- Combine Framework
- MapKit 