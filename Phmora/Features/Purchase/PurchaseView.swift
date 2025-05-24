import SwiftUI
import UIKit

// UIKit renkleri için Color extension'ı ekleyin
extension Color {
    static let systemGray6 = Color(UIColor.systemGray6)
}

struct PurchaseView: View {
    let medication: Medication
    var onComplete: () -> Void
    
    @State private var paymentMethod = 0
    @State private var cardNumber = ""
    @State private var cardName = ""
    @State private var cardExpiry = ""
    @State private var cardCVV = ""
    @State private var isProcessing = false
    @State private var showSuccess = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                if showSuccess {
                    successView
                } else {
                    formView
                }
            }
            .navigationTitle("Ödeme")
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
                    
                    Divider()
                    
                    HStack {
                        Text("Toplam")
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(String(format: "%.2f", medication.price)) TL")
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
                
                if paymentMethod == 0 {
                    // Kredi kartı bilgileri
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Kart Bilgileri")
                            .font(.headline)
                        
                        TextField("Kart Numarası", text: $cardNumber)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        TextField("Kart Üzerindeki İsim", text: $cardName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        HStack {
                            TextField("Son Kullanma (AA/YY)", text: $cardExpiry)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            
                            TextField("CVV", text: $cardCVV)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                } else {
                    // Havale bilgileri
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Havale Bilgileri")
                            .font(.headline)
                        
                        Text("Banka: Pharmora Bank")
                        Text("IBAN: TR12 3456 7890 1234 5678 9012 34")
                        Text("Hesap Sahibi: Pharmora İlaç A.Ş.")
                        
                        Text("Not: Ödemenizin açıklama kısmına sipariş numaranızı yazın.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 5)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                }
                
                // Ödeme butonu
                Button(action: {
                    processPayment()
                }) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Ödemeyi Tamamla")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.4, green: 0.5, blue: 0.4))
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isProcessing || (paymentMethod == 0 && (cardNumber.isEmpty || cardName.isEmpty || cardExpiry.isEmpty || cardCVV.isEmpty)))
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
            
            Text("Ödeme Başarılı!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Sipariş numaranız: #\(Int.random(in: 10000...99999))")
                .font(.headline)
            
            Text("Siparişiniz ilgili eczacıya iletilmiştir. İşlem durumunu bildirimler sekmesinden takip edebilirsiniz.")
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
    
    private func processPayment() {
        isProcessing = true
        
        // Ödeme işlemi simülasyonu
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
    
    PurchaseView(medication: sampleMedication) {}
} 