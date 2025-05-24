#!/usr/bin/env python3
"""
Info.plist çakışmasını çözer
"""

import os
import re

def fix_infoplist_issue(project_path):
    """Xcode proje dosyasındaki Info.plist ayarlarını düzeltir"""
    pbxproj_path = os.path.join(project_path, 'project.pbxproj')
    
    # Dosyayı oku
    with open(pbxproj_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Backup al
    backup_path = pbxproj_path + '.infoplist_backup'
    with open(backup_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    # GENERATE_INFOPLIST_FILE = YES; satırlarını NO yap
    content = re.sub(
        r'GENERATE_INFOPLIST_FILE = YES;',
        'GENERATE_INFOPLIST_FILE = NO;',
        content
    )
    
    # INFOPLIST_FILE ayarını ekle veya güncelle
    # Build Settings bölümünde GENERATE_INFOPLIST_FILE'dan sonra INFOPLIST_FILE ekle
    def add_infoplist_file(match):
        return match.group(0) + '\n\t\t\t\tINFOPLIST_FILE = "Phmora/App/Info.plist";'
    
    # Her GENERATE_INFOPLIST_FILE = NO; satırından sonra INFOPLIST_FILE ekle
    content = re.sub(
        r'(GENERATE_INFOPLIST_FILE = NO;)',
        add_infoplist_file,
        content
    )
    
    # Eğer zaten INFOPLIST_FILE varsa, yolunu güncelle
    content = re.sub(
        r'INFOPLIST_FILE = "[^"]*";',
        'INFOPLIST_FILE = "Phmora/App/Info.plist";',
        content
    )
    
    # Güncellenmiş içeriği yaz
    with open(pbxproj_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ {pbxproj_path} güncellendi")
    print(f"📁 Backup: {backup_path}")
    print("\nYapılan değişiklikler:")
    print("- GENERATE_INFOPLIST_FILE = NO olarak ayarlandı")
    print("- INFOPLIST_FILE = 'Phmora/App/Info.plist' olarak ayarlandı")

if __name__ == "__main__":
    project_path = "Phmora.xcodeproj"
    
    if os.path.exists(project_path):
        fix_infoplist_issue(project_path)
        print("\n🎉 Info.plist sorunu düzeltildi!")
        print("\n📌 Yapmanız gerekenler:")
        print("1. Xcode'u kapatın")
        print("2. DerivedData'yı temizleyin:")
        print("   rm -rf ~/Library/Developer/Xcode/DerivedData")
        print("3. Xcode'u tekrar açın ve Clean Build yapın (Cmd+Shift+K)")
    else:
        print(f"❌ Hata: {project_path} bulunamadı!") 