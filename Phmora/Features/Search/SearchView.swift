import SwiftUI
import MapKit

struct SearchView: View {
    @State private var searchText = ""
    @State private var medications: [Medication] = []
    @State private var isSearching = false
    @State private var selectedMedication: Medication? = nil
    @State private var showMedicationDetail = false
    
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
        VStack {
            // Arama çubuğu
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("İlaç ara...", text: $searchText)
                    .onChange(of: searchText) { newValue in
                        searchMedications()
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        medications = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
            if isSearching {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding()
            } else if medications.isEmpty && !searchText.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Aradığınız ilaç bulunamadı")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(medications) { medication in
                        Button(action: {
                            selectedMedication = medication
                            showMedicationDetail = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(medication.name)
                                        .font(.headline)
                                    Text(medication.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(String(format: "%.2f", medication.price)) TL")
                                        .font(.subheadline)
                                        .bold()
                                    
                                    Text(medication.status.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(statusColor(medication.status))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .navigationTitle("İlaç Ara")
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Örnek arama sonuçları
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
    
    private func findPharmacyForMedication(_ medication: Medication) -> Pharmacy? {
        for pharmacy in samplePharmacies {
            if pharmacy.availableMedications.contains(where: { $0.id == medication.id }) {
                return pharmacy
            }
        }
        return samplePharmacies.first
    }
    
    private func statusColor(_ status: MedicationStatus) -> Color {
        switch status {
        case .available:
            return Color.blue
        case .forSale:
            return Color(red: 0.85, green: 0.5, blue: 0.2)
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