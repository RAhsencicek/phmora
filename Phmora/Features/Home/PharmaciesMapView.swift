import SwiftUI
import MapKit

// MARK: - Pharmacies Map View
/// Interactive map displaying pharmacy locations with annotations
struct PharmaciesMapView: View {
    // MARK: - Properties
    let pharmacies: [Pharmacy]
    @Binding var selectedPharmacy: Pharmacy?
    @Binding var showPharmacyDetails: Bool
    @Binding var showAddMedicationSheet: Bool
    @Binding var region: MKCoordinateRegion
    
    // MARK: - State
    @State private var selectedAnnotation: Pharmacy?
    @State private var showingPulse = false
    
    // MARK: - Body
    var body: some View {
        Map(coordinateRegion: $region,
            showsUserLocation: true,
            userTrackingMode: .constant(.none),
            annotationItems: pharmacies) { pharmacy in
            MapAnnotation(coordinate: pharmacy.coordinate) {
                PharmacyAnnotationView(
                    pharmacy: pharmacy,
                    isSelected: selectedAnnotation == pharmacy,
                    onTap: {
                        handlePharmacySelection(pharmacy)
                    }
                )
            }
        }
        .mapStyle(.standard)
        .mapControls {
            MapCompass()
            MapUserLocationButton()
            MapScaleView()
        }
    }
    
    // MARK: - Private Methods
    private func handlePharmacySelection(_ pharmacy: Pharmacy) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedPharmacy = pharmacy
            selectedAnnotation = pharmacy
            showPharmacyDetails = true
        }
    }
}

// MARK: - Pharmacy Annotation View
/// Individual pharmacy annotation displayed on the map
private struct PharmacyAnnotationView: View {
    // MARK: - Properties
    let pharmacy: Pharmacy
    let isSelected: Bool
    let onTap: () -> Void
    
    // MARK: - State
    @State private var showingPulse = false
    
    // MARK: - Body
    var body: some View {
        Button(action: onTap) {
            VStack {
                ZStack {
                    // Background circle
                    Circle()
                        .fill(.white)
                        .frame(width: 44, height: 44)
                        .shadow(radius: 2)
                    
                    // Pharmacy icon
                    Image(systemName: "cross.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color(red: 0.4, green: 0.6, blue: 0.4))
                    
                    // Selection animation ring
                    if isSelected {
                        Circle()
                            .stroke(Color(red: 0.4, green: 0.6, blue: 0.4), lineWidth: 2)
                            .frame(width: 50, height: 50)
                            .scaleEffect(showingPulse ? 1.3 : 1.0)
                            .opacity(showingPulse ? 0 : 1)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: false), value: showingPulse)
                            .onAppear {
                                showingPulse = true
                            }
                    }
                }
                
                // Medication count indicator
                if pharmacy.availableMedications.contains(where: { $0.status == .forSale }) {
                    Text("\(pharmacy.availableMedications.filter { $0.status == .forSale }.count)")
                        .font(.caption)
                        .padding(6)
                        .background(Color(red: 0.85, green: 0.6, blue: 0.3))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .offset(y: -5)
                }
                
                // Pharmacy name
                Text(pharmacy.name)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .padding(4)
                    .background(.regularMaterial)
                    .cornerRadius(4)
                    .shadow(radius: 1)
            }
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
}

// MARK: - Preview
#Preview {
    PharmaciesMapView(
        pharmacies: [],
        selectedPharmacy: .constant(nil),
        showPharmacyDetails: .constant(false),
        showAddMedicationSheet: .constant(false),
        region: .constant(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 38.6748, longitude: 39.2225),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    )
} 