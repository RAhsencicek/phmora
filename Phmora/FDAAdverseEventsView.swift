import SwiftUI

struct FDAAdverseEventsView: View {
    let drugName: String
    
    @StateObject private var fdaService = OpenFDAService()
    @State private var adverseEvents: [AdverseEvent] = []
    @State private var drugRecalls: [DrugRecall] = []
    @State private var errorMessage: String? = nil
    @State private var activeTab: DataTab = .adverseEvents
    
    enum DataTab {
        case adverseEvents, recalls
    }
    
    // Colors based on the project guidelines
    private let primaryColor = Color(red: 0.4, green: 0.6, blue: 0.8)
    private let backgroundColor = Color(red: 0.95, green: 0.97, blue: 0.98)
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Tab selector
                HStack(spacing: 0) {
                    tabButton(title: "Yan Etkiler", tab: .adverseEvents)
                    tabButton(title: "Geri Çağırmalar", tab: .recalls)
                }
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 3)
                
                if fdaService.isLoading {
                    Spacer()
                    ProgressView("Yükleniyor...")
                        .progressViewStyle(CircularProgressViewStyle())
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
                            .padding(.horizontal)
                    }
                    Spacer()
                } else {
                    // Content based on selected tab
                    ScrollView {
                        switch activeTab {
                        case .adverseEvents:
                            adverseEventsContent
                        case .recalls:
                            recallsContent
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .navigationTitle("\(drugName) Güvenlik Bilgileri")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadData()
        }
    }
    
    private func tabButton(title: String, tab: DataTab) -> some View {
        Button(action: {
            activeTab = tab
        }) {
            Text(title)
                .font(.system(size: 16, weight: activeTab == tab ? .semibold : .regular))
                .foregroundColor(activeTab == tab ? primaryColor : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .background(
            VStack {
                Spacer()
                if activeTab == tab {
                    Rectangle()
                        .fill(primaryColor)
                        .frame(height: 3)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 1)
                }
            }
        )
    }
    
    private var adverseEventsContent: some View {
        LazyVStack(spacing: 16) {
            if adverseEvents.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.shield")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Bu ilaç için yan etki raporu bulunamadı")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                .frame(maxWidth: .infinity)
            } else {
                ForEach(adverseEvents) { event in
                    AdverseEventCardView(event: event)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var recallsContent: some View {
        LazyVStack(spacing: 16) {
            if drugRecalls.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Bu ilaç için geri çağırma bildirimi bulunamadı")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                .frame(maxWidth: .infinity)
            } else {
                ForEach(drugRecalls) { recall in
                    RecallCardView(recall: recall)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func loadData() {
        errorMessage = nil
        
        Task {
            do {
                async let eventsTask = fdaService.getAdverseEvents(drug: drugName)
                async let recallsTask = fdaService.getDrugRecalls(drug: drugName)
                
                let (eventsResponse, recallsResponse) = try await (eventsTask, recallsTask)
                
                DispatchQueue.main.async {
                    adverseEvents = eventsResponse.events
                    drugRecalls = recallsResponse.recalls
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Veri yüklenirken bir hata oluştu: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct AdverseEventCardView: View {
    let event: AdverseEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rapor #\(event.reportId)")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Alınma Tarihi: \(formattedDate(event.receiveDate))")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                seriousnessIndicator(event.seriousness)
            }
            
            Divider()
            
            // Patient info
            HStack {
                if let age = event.patientAge {
                    Label {
                        Text("\(age) yaş")
                            .font(.system(size: 14))
                    } icon: {
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                if let sex = event.patientSex {
                    Label {
                        Text(sexDescription(sex))
                            .font(.system(size: 14))
                    } icon: {
                        Image(systemName: sexIcon(sex))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Reactions
            if !event.reactions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reaksiyonlar")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(red: 0.4, green: 0.6, blue: 0.8))
                    
                    ForEach(event.reactions, id: \.reactionName) { reaction in
                        HStack {
                            Text("• \(reaction.reactionName)")
                                .font(.system(size: 14))
                            
                            Spacer()
                            
                            if let outcome = reaction.outcome {
                                outcomeLabel(outcome)
                            }
                        }
                    }
                }
            }
            
            // Drugs
            if !event.drugs.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("İlaçlar")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(red: 0.4, green: 0.6, blue: 0.8))
                    
                    ForEach(event.drugs.prefix(5), id: \.name) { drug in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(drug.name)
                                .font(.system(size: 14, weight: .medium))
                            
                            if let indication = drug.indication, !indication.isEmpty {
                                Text("Kullanım: \(indication)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            
                            if let dosage = drug.dosage, !dosage.isEmpty {
                                Text("Dozaj: \(dosage)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.leading, 8)
                    }
                    
                    if event.drugs.count > 5 {
                        Text("+ \(event.drugs.count - 5) daha fazla ilaç")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.leading, 8)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func formattedDate(_ dateString: String) -> String {
        // Convert YYYYMMDD to DD.MM.YYYY
        guard dateString.count == 8 else { return dateString }
        
        let year = dateString.prefix(4)
        let month = dateString.dropFirst(4).prefix(2)
        let day = dateString.dropFirst(6).prefix(2)
        
        return "\(day).\(month).\(year)"
    }
    
    private func sexDescription(_ sex: String) -> String {
        switch sex {
        case "1", "M":
            return "Erkek"
        case "2", "F":
            return "Kadın"
        default:
            return "Diğer"
        }
    }
    
    private func sexIcon(_ sex: String) -> String {
        switch sex {
        case "1", "M":
            return "person"
        case "2", "F":
            return "person.dress"
        default:
            return "person.fill.questionmark"
        }
    }
    
    private func seriousnessIndicator(_ seriousness: String) -> some View {
        let (color, text) = seriousnessInfo(seriousness)
        
        return Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(8)
    }
    
    private func seriousnessInfo(_ seriousness: String) -> (Color, String) {
        switch seriousness {
        case "1":
            return (Color.red, "Ciddi")
        case "2":
            return (Color.orange, "Orta")
        default:
            return (Color.green, "Hafif")
        }
    }
    
    private func outcomeLabel(_ outcome: String) -> some View {
        let (color, text) = outcomeInfo(outcome)
        
        return Text(text)
            .font(.system(size: 11))
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.1))
            .cornerRadius(4)
    }
    
    private func outcomeInfo(_ outcome: String) -> (Color, String) {
        switch outcome {
        case "1":
            return (Color.red, "Ölüm")
        case "2":
            return (Color.orange, "Yaşamı Tehdit Eden")
        case "3":
            return (Color.orange, "Hastaneye Yatış")
        case "4":
            return (Color.yellow, "Sakatlık")
        case "5":
            return (Color.yellow, "Doğumsal Anomali")
        case "6":
            return (Color.blue, "Diğer Ciddi")
        default:
            return (Color.blue, "Diğer")
        }
    }
}

struct RecallCardView: View {
    let recall: DrugRecall
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recall.product.prefix(80) + (recall.product.count > 80 ? "..." : ""))
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(2)
                    
                    Text("Başlangıç: \(formattedDate(recall.recallInitiationDate))")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                statusLabel(recall.status)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                infoRow(title: "Neden", content: recall.reason)
                infoRow(title: "Sınıflandırma", content: recall.classification)
                infoRow(title: "Firma", content: recall.company)
                infoRow(title: "Ülke", content: recall.country)
                infoRow(title: "Dağıtım", content: truncatedText(recall.distributionPattern, maxLength: 120))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func truncatedText(_ text: String, maxLength: Int) -> String {
        if text.count <= maxLength {
            return text
        }
        return text.prefix(maxLength) + "..."
    }
    
    private func formattedDate(_ dateString: String) -> String {
        // Convert YYYYMMDD to DD.MM.YYYY
        guard dateString.count == 8 else { return dateString }
        
        let year = dateString.prefix(4)
        let month = dateString.dropFirst(4).prefix(2)
        let day = dateString.dropFirst(6).prefix(2)
        
        return "\(day).\(month).\(year)"
    }
    
    private func statusLabel(_ status: String) -> some View {
        let isOngoing = status.lowercased().contains("ongoing") || status.lowercased().contains("terminated") == false
        let color: Color = isOngoing ? .orange : .green
        let text = isOngoing ? "Devam Ediyor" : "Tamamlandı"
        
        return Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(8)
    }
    
    private func infoRow(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(red: 0.4, green: 0.6, blue: 0.8))
            
            Text(content)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationView {
        FDAAdverseEventsView(drugName: "aspirin")
    }
}

// Preview with mock data
struct FDAAdverseEventsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Simple view
            NavigationView {
                FDAAdverseEventsView(drugName: "aspirin")
            }
            .previewDisplayName("Adverse Events View")
            
            // Event card
            AdverseEventCardView(event: FDAMockData.sampleAdverseEvents[0])
                .padding()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Event Card")
            
            // Recall card
            RecallCardView(recall: FDAMockData.sampleDrugRecalls[0])
                .padding()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Recall Card")
        }
    }
} 