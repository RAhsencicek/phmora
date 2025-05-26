import SwiftUI
import MapKit

struct SearchView: View {
    @State private var searchText = ""
    @State private var medications: [Medication] = []
    @State private var isSearching = false
    @State private var selectedMedication: Medication? = nil
    @State private var showMedicationDetail = false
    @State private var searchFieldFocused = false
    
    // Örnek veriler (gerçek uygulamada bir veritabanından gelecek)
    let samplePharmacies: [Pharmacy] = [
        Pharmacy(
            name: "Merkez Eczanesi",
            address: "İstiklal Cad. No:123, Beyoğlu",
            phone: "0212 123 4567",
            coordinate: CLLocationCoordinate2D(latitude: 41.0112, longitude: 28.9762),
            availableMedications: [
                Medication(name: "Parol", description: "Ağrı kesici", price: 25.90, quantity: 10, expiryDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()), imageURL: nil, status: .forSale),
                Medication(name: "Majezik", description: "Ağrı kesici", price: 32.50, quantity: 15, expiryDate: Calendar.current.date(byAdding: .month, value: 8, to: Date()), imageURL: nil, status: .forSale)
            ]
        ),
        Pharmacy(
            name: "Hayat Eczanesi",
            address: "Bağdat Cad. No:45, Kadıköy",
            phone: "0216 987 6543",
            coordinate: CLLocationCoordinate2D(latitude: 41.0052, longitude: 28.9804),
            availableMedications: [
                Medication(name: "Aspirin", description: "Ağrı kesici", price: 18.75, quantity: 20, expiryDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()), imageURL: nil, status: .forSale),
                Medication(name: "B12 Vitamini", description: "Vitamin takviyesi", price: 45.90, quantity: 8, expiryDate: Calendar.current.date(byAdding: .month, value: 12, to: Date()), imageURL: nil, status: .available)
            ]
        )
    ]
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 0.98),
                    Color.blue.opacity(0.05)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Modern Search Header
                VStack(spacing: 16) {
                    // Search Bar
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        
                        TextField("İlaç adı veya etken madde ara...", text: $searchText)
                            .font(.system(size: 16, weight: .medium))
                            .onChange(of: searchText) { newValue in
                                searchMedications()
                            }
                            .onTapGesture {
                                searchFieldFocused = true
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                withAnimation(.spring()) {
                                    searchText = ""
                                    medications = []
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(width: 32, height: 32)
                                    
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    )
                    .scaleEffect(searchFieldFocused ? 1.02 : 1.0)
                    .animation(.spring(response: 0.3), value: searchFieldFocused)
                    
                    // Search Stats
                    if !medications.isEmpty {
                        HStack {
                            Text("\(medications.count) sonuç bulundu")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("En uygun fiyatlar")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                // Content Area
                if isSearching {
                    // Modern Loading State
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                                .frame(width: 60, height: 60)
                            
                            Circle()
                                .trim(from: 0, to: 0.7)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.blue, Color.green],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                )
                                .frame(width: 60, height: 60)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isSearching)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Aranıyor...")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("İlaçlar taranıyor")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else if medications.isEmpty && !searchText.isEmpty {
                    // Empty State
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(.orange)
                        }
                        
                        VStack(spacing: 12) {
                            Text("İlaç Bulunamadı")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Aradığınız ilaç mevcut değil.\nFarklı bir arama deneyin.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else if searchText.isEmpty {
                    // Initial State
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "pills.fill")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(spacing: 12) {
                            Text("İlaç Arama")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Aradığınız ilacın adını veya\netken maddesini yazın")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else {
                    // Results List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(medications) { medication in
                                MedicationCard(
                                    medication: medication,
                                    onTap: {
                                        selectedMedication = medication
                                        showMedicationDetail = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationTitle("İlaç Arama")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showMedicationDetail) {
            if let medication = selectedMedication, 
               let pharmacy = findPharmacyForMedication(medication) {
                MedicationDetailView(medication: medication, pharmacy: pharmacy)
            }
        }
    }
    
    private func searchMedications() {
        guard !searchText.isEmpty else {
            medications = []
            return
        }
        
        isSearching = true
        
        // Gerçek uygulamada API çağrısı yapılır
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [self] in
            withAnimation(.spring()) {
                var allMedications: [Medication] = []
                
                for pharmacy in self.samplePharmacies {
                    allMedications.append(contentsOf: pharmacy.availableMedications)
                }
                
                self.medications = allMedications.filter { medication in
                    medication.name.lowercased().contains(self.searchText.lowercased()) ||
                    medication.description.lowercased().contains(self.searchText.lowercased())
                }
                self.isSearching = false
            }
        }
    }
    
    private func findPharmacyForMedication(_ medication: Medication) -> Pharmacy? {
        for pharmacy in samplePharmacies {
            if pharmacy.availableMedications.contains(where: { $0.id == medication.id }) {
                return pharmacy
            }
        }
        return samplePharmacies.first
    }
}

// MARK: - Medication Card Component
struct MedicationCard: View {
    let medication: Medication
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Medication Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(statusColor(medication.status).opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "pills.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(statusColor(medication.status))
                }
                
                // Medication Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(medication.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(medication.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 8) {
                        Text(medication.status.displayName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusColor(medication.status))
                            .cornerRadius(8)
                        
                        Text("Stok: \(medication.quantity)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Price and Arrow
                VStack(alignment: .trailing, spacing: 8) {
                    Text("₺\(String(format: "%.2f", medication.price))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func statusColor(_ status: MedicationStatus) -> Color {
        switch status {
        case .available:
            return Color.blue
        case .forSale:
            return Color.green
        case .outOfStock:
            return Color.red
        case .reserved:
            return Color.purple
        case .sold:
            return Color.gray
        }
    }
}

#Preview {
    NavigationView {
        SearchView()
    }
} 