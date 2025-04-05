import SwiftUI

struct OfferView: View {
    let medication: Medication
    var onComplete: () -> Void
    
    @State private var offerAmount = ""
    @State private var message = ""
    @State private var isProcessing = false
    @State private var showSuccess = false
    @Environment(\.presentationMode) var presentationMode
    
    var isValid: Bool {
        guard let amount = Double(offerAmount) else { return false }
        return amount > 0
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if showSuccess {
                    successView
                } else {
                    formView
                }
            }
            .navigationTitle("Teklif Ver")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !showSuccess && !isProcessing {
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
                // İlaç bilgileri
                VStack(alignment: .leading, spacing: 10) {
                    Text("İlaç Bilgileri")
                        .font(.headline)
                    
                    HStack {
                        Text("İlaç:")
                            .fontWeight(.medium)
                        Text(medication.name)
                    }
                    
                    HStack {
                        Text("Satış Fiyatı:")
                            .fontWeight(.medium)
                        Text("\(String(format: "%.2f", medication.price)) TL")
                    }
                    
                    HStack {
                        Text("Miktar:")
                            .fontWeight(.medium)
                        Text("\(medication.quantity)")
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.05), radius: 5)
                
                // Teklif formu
                VStack(alignment: .leading, spacing: 15) {
                    Text("Teklifiniz")
                        .font(.headline)
                    
                    HStack {
                        Text("TL")
                            .foregroundColor(.gray)
                            .padding(.leading)
                        
                        TextField("Teklif tutarı", text: $offerAmount)
                            .keyboardType(.decimalPad)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    Text("Mesajınız (Opsiyonel)")
                        .font(.headline)
                    
                    TextEditor(text: $message)
                        .frame(height: 100)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.05), radius: 5)
                
                // Teklif gönder butonu
                Button(action: {
                    sendOffer()
                }) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Teklif Gönder")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.4, green: 0.5, blue: 0.4))
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isProcessing || !isValid)
            }
            .padding()
        }
    }
    
    private var successView: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
            
            Text("Teklif Gönderildi!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Teklifiniz ilgili eczacıya iletilmiştir. İşlem durumunu bildirimler sekmesinden takip edebilirsiniz.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            Button("Tamam") {
                onComplete()
                presentationMode.wrappedValue.dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 0.4, green: 0.5, blue: 0.4))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .padding()
    }
    
    private func sendOffer() {
        isProcessing = true
        
        // Teklif gönderme işlemi simülasyonu
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isProcessing = false
            showSuccess = true
        }
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
    
    return OfferView(medication: sampleMedication) {}
} 