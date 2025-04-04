import SwiftUI
import MapKit

struct Pharmacy: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let phone: String
    let coordinate: CLLocationCoordinate2D
    var availableMedications: [Medication]
}

struct Medication: Identifiable {
    var id = UUID()
    let name: String
    let description: String
    let price: Double
    let quantity: Int
    let expiryDate: Date?
    let imageURL: String?
    let status: MedicationStatus
    
    init(name: String, description: String, price: Double, quantity: Int, expiryDate: Date?, imageURL: String?, status: MedicationStatus) {
        self.name = name
        self.description = description
        self.price = price
        self.quantity = quantity
        self.expiryDate = expiryDate
        self.imageURL = imageURL
        self.status = status
    }
}

enum MedicationStatus: String, CaseIterable {
    case available = "Mevcut"
    case forSale = "Satılık"
    case reserved = "Rezerve"
}

struct HomeView: View {
    @State private var pharmacies: [Pharmacy] = [
        Pharmacy(
            name: "Merkez Eczanesi",
            address: "İstiklal Cad. No:123, Beyoğlu",
            phone: "0212 123 4567",
            coordinate: CLLocationCoordinate2D(latitude: 41.0112, longitude: 28.9762),
            availableMedications: [
                Medication(name: "Parol", description: "Ağrı kesici", price: 25.90, quantity: 10, expiryDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()), imageURL: nil, status: .available),
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
    @State private var showAddMedicationSheet = false
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
        .sheet(isPresented: $showAddMedicationSheet) {
            AddMedicationView(onSave: { newMedication in
                if currentUserPharmacyIndex < pharmacies.count {
                    pharmacies[currentUserPharmacyIndex].availableMedications.append(newMedication)
                }
                showAddMedicationSheet = false
            })
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .navigationTitle("Eczaneler")
    }
}

struct AddMedicationView: View {
    @State private var name = ""
    @State private var description = ""
    @State private var price = ""
    @State private var quantity = ""
    @State private var expiryDate = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    @State private var selectedStatus: MedicationStatus = .forSale
    @State private var showImagePicker = false
    @State private var image: Image?
    
    var onSave: (Medication) -> Void
    
    var isFormValid: Bool {
        !name.isEmpty && !price.isEmpty && !quantity.isEmpty && Double(price) != nil && Int(quantity) != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("İlaç Bilgileri")) {
                    TextField("İlaç Adı", text: $name)
                    TextField("Açıklama", text: $description)
                    TextField("Fiyat (TL)", text: $price)
                    TextField("Miktar", text: $quantity)
                }
                
                Section(header: Text("Son Kullanma Tarihi")) {
                    DatePicker("Tarih", selection: $expiryDate, displayedComponents: .date)
                }
                
                Section(header: Text("Durum")) {
                    Picker("Durum", selection: $selectedStatus) {
                        ForEach(MedicationStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Görsel")) {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        HStack {
                            Text("Görsel Ekle")
                            Spacer()
                            if image != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "photo")
                                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                            }
                        }
                    }
                }
            }
            .navigationTitle("İlaç Ekle")
            .navigationBarItems(
                leading: Button("İptal") {
                    // İptal işlemi
                },
                trailing: Button("Kaydet") {
                    let newMedication = Medication(
                        name: name,
                        description: description,
                        price: Double(price) ?? 0.0,
                        quantity: Int(quantity) ?? 0,
                        expiryDate: expiryDate,
                        imageURL: nil,
                        status: selectedStatus
                    )
                    onSave(newMedication)
                }
                .disabled(!isFormValid)
            )
        }
    }
}

struct PharmacyDetailView: View {
    let pharmacy: Pharmacy
    @State private var selectedTab = 0
    
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
                PharmacyMedicationsView(medications: pharmacy.availableMedications)
            } else {
                PharmacyMedicationsView(medications: pharmacy.availableMedications.filter { $0.status == .forSale })
            }
            
            Spacer()
        }
        .padding()
        .background(Color(red: 0.95, green: 0.97, blue: 0.95))
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

struct PharmacyMedicationsView: View {
    let medications: [Medication]
    
    var body: some View {
        if medications.isEmpty {
            Text("Satılık ilaç bulunmuyor.")
                .foregroundColor(.gray)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 15) {
                    ForEach(medications) { medication in
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
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
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

#Preview {
    NavigationView {
        HomeView()
    }
} 