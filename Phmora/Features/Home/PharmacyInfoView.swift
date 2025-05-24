import SwiftUI
import CoreLocation

// MARK: - Pharmacy Info View
/// Display basic information about a pharmacy (hours, duty status, rating)
struct PharmacyInfoView: View {
    // MARK: - Properties
    let pharmacy: Pharmacy
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Opening hours
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                Text("Açık: 08:00 - 19:00")
            }
            
            // Duty status
            HStack {
                Image(systemName: "person.2")
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                Text("Nöbetçi: Hayır")
            }
            
            // Rating
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                Text("Değerlendirme: 4.7")
            }
        }
        .padding(.top, 5)
    }
}

// MARK: - Preview
#Preview {
    PharmacyInfoView(
        pharmacy: Pharmacy(
            name: "Örnek Eczane",
            address: "Örnek Adres",
            phone: "0424 000 0000",
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            availableMedications: []
        )
    )
    .padding()
} 