import SwiftUI

struct AddMedicationView: View {
    @State private var name = ""
    @State private var description = ""
    @State private var price = ""
    @State private var quantity = ""
    @State private var expiryDate = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    @State private var selectedStatus: MedicationStatus = .forSale
    @State private var showImagePicker = false
    @State private var image: Image?
    @Environment(\.presentationMode) var presentationMode
    
    var onSave: (Medication) -> Void
    
    var isFormValid: Bool {
        !name.isEmpty && !price.isEmpty && !quantity.isEmpty && Double(price) != nil && Int(quantity) != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("İlaç Bilgileri")) {
                    TextField("İlaç Adı", text: $name)
                    TextField("Açıklama", text: $description)
                    TextField("Fiyat (TL)", text: $price)
                    TextField("Miktar", text: $quantity)
                }
                
                Section(header: Text("Son Kullanma Tarihi")) {
                    DatePicker("Tarih", selection: $expiryDate, displayedComponents: .date)
                }
                
                Section(header: Text("Durum")) {
                    Picker("Durum", selection: $selectedStatus) {
                        ForEach(MedicationStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Görsel")) {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        HStack {
                            Text("Görsel Ekle")
                            Spacer()
                            if image != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "photo")
                                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.4))
                            }
                        }
                    }
                }
            }
            .navigationTitle("İlaç Ekle")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        let newMedication = Medication(
                            name: name,
                            description: description,
                            price: Double(price) ?? 0.0,
                            quantity: Int(quantity) ?? 0,
                            expiryDate: expiryDate,
                            imageURL: nil,
                            status: selectedStatus
                        )
                        onSave(newMedication)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
} 