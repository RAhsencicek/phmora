import SwiftUI

struct FDADrugSearchView: View {
    @State private var searchQuery = ""
    @State private var searchResults: [Drug] = []
    @State private var selectedDrug: Drug? = nil
    @State private var showDrugDetail = false
    @State private var isSearching = false
    @State private var errorMessage: String? = nil
    
    @StateObject private var fdaService = OpenFDAService()
    
    // Colors based on the project guidelines
    private let primaryColor = Color(red: 0.4, green: 0.6, blue: 0.8)
    private let backgroundColor = Color(red: 0.95, green: 0.97, blue: 0.98)
    private let accentColor = Color(red: 0.4, green: 0.5, blue: 0.7)
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search header
                VStack(spacing: 16) {
                    Text("İlaç Bilgi Merkezi")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("FDA veritabanında ilaç araması yapın")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("İlaç adı girin...", text: $searchQuery)
                            .font(.system(size: 16))
                        
                        if !searchQuery.isEmpty {
                            Button(action: {
                                searchQuery = ""
                                searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    Button(action: performSearch) {
                        Text("Ara")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(primaryColor)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                .background(Color.white)
                
                // Results area
                if fdaService.isLoading {
                    Spacer()
                    ProgressView("Aranıyor...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                        .padding()
                    Spacer()
                } else if let error = errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else if searchResults.isEmpty && !searchQuery.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Aradığınız ilaç bulunamadı")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(searchResults) { drug in
                                DrugCardView(drug: drug)
                                    .onTapGesture {
                                        selectedDrug = drug
                                        showDrugDetail = true
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
            }
        }
        .navigationTitle("FDA İlaç Arama")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDrugDetail) {
            if let drug = selectedDrug {
                DrugDetailView(drugId: drug.id)
            }
        }
    }
    
    private func performSearch() {
        guard !searchQuery.isEmpty else { return }
        
        errorMessage = nil
        
        Task {
            do {
                let response = try await fdaService.searchDrugs(query: searchQuery)
                searchResults = response.drugs
            } catch let error as APIError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "Arama sırasında bir hata oluştu: \(error.localizedDescription)"
            }
        }
    }
}

struct DrugCardView: View {
    let drug: Drug
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(drug.brandName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(drug.genericName)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "pill.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.4, green: 0.6, blue: 0.8))
            }
            
            Divider()
            
            HStack(spacing: 16) {
                if let dosageForm = drug.dosageForm, !dosageForm.isEmpty {
                    Label {
                        Text(dosageForm)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "capsule")
                            .foregroundColor(.secondary)
                    }
                }
                
                if let route = drug.route, !route.isEmpty {
                    Label {
                        Text(route)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "arrow.down.to.line")
                            .foregroundColor(.secondary)
                    }
                }
                
                if drug.dosageForm == nil && drug.route == nil {
                    Label {
                        Text("İlaç formu belirtilmemiş")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Text(drug.manufacturerName)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .padding(.top, 4)
            
            if let description = drug.description, !description.isEmpty {
                Text(description.prefix(150) + (description.count > 150 ? "..." : ""))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct DrugDetailView: View {
    let drugId: String
    
    @StateObject private var fdaService = OpenFDAService()
    @State private var drugDetail: DrugDetail?
    @State private var errorMessage: String?
    @State private var activeTab: DetailTab = .overview
    @State private var showAdverseEvents = false
    @Environment(\.dismiss) private var dismiss
    
    enum DetailTab {
        case overview, warnings, interactions, dosage
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.97, blue: 0.98).ignoresSafeArea()
                
                if fdaService.isLoading {
                    ProgressView("Yükleniyor...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else if let drug = drugDetail {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            // Header
                            VStack(alignment: .leading, spacing: 8) {
                                Text(drug.brandName)
                                    .font(.system(size: 24, weight: .bold))
                                
                                Text(drug.genericName)
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Text(drug.manufacturerName)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("ID: \(drug.id)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                .padding(.top, 4)
                                
                                // Safety information button
                                Button(action: {
                                    showAdverseEvents = true
                                }) {
                                    HStack {
                                        Image(systemName: "exclamationmark.shield")
                                            .foregroundColor(.white)
                                        Text("Güvenlik Bilgileri")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color(red: 0.9, green: 0.3, blue: 0.3))
                                    .cornerRadius(8)
                                }
                                .padding(.top, 12)
                            }
                            .padding(20)
                            .background(Color.white)
                            
                            // Tab buttons
                            HStack(spacing: 0) {
                                ForEach([
                                    (DetailTab.overview, "Genel Bilgi", "info.circle"),
                                    (DetailTab.warnings, "Uyarılar", "exclamationmark.triangle"),
                                    (DetailTab.interactions, "Etkileşimler", "arrow.left.arrow.right"),
                                    (DetailTab.dosage, "Dozaj", "calendar.badge.plus")
                                ], id: \.0) { tab, title, icon in
                                    Button(action: {
                                        activeTab = tab
                                    }) {
                                        VStack(spacing: 6) {
                                            Image(systemName: icon)
                                                .font(.system(size: 16))
                                            
                                            Text(title)
                                                .font(.system(size: 11))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(activeTab == tab ? 
                                                  Color(red: 0.4, green: 0.6, blue: 0.8).opacity(0.1) : 
                                                  Color.white)
                                        .foregroundColor(activeTab == tab ? 
                                                       Color(red: 0.4, green: 0.6, blue: 0.8) : 
                                                       Color.gray)
                                    }
                                }
                            }
                            .background(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 3)
                            
                            // Content based on selected tab
                            VStack(alignment: .leading, spacing: 20) {
                                switch activeTab {
                                case .overview:
                                    overviewTabContent(drug)
                                case .warnings:
                                    warningsTabContent(drug)
                                case .interactions:
                                    interactionsTabContent(drug)
                                case .dosage:
                                    dosageTabContent(drug)
                                }
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(16)
                        }
                    }
                    .sheet(isPresented: $showAdverseEvents) {
                        FDAAdverseEventsView(drugName: drug.genericName)
                    }
                }
            }
            .navigationBarTitle("İlaç Detayları", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            })
            .onAppear {
                loadDrugDetails()
            }
        }
    }
    
    private func loadDrugDetails() {
        Task {
            do {
                let response = try await fdaService.getDrugDetails(drugId: drugId)
                drugDetail = response.drug
            } catch let error as APIError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "İlaç detayları yüklenirken bir hata oluştu: \(error.localizedDescription)"
            }
        }
    }
    
    private func overviewTabContent(_ drug: DrugDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if let description = drug.description, !description.isEmpty {
                infoSection(title: "Açıklama", content: description)
            }
            
            if let activeIngredients = drug.activeIngredients, !activeIngredients.isEmpty {
                infoSection(title: "Aktif Bileşenler", content: activeIngredients.joined(separator: ", "))
            }
            
            if let dosageForm = drug.dosageForm, !dosageForm.isEmpty {
                infoSection(title: "Form", content: dosageForm)
            }
            
            if let route = drug.route, !route.isEmpty {
                infoSection(title: "Kullanım Yolu", content: route)
            }
            
            if let indications = drug.indications, !indications.isEmpty {
                infoSection(title: "Endikasyonlar", content: indications.joined(separator: "\n"))
            }
        }
    }
    
    private func warningsTabContent(_ drug: DrugDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if let warnings = drug.warnings, !warnings.isEmpty {
                infoSection(title: "Uyarılar", content: warnings.joined(separator: "\n"))
            }
            
            if let contraindications = drug.contraindications, !contraindications.isEmpty {
                infoSection(title: "Kontrendikasyonlar", content: contraindications.joined(separator: "\n"))
            }
            
            if let adverseReactions = drug.adverseReactions, !adverseReactions.isEmpty {
                infoSection(title: "Yan Etkiler", content: adverseReactions.joined(separator: "\n"))
            }
            
            if drug.warnings == nil && drug.contraindications == nil && drug.adverseReactions == nil {
                Text("Bu ilaç için uyarı bilgisi bulunmamaktadır.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            }
        }
    }
    
    private func interactionsTabContent(_ drug: DrugDetail) -> some View {
        if let drugInteractions = drug.drugInteractions, !drugInteractions.isEmpty {
            return AnyView(infoSection(title: "İlaç Etkileşimleri", content: drugInteractions.joined(separator: "\n")))
        } else {
            return AnyView(
                VStack {
                    Text("Bu ilaç için etkileşim bilgisi bulunmamaktadır.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                }
            )
        }
    }
    
    private func dosageTabContent(_ drug: DrugDetail) -> some View {
        if let dosageAdministration = drug.dosageAdministration, !dosageAdministration.isEmpty {
            return AnyView(infoSection(title: "Dozaj ve Kullanım", content: dosageAdministration.joined(separator: "\n")))
        } else {
            return AnyView(
                VStack {
                    Text("Bu ilaç için dozaj bilgisi bulunmamaktadır.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                }
            )
        }
    }
    
    private func infoSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(red: 0.4, green: 0.6, blue: 0.8))
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationView {
        FDADrugSearchView()
    }
}

#Preview("Drug Detail") {
    DrugDetailView(drugId: "ANDA040445")
}

// Preview with mock data
struct FDADrugSearchView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Simple search view
            NavigationView {
                FDADrugSearchView()
            }
            .previewDisplayName("Search View")
            
            // Simple detail view
            DrugDetailView(drugId: "ANDA040445")
                .previewDisplayName("Drug Details")
        }
    }
} 