import SwiftUI

struct NetworkTestView: View {
    @StateObject private var pharmacyService = PharmacyService.shared
    @State private var testResults: [String] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Backend API Test")
                    .font(.title)
                    .fontWeight(.bold)
                
                if pharmacyService.isLoading {
                    ProgressView("API Test Çalışıyor...")
                        .scaleEffect(1.2)
                }
                
                if let errorMessage = pharmacyService.errorMessage {
                    Text("❌ Hata: \(errorMessage)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("📊 Test Sonuçları:")
                        .font(.headline)
                    
                    Text("Toplam Eczane: \(pharmacyService.pharmacies.count)")
                    Text("İlaçlı Eczane: \(pharmacyService.pharmacies.filter { !$0.availableMedications.isEmpty }.count)")
                    Text("Aktif Eczane: \(pharmacyService.pharmacies.filter { $0.isActive }.count)")
                    Text("Nöbetçi Eczane: \(pharmacyService.pharmacies.filter { $0.isOnDuty }.count)")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                if !pharmacyService.pharmacies.isEmpty {
                    List(pharmacyService.pharmacies.prefix(5), id: \.id) { pharmacy in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pharmacy.name)
                                .font(.headline)
                            Text(pharmacy.fullAddress)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("İlaç: \(pharmacy.availableMedications.count)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 2)
                    }
                    .frame(maxHeight: 200)
                }
                
                VStack(spacing: 10) {
                    Button("🔄 Tüm Eczaneleri Getir") {
                        pharmacyService.fetchAllPharmacies()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("📍 Yakın Eczaneleri Getir") {
                        // Elazığ merkez koordinatları
                        pharmacyService.fetchNearbyPharmacies(
                            latitude: 38.6748,
                            longitude: 39.2225,
                            radius: 5000
                        )
                    }
                    .buttonStyle(.bordered)
                    
                    Button("🏙️ Elazığ Eczaneleri") {
                        pharmacyService.fetchPharmacies(city: "Elazığ")
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("API Test")
            .onAppear {
                pharmacyService.fetchAllPharmacies()
            }
        }
    }
}

#Preview {
    NetworkTestView()
} 