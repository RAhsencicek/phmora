import SwiftUI
import Foundation

// MARK: - Pharmacy Medications View
/// List view displaying medications with tap handling
struct PharmacyMedicationsView: View {
    // MARK: - Properties
    let medications: [Medication]
    var onMedicationTapped: (Medication) -> Void
    
    // MARK: - Body
    var body: some View {
        if medications.isEmpty {
            emptyStateView
        } else {
            medicationListView
        }
    }
    
    // MARK: - View Components
    private var emptyStateView: some View {
        Text("İlaç bulunmuyor.")
            .foregroundColor(.gray)
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var medicationListView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 15) {
                ForEach(medications) { medication in
                    MedicationRowView(
                        medication: medication,
                        onTap: { onMedicationTapped(medication) }
                    )
                }
            }
            .padding(.horizontal, 5)
        }
    }
}

// MARK: - Medication Row View
/// Individual row view for medication display
private struct MedicationRowView: View {
    // MARK: - Properties
    let medication: Medication
    let onTap: () -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 5) {
                // Header with name and status
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
                
                // Description
                Text(medication.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Expiry date if available
                if let expiryDate = medication.expiryDate {
                    Text("SKT: \(expiryDateFormatter.string(from: expiryDate))")
                        .font(.caption)
                        .foregroundColor(isExpiryClose(date: expiryDate) ? .red : .gray)
                }
                
                // Price and stock
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
    
    // MARK: - Helper Properties
    private var expiryDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    // MARK: - Helper Methods
    private func isExpiryClose(date: Date) -> Bool {
        let threeMonthsFromNow = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
        return date < threeMonthsFromNow
    }
}

// MARK: - Preview
#Preview {
    PharmacyMedicationsView(
        medications: [
            Medication(
                name: "Parol",
                description: "Ağrı kesici",
                price: 25.90,
                quantity: 10,
                expiryDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()),
                imageURL: nil,
                status: .forSale
            ),
            Medication(
                name: "Aspirin",
                description: "Ağrı kesici",
                price: 18.75,
                quantity: 20,
                expiryDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()),
                imageURL: nil,
                status: .available
            )
        ]
    ) { medication in
        print("Tapped: \(medication.name)")
    }
    .padding()
} 