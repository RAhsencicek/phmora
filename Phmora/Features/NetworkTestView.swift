import SwiftUI
import Combine

struct NetworkTestView: View {
    @State private var medicines: [Medicine] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var cancellables = Set<AnyCancellable>()
    
    private let baseURL = "https://phamorabackend-production.up.railway.app/api"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🧪 Backend API Test")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                Button(action: testAPI) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        }
                        Text(isLoading ? "Test Ediliyor..." : "Backend'i Test Et")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isLoading)
                .padding(.horizontal)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                if !successMessage.isEmpty {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                if !medicines.isEmpty {
                    List(medicines) { medicine in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(medicine.name)
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(medicine.manufacturer)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text(medicine.dosageFormDisplayName)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(6)
                                
                                Spacer()
                                
                                if let price = medicine.price {
                                    Text(price.formattedPrice)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                }
                            }
                            
                            if let strength = medicine.strength {
                                Text("Doz: \(strength)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("API Test")
        }
    }
    
    private func testAPI() {
        isLoading = true
        errorMessage = ""
        successMessage = ""
        medicines = []
        
        // Direct API call without complex NetworkManager
        guard let url = URL(string: "\(baseURL)/medicines?limit=5") else {
            errorMessage = "❌ Geçersiz URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("🌐 Status Code: \(httpResponse.statusCode)")
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("🌐 Response: \(responseString)")
                }
                
                if httpResponse.statusCode >= 400 {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: APIResponse<[Medicine]>.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        errorMessage = "❌ Hata: \(error.localizedDescription)"
                        print("🔴 Error: \(error)")
                    }
                },
                receiveValue: { response in
                    if response.success {
                        medicines = response.data ?? []
                        successMessage = "✅ Başarılı! \(medicines.count) ilaç yüklendi"
                        
                        // Konsola detaylı log
                        print("✅ API Test Başarılı!")
                        print("📊 Toplam İlaç: \(medicines.count)")
                        for medicine in medicines {
                            print("💊 \(medicine.name) - \(medicine.manufacturer)")
                        }
                    } else {
                        errorMessage = "❌ API Hatası: \(response.message ?? "Bilinmeyen hata")"
                    }
                }
            )
            .store(in: &cancellables)
    }
}

#Preview {
    NetworkTestView()
} 