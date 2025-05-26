import SwiftUI
import MapKit

struct PurchaseView: View {
    let medication: Medication
    let sellerPharmacy: Pharmacy
    var onComplete: () -> Void
    
    @State private var paymentMethod = 0
    @State private var quantity = 1
    @State private var notes = ""
    @State private var isProcessing = false
    @State private var showingSuccessAlert = false
    @State private var successMessage = ""
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var transactionService = TransactionService.shared
    
    var body: some View {
        NavigationView {
            VStack {
                if showingSuccessAlert {
                    successView
                } else {
                    formView
                }
            }
            .navigationTitle("Ödeme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !showingSuccessAlert && !isProcessing {
                        Button("İptal") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private var formView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Özet bilgisi
                VStack(alignment: .leading, spacing: 15) {
                    Text("Sipariş Özeti")
                        .font(.headline)
                    
                    HStack {
                        Text(medication.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(String(format: "%.2f", medication.price)) TL")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Satıcı Eczane:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(sellerPharmacy.name)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    // Miktar seçimi
                    HStack {
                        Text("Miktar:")
                            .font(.subheadline)
                        Spacer()
                        Stepper(value: $quantity, in: 1...medication.quantity) {
                            Text("\(quantity) adet")
                                .fontWeight(.medium)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Toplam")
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(String(format: "%.2f", medication.price * Double(quantity))) TL")
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.05), radius: 5)
                
                // Ödeme yöntemi seçimi
                VStack(alignment: .leading, spacing: 15) {
                    Text("Ödeme Yöntemi")
                        .font(.headline)
                    
                    Picker("Ödeme Yöntemi", selection: $paymentMethod) {
                        Text("Kredi Kartı").tag(0)
                        Text("Havale/EFT").tag(1)
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.05), radius: 5)
                
                // Notlar
                    VStack(alignment: .leading, spacing: 15) {
                    Text("Notlar (İsteğe Bağlı)")
                            .font(.headline)
                        
                    TextField("Özel isteklerinizi buraya yazabilirsiniz...", text: $notes, axis: .vertical)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        .lineLimit(3...6)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                
                // Bilgilendirme
                    VStack(alignment: .leading, spacing: 10) {
                    Text("Nasıl Çalışır?")
                            .font(.headline)
                        
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "1.circle.fill")
                            .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                        Text("Satın alma talebiniz satıcı eczaneye bildirim olarak gönderilir")
                            .font(.caption)
                    }
                    
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "2.circle.fill")
                            .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                        Text("Satıcı eczane talebinizi onaylar veya reddeder")
                            .font(.caption)
                    }
                    
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "3.circle.fill")
                            .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                        Text("Onay durumunu bildirimler sekmesinden takip edebilirsiniz")
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(10)
                
                // Satın alma butonu
                Button(action: {
                    Task {
                        await createPurchaseRequest()
                    }
                }) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Satın Alma Talebi Gönder")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.4, green: 0.5, blue: 0.4))
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isProcessing)
            }
            .padding()
        }
    }
    
    private var successView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            VStack(spacing: 8) {
                Text("Satın Alma Talebi Gönderildi!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Talebiniz \(sellerPharmacy.name) eczanesine gönderildi. Onay durumu hakkında bildirim alacaksınız.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button("Tamam") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.4, green: 0.5, blue: 0.4))
        }
        .padding()
    }
    
    private func createPurchaseRequest() async {
        isProcessing = true
        
        do {
            // AuthService'den gerçek kullanıcı bilgilerini al
            guard let currentUserId = AuthService.shared.currentUserId,
                  let currentPharmacyId = AuthService.shared.currentPharmacyId else {
                throw APIError(message: "Kullanıcı bilgileri bulunamadı. Lütfen tekrar giriş yapın.", errors: nil)
            }
            
            // Seller pharmacy ID'sini kontrol et ve debug et
            print("🔍 Seller Pharmacy Raw ID: '\(sellerPharmacy.id)'")
            print("🔍 Seller Pharmacy ID Length: \(sellerPharmacy.id.count)")
            print("🔍 Seller Pharmacy ID isHex: \(sellerPharmacy.id.allSatisfy { $0.isHexDigit })")
            
            // Backend'den gelen gerçek ID'leri kullan, eğer geçersizse hata ver
            guard isValidObjectId(sellerPharmacy.id) else {
                throw APIError(message: "Geçersiz satıcı eczane bilgisi", errors: nil)
            }
            
            guard let sellerUserId = sellerPharmacy.owner?.id, isValidObjectId(sellerUserId) else {
                throw APIError(message: "Geçersiz satıcı kullanıcı bilgisi", errors: nil)
            }
            
            // Medication ID'sini kontrol et
            let medicineId: String
            if let backendId = medication.backendId, isValidObjectId(backendId) {
                medicineId = backendId
            } else {
                // Backend ID yoksa ilaç adına göre ara
                medicineId = try await findMedicineIdByName(medication.name)
            }
            
            print("🔍 Transaction IDs (Real):")
            print("  Seller Pharmacy: \(sellerPharmacy.id) (valid: \(isValidObjectId(sellerPharmacy.id)))")
            print("  Seller User: \(sellerUserId) (valid: \(isValidObjectId(sellerUserId)))")
            print("  Buyer Pharmacy: \(currentPharmacyId) (valid: \(isValidObjectId(currentPharmacyId)))")
            print("  Buyer User: \(currentUserId) (valid: \(isValidObjectId(currentUserId)))")
            print("  Medicine: \(medicineId) (valid: \(isValidObjectId(medicineId)))")
            
            let _ = try await transactionService.createTransaction(
                type: TransactionType.purchase,
                sellerPharmacyId: sellerPharmacy.id,
                sellerUserId: sellerUserId,
                buyerPharmacyId: currentPharmacyId,
                buyerUserId: currentUserId,
                medicineId: medicineId,
                quantity: quantity,
                unitPrice: medication.price,
                paymentMethod: paymentMethod == 0 ? PaymentMethod.creditCard : PaymentMethod.bankTransfer,
                notes: notes.isEmpty ? nil : notes
            )
            
            isProcessing = false
            showingSuccessAlert = true
            successMessage = "Talep Gönderildi!"
            
        } catch {
            isProcessing = false
            print("❌ Transaction creation error: \(error)")
        }
    }
    
    // İlaç adına göre backend'den ilaç ID'sini bul
    private func findMedicineIdByName(_ medicineName: String) async throws -> String {
        guard let url = URL(string: "https://phamorabackend-production.up.railway.app/api/medicines?search=\(medicineName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&limit=1") else {
            throw APIError(message: "Geçersiz URL", errors: nil)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        struct MedicineSearchResponse: Codable {
            let success: Bool
            let data: [Medicine]
        }
        
        let response = try JSONDecoder().decode(MedicineSearchResponse.self, from: data)
        
        if let medicine = response.data.first {
            return medicine.id
        } else {
            // Eğer ilaç bulunamazsa, genel bir ilaç ID'si kullan (test amaçlı)
            throw APIError(message: "İlaç bulunamadı: \(medicineName)", errors: nil)
        }
    }
    
    // MongoDB ObjectId validation helper
    private func isValidObjectId(_ id: String) -> Bool {
        return id.count == 24 && id.allSatisfy { $0.isHexDigit }
    }
}

#Preview {
    let sampleMedication = Medication(
        name: "Parol", 
        description: "Ağrı kesici", 
        price: 25.90, 
        quantity: 10, 
        expiryDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()), 
        imageURL: nil, 
        status: .forSale
    )
    
    let samplePharmacy = Pharmacy(
        name: "Örnek Eczane",
        address: "Atatürk Caddesi No:15, Kadıköy/İstanbul",
        phone: "0212 123 4567",
        coordinate: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
        availableMedications: [sampleMedication]
    )
    
    PurchaseView(medication: sampleMedication, sellerPharmacy: samplePharmacy) {}
} 