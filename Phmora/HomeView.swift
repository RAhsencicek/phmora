import SwiftUI
import MapKit

struct HomeView: View {
    @Binding var showAddMedicationSheet: Bool
    
    @State private var pharmacies: [Pharmacy] = [
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
        ),
        Pharmacy(
            name: "Güneş Eczanesi",
            address: "Moda Cad. No:78, Kadıköy",
            phone: "0216 345 6789",
            coordinate: CLLocationCoordinate2D(latitude: 41.0102, longitude: 28.9704),
            availableMedications: [
                Medication(name: "Augmentin", description: "Antibiyotik", price: 65.30, quantity: 5, expiryDate: Calendar.current.date(byAdding: .month, value: 2, to: Date()), imageURL: nil, status: .forSale),
                Medication(name: "Zinc", description: "Mineral takviyesi", price: 38.25, quantity: 12, expiryDate: Calendar.current.date(byAdding: .month, value: 10, to: Date()), imageURL: nil, status: .available)
            ]
        )
    ]
    
    @State private var selectedPharmacy: Pharmacy? = nil
    @State private var showPharmacyDetails = false
    @State private var currentUserPharmacyIndex = 0 // Kullanıcının kendi eczanesinin indeksi
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )), annotationItems: pharmacies) { pharmacy in
                MapAnnotation(coordinate: pharmacy.coordinate) {
                    Button(action: {
                        selectedPharmacy = pharmacy
                        showPharmacyDetails = true
                    }) {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 40, height: 40)
                                    .shadow(radius: 2)
                                
                                Image(systemName: "cross.fill")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                            }
                            
                            if pharmacy.availableMedications.contains(where: { $0.status == .forSale }) {
                                Text("\(pharmacy.availableMedications.filter { $0.status == .forSale }.count)")
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color(red: 0.85, green: 0.5, blue: 0.2))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .offset(y: -5)
                            }
                        }
                    }
                }
            }
            
            // İlaç Ekle butonu
            Button(action: {
                showAddMedicationSheet = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("İlaç Ekle")
                }
                .padding()
                .background(Color(red: 0.4, green: 0.5, blue: 0.4))
                .foregroundColor(.white)
                .cornerRadius(25)
                .shadow(radius: 3)
            }
            .padding()
        }
        .sheet(isPresented: $showPharmacyDetails, onDismiss: {
            selectedPharmacy = nil
        }) {
            if let pharmacy = selectedPharmacy {
                PharmacyDetailView(pharmacy: pharmacy)
                    .presentationDetents([.height(200), .medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .navigationTitle("Eczaneler")
    }
}

struct PharmacyDetailView: View {
    let pharmacy: Pharmacy
    @State private var selectedTab = 0
    @State private var showOfferSheet = false
    @State private var selectedMedication: Medication? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(pharmacy.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.3))
            
            Text(pharmacy.address)
                .font(.subheadline)
            
            Text(pharmacy.phone)
                .font(.subheadline)
            
            Divider()
            
            Picker("Bilgi Türü", selection: $selectedTab) {
                Text("Bilgiler").tag(0)
                Text("İlaçlar").tag(1)
                Text("Satılık İlaçlar").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 5)
            
            if selectedTab == 0 {
                PharmacyInfoView(pharmacy: pharmacy)
            } else if selectedTab == 1 {
                PharmacyMedicationsView(medications: pharmacy.availableMedications) { medication in
                    selectedMedication = medication
                    showOfferSheet = true
                }
            } else {
                PharmacyMedicationsView(medications: pharmacy.availableMedications.filter { $0.status == .forSale }) { medication in
                    selectedMedication = medication
                    showOfferSheet = true
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(red: 0.95, green: 0.97, blue: 0.95))
        .sheet(isPresented: $showOfferSheet) {
            if let medication = selectedMedication {
                MedicationDetailView(medication: medication, pharmacy: pharmacy)
            }
        }
    }
}

struct MedicationDetailView: View {
    let medication: Medication
    let pharmacy: Pharmacy
    @State private var showPurchaseSheet = false
    @State private var showOfferSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // İlaç görseli
                    if let _ = medication.imageURL {
                        Image(systemName: "pills.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.95, green: 0.97, blue: 0.95))
                            .cornerRadius(10)
                    } else {
                        Image(systemName: "pills.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                            .padding()
                            .background(Color(red: 0.95, green: 0.97, blue: 0.95))
                            .cornerRadius(10)
                    }
                    
                    // İlaç bilgileri
                    VStack(alignment: .leading, spacing: 10) {
                        Text(medication.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(medication.description)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Label("Fiyat:", systemImage: "tag")
                                .foregroundColor(.gray)
                            Text("\(String(format: "%.2f", medication.price)) TL")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Label("Miktar:", systemImage: "number")
                                .foregroundColor(.gray)
                            Text("\(medication.quantity)")
                                .fontWeight(.semibold)
                        }
                        
                        if let expiryDate = medication.expiryDate {
                            HStack {
                                Label("Son Kullanma:", systemImage: "calendar")
                                    .foregroundColor(.gray)
                                Text(expiryDateFormatted(expiryDate))
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        HStack {
                            Label("Durum:", systemImage: "circle.fill")
                                .foregroundColor(.gray)
                            Text(medication.status.rawValue)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 3)
                                .background(statusColor(medication.status))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    
                    // Eczane bilgileri
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Eczane Bilgileri")
                            .font(.headline)
                        
                        HStack {
                            Label(pharmacy.name, systemImage: "cross")
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Label(pharmacy.address, systemImage: "location")
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Label(pharmacy.phone, systemImage: "phone")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    
                    // Satın alma ve teklif verme butonları
                    if medication.status == .forSale {
                        HStack {
                            Button(action: {
                                showPurchaseSheet = true
                            }) {
                                Label("Satın Al", systemImage: "cart")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red: 0.4, green: 0.5, blue: 0.4))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                showOfferSheet = true
                            }) {
                                Label("Teklif Ver", systemImage: "text.badge.plus")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("İlaç Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPurchaseSheet) {
                PurchaseView(medication: medication) {
                    // Satın alma işlemi tamamlandığında yapılacaklar
                    showPurchaseSheet = false
                }
            }
            .sheet(isPresented: $showOfferSheet) {
                OfferView(medication: medication) {
                    // Teklif verme işlemi tamamlandığında yapılacaklar
                    showOfferSheet = false
                }
            }
        }
    }
    
    private func expiryDateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
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

struct PharmacyMedicationsView: View {
    let medications: [Medication]
    var onMedicationTapped: (Medication) -> Void
    
    var body: some View {
        if medications.isEmpty {
            Text("İlaç bulunmuyor.")
                .foregroundColor(.gray)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 15) {
                    ForEach(medications) { medication in
                        Button(action: {
                            onMedicationTapped(medication)
                        }) {
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text(medication.name)
                                        .font(.headline)
                                        .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.3))
                                    
                                    Spacer()
                                    
                                    if medication.status == .forSale {
                                        Text(medication.status.rawValue)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color(red: 0.85, green: 0.5, blue: 0.2))
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                }
                                
                                Text(medication.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                if let expiryDate = medication.expiryDate {
                                    Text("SKT: \(expiryDateFormatter.string(from: expiryDate))")
                                        .font(.caption)
                                        .foregroundColor(isExpiryClose(date: expiryDate) ? .red : .gray)
                                }
                                
                                HStack {
                                    Text("\(String(format: "%.2f", medication.price)) TL")
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Text("Stok: \(medication.quantity)")
                                        .font(.caption)
                                        .padding(5)
                                        .background(Color(red: 0.85, green: 0.9, blue: 0.85))
                                        .cornerRadius(5)
                                }
                            }
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 5)
            }
        }
    }
    
    private var expiryDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private func isExpiryClose(date: Date) -> Bool {
        let threeMonthsFromNow = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
        return date < threeMonthsFromNow
    }
}

struct PharmacyInfoView: View {
    let pharmacy: Pharmacy
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                Text("Açık: 08:00 - 19:00")
            }
            
            HStack {
                Image(systemName: "person.2")
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                Text("Nöbetçi: Hayır")
            }
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                Text("Değerlendirme: 4.7")
            }
        }
        .padding(.top, 5)
    }
}

#Preview {
    NavigationView {
        HomeView(showAddMedicationSheet: .constant(false))
    }
} 