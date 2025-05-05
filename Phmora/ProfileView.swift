import SwiftUI

struct ProfileView: View {
    @State private var showingLogoutAlert = false
    
    // Kullanıcı bilgileri (gerçek uygulamada veritabanından gelecek)
    let name = "Ahmet Yılmaz"
    let pharmacyName = "Merkez Eczanesi"
    let email = "ahmet.yilmaz@example.com"
    let phone = "0532 123 4567"
    let address = "İstiklal Cad. No:123, Beyoğlu, İstanbul"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Profil başlığı
                VStack(spacing: 20) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                        .background(Circle().fill(Color.white))
                        .shadow(color: .gray.opacity(0.3), radius: 5)
                    
                    VStack(spacing: 5) {
                        Text(name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(pharmacyName)
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                // Kişisel bilgiler
                VStack(alignment: .leading, spacing: 20) {
                    Text("Kişisel Bilgiler")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        profileRow(icon: "envelope", title: "E-posta", detail: email)
                            .padding(.vertical, 12)
                        Divider().padding(.leading, 50)
                        profileRow(icon: "phone", title: "Telefon", detail: phone)
                            .padding(.vertical, 12)
                        Divider().padding(.leading, 50)
                        profileRow(icon: "location", title: "Adres", detail: address)
                            .padding(.vertical, 12)
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    .padding(.horizontal)
                }
                
                // İstatistikler
                VStack(alignment: .leading, spacing: 20) {
                    Text("İşlem İstatistikleri")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: 15) {
                        statCard(title: "Satış", value: "12", icon: "arrow.up.right", color: .green)
                        statCard(title: "Alış", value: "8", icon: "arrow.down.left", color: .blue)
                        statCard(title: "İlanlar", value: "5", icon: "tag", color: .orange)
                    }
                    .padding(.horizontal)
                }
                
                // Ayarlar
                VStack(alignment: .leading, spacing: 20) {
                    Text("Ayarlar")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        settingsRow(icon: "bell", title: "Bildirim Ayarları")
                        Divider().padding(.leading, 50)
                        settingsRow(icon: "shield", title: "Gizlilik Ayarları")
                        Divider().padding(.leading, 50)
                        settingsRow(icon: "hand.raised", title: "Yardım ve Destek")
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    .padding(.horizontal)
                }
                
                // Çıkış yap butonu
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    Text("Çıkış Yap")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.top, 10)
                .alert(isPresented: $showingLogoutAlert) {
                    Alert(
                        title: Text("Çıkış Yap"),
                        message: Text("Hesabınızdan çıkış yapmak istediğinize emin misiniz?"),
                        primaryButton: .destructive(Text("Çıkış Yap")) {
                            // Çıkış işlemi
                        },
                        secondaryButton: .cancel(Text("İptal"))
                    )
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Profilim")
        .background(Color(.systemGroupedBackground))
    }
    
    private func profileRow(icon: String, title: String, detail: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(detail)
                    .font(.subheadline)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func settingsRow(icon: String, title: String) -> some View {
        Button(action: {
            // Ayar işlemi
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                    .frame(width: 30)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            
            HStack {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
} 