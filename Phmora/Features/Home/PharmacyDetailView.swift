import SwiftUI
import MapKit

// MARK: - Pharmacy Detail View
/// Detailed view for a selected pharmacy showing tabs for info, medications, and for-sale items
struct PharmacyDetailView: View {
    // MARK: - Properties
    let pharmacy: Pharmacy
    
    // MARK: - State
    @State private var selectedTab = 0
    @State private var showOfferSheet = false
    @State private var selectedMedication: Medication? = nil
    @StateObject private var authService = AuthService.shared
    
    // MARK: - Computed Properties
    private var isOwnPharmacy: Bool {
        guard let currentUserPharmacistId = authService.currentUserPharmacistId else {
            return false
        }
        return pharmacy.owner?.pharmacistId == currentUserPharmacistId
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header - sadece kendi eczanesi değilse göster
            if !isOwnPharmacy {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pharmacy.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.3))
                            
                            Text(pharmacy.fullAddress)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(pharmacy.phone)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Eczane durumu
                        VStack(spacing: 4) {
                            Circle()
                                .fill(pharmacy.isOnDuty ? .green : .orange)
                                .frame(width: 12, height: 12)
                            
                            Text(pharmacy.isOnDuty ? "Nöbetçi" : "Kapalı")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Rating ve hizmetler
                    HStack {
                        if let rating = pharmacy.rating {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                Text("\(rating.average, specifier: "%.1f")")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text("(\(rating.count))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if let services = pharmacy.services, !services.isEmpty {
                            HStack(spacing: 4) {
                                ForEach(services.prefix(2), id: \.self) { service in
                                    Text(service)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(4)
                                }
                                if services.count > 2 {
                                    Text("+\(services.count - 2)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                
                Divider()
            } else {
                // Kendi eczanesi için özel header
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "house.circle.fill")
                            .font(.title)
                            .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.8))
                        
                        VStack(alignment: .leading) {
                            Text("Eczanem")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.8))
                            
                            Text(pharmacy.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Hızlı istatistikler
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(pharmacy.availableMedications.count)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("Toplam İlaç")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Hızlı durum kartları
                    HStack(spacing: 12) {
                        QuickStatCard(
                            title: "Satışta",
                            value: "\(pharmacy.availableMedications.filter { $0.status == .forSale }.count)",
                            color: .green,
                            icon: "cart.fill"
                        )
                        
                        QuickStatCard(
                            title: "Düşük Stok",
                            value: "\(pharmacy.availableMedications.filter { $0.quantity <= 5 && $0.status != .outOfStock }.count)",
                            color: .orange,
                            icon: "exclamationmark.triangle.fill"
                        )
                        
                        QuickStatCard(
                            title: "Stokta Yok",
                            value: "\(pharmacy.availableMedications.filter { $0.status == .outOfStock }.count)",
                            color: .red,
                            icon: "xmark.circle.fill"
                        )
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.4, blue: 0.8).opacity(0.1),
                            Color(red: 0.2, green: 0.4, blue: 0.8).opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                Divider()
            }
            
            // Tab Selection - kendi eczanesi ise farklı sekmeler
            if isOwnPharmacy {
                Picker("Bilgi Türü", selection: $selectedTab) {
                    Text("Tüm İlaçlar").tag(0)
                    Text("Satışta").tag(1)
                    Text("Stok Yönetimi").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color(UIColor.systemBackground))
            } else {
                Picker("Bilgi Türü", selection: $selectedTab) {
                    Text("Bilgiler").tag(0)
                    Text("İlaçlar").tag(1)
                    Text("Satılık İlaçlar").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color(UIColor.systemBackground))
            }
            
            // Tab Content
            if isOwnPharmacy {
                // Kendi eczanesi için sekmeler
                if selectedTab == 0 {
                    // Tüm ilaçlar
                    OwnPharmacyMedicationsView(medications: pharmacy.availableMedications) { medication in
                        selectedMedication = medication
                        showOfferSheet = true
                    }
                } else if selectedTab == 1 {
                    // Satışta olan ilaçlar
                    OwnPharmacyMedicationsView(medications: pharmacy.availableMedications.filter { $0.status == .forSale }) { medication in
                        selectedMedication = medication
                        showOfferSheet = true
                    }
                } else if selectedTab == 2 {
                    // Stok yönetimi
                    StockManagementView(medications: pharmacy.availableMedications)
                }
            } else {
                // Diğer eczaneler için sekmeler
                if selectedTab == 0 {
                    PharmacyInfoView(pharmacy: pharmacy)
                } else if selectedTab == 1 {
                    PharmacyMedicationsView(medications: pharmacy.availableMedications) { medication in
                        selectedMedication = medication
                        showOfferSheet = true
                    }
                } else if selectedTab == 2 {
                    PharmacyMedicationsView(medications: pharmacy.availableMedications.filter { $0.status == .forSale }) { medication in
                        selectedMedication = medication
                        showOfferSheet = true
                    }
                }
            }
            
            Spacer()
        }
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
        .sheet(isPresented: $showOfferSheet) {
            if let medication = selectedMedication {
                if isOwnPharmacy {
                    // Kendi eczanesi için özel detay görünümü (satın alma/teklif verme olmadan)
                    OwnMedicationDetailView(medication: medication, pharmacy: pharmacy)
                } else {
                    // Diğer eczaneler için normal detay görünümü
                    MedicationDetailView(medication: medication, pharmacy: pharmacy)
                }
            }
        }
    }
}

// MARK: - Quick Stat Card
/// Hızlı istatistik kartı
private struct QuickStatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Own Pharmacy Medications View
/// Kendi eczanesi için ilaç listesi - tüm durumları gösterir
private struct OwnPharmacyMedicationsView: View {
    let medications: [Medication]
    let onMedicationTap: (Medication) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if medications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "pills")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("Henüz ilaç bulunmuyor")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("İlaç eklemek için + butonunu kullanın")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    ForEach(medications, id: \.id) { medication in
                        OwnMedicationRowView(medication: medication) {
                            onMedicationTap(medication)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Own Medication Row View
/// Kendi eczanesi için ilaç satırı - durum bilgisi ile
private struct OwnMedicationRowView: View {
    let medication: Medication
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(medication.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Text(medication.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    // Durum etiketi
                    Text(medication.status.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor(for: medication.status))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                
                Divider()
                
                HStack {
                    // Fiyat
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Fiyat")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("₺\(medication.price, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Stok
                    VStack(alignment: .center, spacing: 2) {
                        Text("Stok")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(medication.quantity)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(medication.quantity <= 5 ? .orange : .primary)
                    }
                    
                    Spacer()
                    
                    // Son kullanma tarihi
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Son Kullanma")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        if let expiryDate = medication.expiryDate {
                            let isExpiringSoon = expiryDate.timeIntervalSinceNow < 30 * 24 * 60 * 60 // 30 gün
                            Text(expiryDate, style: .date)
                                .font(.caption)
                                .foregroundColor(isExpiringSoon ? .red : .secondary)
                        } else {
                            Text("Belirtilmemiş")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func statusColor(for status: MedicationStatus) -> Color {
        switch status {
        case .available:
            return .blue
        case .forSale:
            return .green
        case .outOfStock:
            return .red
        case .reserved:
            return .orange
        case .sold:
            return .gray
        }
    }
}

// MARK: - Own Medication Detail View
/// Kendi eczanesi için ilaç detay görünümü (satın alma/teklif verme olmadan)
private struct OwnMedicationDetailView: View {
    let medication: Medication
    let pharmacy: Pharmacy
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // İlaç başlığı
                    VStack(alignment: .leading, spacing: 8) {
                        Text(medication.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(medication.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // İlaç bilgileri
                    VStack(spacing: 16) {
                        InfoRow(title: "Fiyat", value: String(format: "₺%.2f", medication.price), color: .primary)
                        InfoRow(title: "Stok Miktarı", value: "\(medication.quantity)", color: medication.quantity <= 5 ? .orange : .primary)
                        InfoRow(title: "Durum", value: medication.status.displayName, color: statusColor(for: medication.status))
                        
                        if let expiryDate = medication.expiryDate {
                            let isExpiringSoon = expiryDate.timeIntervalSinceNow < 30 * 24 * 60 * 60
                            InfoRow(title: "Son Kullanma Tarihi", value: expiryDate.formatted(date: .abbreviated, time: .omitted), color: isExpiringSoon ? .red : .primary)
                        }
                    }
                    
                    Divider()
                    
                    // Yönetim butonları
                    VStack(spacing: 12) {
                        Button(action: {
                            // Stok güncelleme işlemi
                        }) {
                            HStack {
                                Image(systemName: "square.and.pencil")
                                Text("Stok Güncelle")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            // Fiyat güncelleme işlemi
                        }) {
                            HStack {
                                Image(systemName: "dollarsign.circle")
                                Text("Fiyat Güncelle")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            // Durum değiştirme işlemi
                        }) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Durum Değiştir")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("İlaç Detayları")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Kapat") { dismiss() })
        }
    }
    
    private func statusColor(for status: MedicationStatus) -> Color {
        switch status {
        case .available: return .blue
        case .forSale: return .green
        case .outOfStock: return .red
        case .reserved: return .orange
        case .sold: return .gray
        }
    }
}

// MARK: - Info Row
private struct InfoRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Stock Management View
/// Stok yönetimi görünümü - sadece kendi eczanesi için
private struct StockManagementView: View {
    let medications: [Medication]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Stok özeti
                StockSummaryView(medications: medications)
                
                Divider()
                
                // Düşük stok uyarıları
                LowStockWarningsView(medications: medications)
                
                Divider()
                
                // Son kullanma tarihi uyarıları
                ExpiryWarningsView(medications: medications)
            }
            .padding()
        }
    }
}

// MARK: - Stock Summary View
private struct StockSummaryView: View {
    let medications: [Medication]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stok Özeti")
                .font(.title3)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StockStatCard(
                    title: "Toplam İlaç",
                    value: "\(medications.count)",
                    color: .blue,
                    icon: "pills.fill"
                )
                
                StockStatCard(
                    title: "Satışta",
                    value: "\(medications.filter { $0.status == .forSale }.count)",
                    color: .green,
                    icon: "cart.fill"
                )
                
                StockStatCard(
                    title: "Stokta Yok",
                    value: "\(medications.filter { $0.status == .outOfStock }.count)",
                    color: .red,
                    icon: "xmark.circle.fill"
                )
                
                StockStatCard(
                    title: "Düşük Stok",
                    value: "\(medications.filter { $0.quantity <= 5 && $0.status != .outOfStock }.count)",
                    color: .orange,
                    icon: "exclamationmark.triangle.fill"
                )
            }
        }
    }
}

// MARK: - Stock Stat Card
private struct StockStatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Low Stock Warnings View
private struct LowStockWarningsView: View {
    let medications: [Medication]
    
    private var lowStockMedications: [Medication] {
        medications.filter { $0.quantity <= 5 && $0.status != .outOfStock }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Düşük Stok Uyarıları")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            if lowStockMedications.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Düşük stoklu ilaç bulunmuyor.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            } else {
                VStack(spacing: 8) {
                    ForEach(lowStockMedications, id: \.id) { medication in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(medication.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("Kalan: \(medication.quantity)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Stok ekleme işlemi
                            }) {
                                Text("Stok Ekle")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
}

// MARK: - Expiry Warnings View
private struct ExpiryWarningsView: View {
    let medications: [Medication]
    
    private var expiringMedications: [Medication] {
        let thirtyDaysFromNow = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        return medications.filter { medication in
            guard let expiryDate = medication.expiryDate else { return false }
            return expiryDate <= thirtyDaysFromNow
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.exclamationmark")
                    .foregroundColor(.red)
                Text("Son Kullanma Tarihi Uyarıları")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            if expiringMedications.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("30 gün içinde son kullanma tarihi dolacak ilaç bulunmuyor.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            } else {
                VStack(spacing: 8) {
                    ForEach(expiringMedications, id: \.id) { medication in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(medication.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                if let expiryDate = medication.expiryDate {
                                    Text("Son kullanma: \(expiryDate, style: .date)")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // İndirim uygulama işlemi
                            }) {
                                Text("İndirim Uygula")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    PharmacyDetailView(
        pharmacy: Pharmacy(
            name: "Örnek Eczane",
            address: "Örnek Adres",
            phone: "0424 000 0000",
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            availableMedications: []
        )
    )
} 