import SwiftUI
import Combine
import MapKit

struct ProfileView: View {
    @StateObject private var authService = AuthService.shared
    @State private var showingLogoutAlert = false
    @State private var userPharmacy: Pharmacy?
    @State private var isLoadingPharmacy = false
    @State private var cancellables = Set<AnyCancellable>()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Profil başlığı
                VStack(spacing: 20) {
                    // Profil resmi
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.6), Color.green.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: .blue.opacity(0.3), radius: 10)
                        
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 8) {
                        if let user = authService.currentUser {
                            Text(user.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Eczacı ID: \(user.pharmacistId)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        } else {
                            Text("Kullanıcı Bilgisi Yükleniyor...")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.top, 20)
                
                // Eczane bilgileri
                if let pharmacy = userPharmacy {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image(systemName: "cross.case.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            Text("Eczane Bilgileri")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            profileRow(
                                icon: "building.2",
                                title: "Eczane Adı",
                                detail: pharmacy.name,
                                color: .blue
                            )
                            Divider().padding(.leading, 50)
                            
                            profileRow(
                                icon: "location",
                                title: "Adres",
                                detail: pharmacy.address.fullAddress ?? pharmacy.fullAddress,
                                color: .orange
                            )
                            Divider().padding(.leading, 50)
                            
                            profileRow(
                                icon: "phone",
                                title: "Telefon",
                                detail: pharmacy.phone,
                                color: .green
                            )
                            
                            if let email = pharmacy.email {
                                Divider().padding(.leading, 50)
                                profileRow(
                                    icon: "envelope",
                                    title: "E-posta",
                                    detail: email,
                                    color: .purple
                                )
                            }
                            
                            Divider().padding(.leading, 50)
                            
                            profileRow(
                                icon: "doc.text",
                                title: "Lisans No",
                                detail: pharmacy.licenseNumber,
                                color: .red
                            )
                            
                            Divider().padding(.leading, 50)
                            
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(pharmacy.isActive ? .green : .red)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Durum")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Text(pharmacy.isActive ? "Aktif" : "Pasif")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(pharmacy.isActive ? .green : .red)
                                }
                                
                                Spacer()
                                
                                if pharmacy.isOnDuty {
                                    Text("Nöbetçi")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.red)
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                    }
                } else if isLoadingPharmacy {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Eczane bilgileri yükleniyor...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                
                // Hızlı işlemler
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                            .font(.title2)
                        Text("Hızlı İşlemler")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        NavigationLink(destination: PharmacyDetailView(pharmacy: userPharmacy ?? Pharmacy.mockPharmacy)) {
                            quickActionRow(
                                icon: "pill.fill",
                                title: "İlaç Stokları",
                                subtitle: "Mevcut ilaçlarınızı görüntüleyin",
                                color: .blue
                            )
                        }
                        .disabled(userPharmacy == nil)
                        
                        Divider().padding(.leading, 50)
                        
                        NavigationLink(destination: NotificationsView()) {
                            quickActionRow(
                                icon: "bell",
                                title: "Bildirimler",
                                subtitle: "Yeni bildirimleri kontrol edin",
                                color: .orange
                            )
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                }
                
                // Çıkış yap butonu
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.right.square")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("Çıkış Yap")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color.red.opacity(0.8), Color.red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .alert("Çıkış Yap", isPresented: $showingLogoutAlert) {
                    Button("İptal", role: .cancel) { }
                    Button("Çıkış Yap", role: .destructive) {
                        performLogout()
                    }
                } message: {
                    Text("Hesabınızdan çıkış yapmak istediğinize emin misiniz?")
                }
                
                Spacer(minLength: 30)
            }
            .padding(.vertical)
        }
        .navigationTitle("Profilim")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(red: 0.95, green: 0.97, blue: 0.98).ignoresSafeArea())
        .onAppear {
            loadUserPharmacy()
        }
    }
    
    // MARK: - Helper Views
    private func profileRow(icon: String, title: String, detail: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
                .font(.system(size: 16, weight: .medium))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(detail)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func quickActionRow(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
                .font(.system(size: 18, weight: .medium))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    private func loadUserPharmacy() {
        guard let pharmacistId = authService.currentUser?.pharmacistId else { return }
        
        isLoadingPharmacy = true
        
        // PharmacyService'den eczane bilgilerini yükle
        PharmacyService.shared.fetchAllPharmacies()
        
        // PharmacyService'in published pharmacies değişkenini dinle
        PharmacyService.shared.$pharmacies
            .receive(on: DispatchQueue.main)
            .sink { pharmacies in
                // Giriş yapan kullanıcının eczanesini bul
                userPharmacy = pharmacies.first { pharmacy in
                    pharmacy.owner?.pharmacistId == pharmacistId
                }
                isLoadingPharmacy = false
            }
            .store(in: &cancellables)
    }
    
    private func performLogout() {
        // AuthService'den çıkış yap
        authService.logout()
        
        // Dismiss kullanmaya gerek yok, ContentView otomatik olarak loading ekranına geçecek
    }
}

// MARK: - Mock Data Extension
extension Pharmacy {
    static var mockPharmacy: Pharmacy {
        Pharmacy(
            name: "Mock Eczane",
            address: "Mock Sokak, Mock İlçe/Mock Şehir",
            phone: "0000 000 0000",
            coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
            availableMedications: []
        )
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
} 