import SwiftUI
import MapKit

// MARK: - Medication Detail View
/// Detailed view for medication information with purchase actions
struct MedicationDetailView: View {
    // MARK: - Properties
    let medication: Medication
    let pharmacy: Pharmacy
    
    // MARK: - State
    @State private var showPurchaseSheet = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Medication Information Card
                    medicationInfoCard
                    
                    // Pharmacy Information Card
                    pharmacyInfoCard
                    
                    // Action Button
                    if medication.status == .forSale {
                        actionButtonView
                    }
                }
                .padding()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.98, green: 0.99, blue: 1.0),
                        Color(red: 0.95, green: 0.97, blue: 0.98)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("İlaç Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPurchaseSheet) {
                PurchaseView(medication: medication) {
                    showPurchaseSheet = false
                }
            }
        }
    }
    
    // MARK: - View Components
    private var medicationInfoCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text(medication.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(medication.description)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Information Grid
            VStack(spacing: 16) {
                InfoRowView(
                    icon: "tag.fill",
                    title: "Fiyat",
                    value: "\(String(format: "%.2f", medication.price)) TL",
                    color: Color(red: 0.2, green: 0.6, blue: 0.2)
                )
                
                InfoRowView(
                    icon: "number.square.fill",
                    title: "Stok Miktarı",
                    value: "\(medication.quantity) adet",
                    color: medication.quantity <= 5 ? .orange : Color(red: 0.2, green: 0.4, blue: 0.8)
                )
                
                if let expiryDate = medication.expiryDate {
                    let isExpiringSoon = expiryDate.timeIntervalSinceNow < 30 * 24 * 60 * 60
                    InfoRowView(
                        icon: "calendar.circle.fill",
                        title: "Son Kullanma Tarihi",
                        value: expiryDateFormatted(expiryDate),
                        color: isExpiringSoon ? .red : Color(red: 0.4, green: 0.6, blue: 0.8)
                    )
                }
                
                InfoRowView(
                    icon: "circle.fill",
                    title: "Durum",
                    value: medication.status.displayName,
                    color: statusColor(medication.status)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
    
    private var pharmacyInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Eczane Bilgileri")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                InfoRowView(
                    icon: "cross.circle.fill",
                    title: "Eczane Adı",
                    value: pharmacy.name,
                    color: Color(red: 0.4, green: 0.6, blue: 0.8)
                )
                
                InfoRowView(
                    icon: "location.circle.fill",
                    title: "Adres",
                    value: pharmacy.fullAddress,
                    color: Color(red: 0.6, green: 0.4, blue: 0.8)
                )
                
                InfoRowView(
                    icon: "phone.circle.fill",
                    title: "Telefon",
                    value: pharmacy.phone,
                    color: Color(red: 0.8, green: 0.4, blue: 0.6)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
    
    private var actionButtonView: some View {
        Button(action: {
            showPurchaseSheet = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "cart.fill")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Satın Al")
                    .font(.system(size: 18, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.6, blue: 0.2),
                        Color(red: 0.3, green: 0.7, blue: 0.3)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: Color(red: 0.2, green: 0.6, blue: 0.2).opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper Methods
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
            return Color(red: 0.2, green: 0.6, blue: 0.2)
        case .outOfStock:
            return Color.red
        case .reserved:
            return Color.purple
        case .sold:
            return Color.gray
        }
    }
}

// MARK: - Info Row View
/// Bilgi satırı bileşeni
struct InfoRowView: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    MedicationDetailView(
        medication: Medication(
            name: "Parol 500mg",
            description: "Ağrı kesici ve ateş düşürücü ilaç",
            price: 25.90,
            quantity: 10,
            expiryDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()),
            imageURL: nil,
            status: .forSale
        ),
        pharmacy: Pharmacy(
            name: "Sağlık Eczanesi",
            address: "Merkez Mahallesi, Atatürk Caddesi No:15",
            phone: "0424 123 4567",
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            availableMedications: []
        )
    )
} 