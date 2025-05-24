#!/usr/bin/env python3
"""
Xcode proje dosyasındaki dosya referanslarını yeni klasör yapısına göre günceller
"""

import os
import re

# Dosya taşıma eşlemeleri
file_mappings = {
    'PhmoraApp.swift': 'App/PhmoraApp.swift',
    'Info.plist': 'App/Info.plist',
    'Models.swift': 'Core/Models/Models.swift',
    'AuthService.swift': 'Core/Services/AuthService.swift',
    'PharmacyService.swift': 'Core/Services/PharmacyService.swift',
    'OpenFDAService.swift': 'Core/Services/OpenFDAService.swift',
    'LocationManager.swift': 'Core/Services/LocationManager.swift',
    'FDAMockData.swift': 'Core/MockData/FDAMockData.swift',
    'ContentView.swift': 'Features/Auth/ContentView.swift',
    'HomeView.swift': 'Features/Home/HomeView.swift',
    'MainView.swift': 'Features/Home/MainView.swift',
    'SearchView.swift': 'Features/Search/SearchView.swift',
    'FDADrugSearchView.swift': 'Features/Search/FDADrugSearchView.swift',
    'DutyPharmacyView.swift': 'Features/Pharmacy/DutyPharmacyView.swift',
    'AddMedicationView.swift': 'Features/Pharmacy/AddMedicationView.swift',
    'ProfileView.swift': 'Features/Profile/ProfileView.swift',
    'NotificationsView.swift': 'Features/Notifications/NotificationsView.swift',
    'OfferView.swift': 'Features/Offers/OfferView.swift',
    'PurchaseView.swift': 'Features/Purchase/PurchaseView.swift',
    'FDAAdverseEventsView.swift': 'Features/FDA/FDAAdverseEventsView.swift',
    'Assets.xcassets': 'Resources/Assets.xcassets',
    'Images': 'Resources/Images'
}

def update_pbxproj(project_path):
    """Xcode proje dosyasını günceller"""
    pbxproj_path = os.path.join(project_path, 'project.pbxproj')
    
    # Dosyayı oku
    with open(pbxproj_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Backup al
    with open(pbxproj_path + '.backup', 'w', encoding='utf-8') as f:
        f.write(content)
    
    # Dosya yollarını güncelle
    for old_path, new_path in file_mappings.items():
        # path = "dosya.swift" formatındaki yolları güncelle
        content = re.sub(
            f'path = "{re.escape(old_path)}"',
            f'path = "{new_path}"',
            content
        )
        # path = dosya.swift; formatındaki yolları güncelle
        content = re.sub(
            f'path = {re.escape(old_path)};',
            f'path = {new_path};',
            content
        )
        # name = "dosya.swift" formatındaki isimleri koru
        # sourceTree = "<group>" olanları güncelle
        
    # Güncellenmiş içeriği yaz
    with open(pbxproj_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ {pbxproj_path} güncellendi")
    print(f"📁 Backup: {pbxproj_path}.backup")

if __name__ == "__main__":
    project_path = "Phmora.xcodeproj"
    
    if os.path.exists(project_path):
        update_pbxproj(project_path)
        print("\n🎉 Xcode proje dosyası başarıyla güncellendi!")
        print("📌 Xcode'u açmadan önce projeyi temizlemeyi unutmayın:")
        print("   - Xcode'u kapatın")
        print("   - DerivedData klasörünü temizleyin")
        print("   - Xcode'u tekrar açın")
    else:
        print(f"❌ Hata: {project_path} bulunamadı!") 