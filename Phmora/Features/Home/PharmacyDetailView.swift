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
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            Text(pharmacy.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.3))
            
            Text(pharmacy.address)
                .font(.subheadline)
            
            Text(pharmacy.phone)
                .font(.subheadline)
            
            Divider()
            
            // Tab Selection
            Picker("Bilgi Türü", selection: $selectedTab) {
                Text("Bilgiler").tag(0)
                Text("İlaçlar").tag(1)
                Text("Satılık İlaçlar").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 5)
            
            // Tab Content
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