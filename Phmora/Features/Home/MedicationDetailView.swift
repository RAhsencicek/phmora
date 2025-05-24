import SwiftUI
import MapKit

// MARK: - Medication Detail View
/// Detailed view for medication information with purchase and offer actions
struct MedicationDetailView: View {
    // MARK: - Properties
    let medication: Medication
    let pharmacy: Pharmacy
    
    // MARK: - State
    @State private var showPurchaseSheet = false
    @State private var showOfferSheet = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Medication Image
                    medicationImageView
                    
                    // Medication Information
                    medicationInfoCard
                    
                    // Pharmacy Information
                    pharmacyInfoCard
                    
                    // Action Buttons
                    if medication.status == .forSale {
                        actionButtonsView
                    }
                }
                .padding()
            }
            .navigationTitle("İlaç Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPurchaseSheet) {
                PurchaseView(medication: medication) {
                    showPurchaseSheet = false
                }
            }
            .sheet(isPresented: $showOfferSheet) {
                OfferView(medication: medication) {
                    showOfferSheet = false
                }
            }
        }
    }
    
    // MARK: - View Components
    private var medicationImageView: some View {
        Group {
            if let _ = medication.imageURL {
                Image(systemName: "pills.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial)
                    .cornerRadius(10)
            } else {
                Image(systemName: "pills.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(10)
            }
        }
    }
    
    private var medicationInfoCard: some View {
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
        .background(.regularMaterial)
        .cornerRadius(10)
    }
    
    private var pharmacyInfoCard: some View {
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
        .background(.regularMaterial)
        .cornerRadius(10)
    }
    
    private var actionButtonsView: some View {
        HStack {
            Button(action: {
                showPurchaseSheet = true
            }) {
                Label("Satın Al", systemImage: "cart")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.4, green: 0.6, blue: 0.4))
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
                    .foregroundColor(Color(red: 0.4, green: 0.6, blue: 0.4))
                    .cornerRadius(10)
            }
        }
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
            return Color(red: 0.85, green: 0.5, blue: 0.2)
        case .reserved:
            return Color.purple
        case .sold:
            return Color.gray
        }
    }
}

// MARK: - Preview
#Preview {
    MedicationDetailView(
        medication: Medication(
            name: "Örnek İlaç",
            description: "Ağrı kesici",
            price: 25.90,
            quantity: 10,
            expiryDate: Date(),
            imageURL: nil,
            status: .forSale
        ),
        pharmacy: Pharmacy(
            name: "Örnek Eczane",
            address: "Örnek Adres",
            phone: "0424 000 0000",
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            availableMedications: []
        )
    )
} 