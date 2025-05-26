import Foundation
import Combine

@MainActor
class TransactionService: ObservableObject {
    static let shared = TransactionService()
    
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkManager = NetworkManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Create Transaction
    
    func createTransaction(
        type: TransactionType,
        sellerPharmacyId: String,
        sellerUserId: String,
        buyerPharmacyId: String,
        buyerUserId: String,
        medicineId: String,
        quantity: Int,
        unitPrice: Double,
        paymentMethod: PaymentMethod,
        notes: String? = nil
    ) async throws -> Transaction {
        
        isLoading = true
        errorMessage = nil
        
        let transactionId = "TXN-\(UUID().uuidString.prefix(8).uppercased())"
        let totalAmount = unitPrice * Double(quantity)
        
        // Backend'in beklediği date format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let expiryDateString = dateFormatter.string(from: Calendar.current.date(byAdding: .year, value: 2, to: Date()) ?? Date())
        
        // Backend'in beklediği format - String ID'ler
        let requestBody: [String: Any] = [
            "type": type.rawValue,
            "seller": sellerPharmacyId,  // String format
            "buyer": buyerPharmacyId,    // String format
            "items": [[
                "medicine": medicineId,
                "quantity": quantity,
                "unitPrice": [
                    "currency": "TRY",
                    "amount": unitPrice
                ],
                "batchNumber": "BATCH-\(Int.random(in: 1000...9999))",
                "expiryDate": expiryDateString
            ]],
            "paymentMethod": paymentMethod.rawValue,
            "transactionId": transactionId,
            "totalAmount": [
                "currency": "TRY",
                "amount": totalAmount
            ],
            "notes": notes ?? ""
        ]
        
        print("🔍 Transaction Request:")
        if let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        }
        
        do {
            guard let url = URL(string: "https://phamorabackend-production.up.railway.app/api/transactions") else {
                throw APIError(message: "Geçersiz URL", errors: nil)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // pharmacistid header'ı ekle
            if let pharmacistId = UserDefaults.standard.string(forKey: "pharmacistId") {
                request.setValue(pharmacistId, forHTTPHeaderField: "pharmacistid")
            }
            
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Response'u debug et
            if let responseString = String(data: data, encoding: .utf8) {
                print("🌐 API Response: \(responseString)")
            }
            
            // HTTP status code kontrolü
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 400 {
                    if let errorResponse = try? JSONDecoder().decode(APIError.self, from: data) {
                        print("❌ Transaction API Error: \(errorResponse)")
                        throw errorResponse
                    } else {
                        throw APIError(message: "HTTP Error: \(httpResponse.statusCode)", errors: nil)
                    }
                }
            }
            
            // Success response'u parse et
            struct TransactionResponse: Codable {
                let success: Bool
                let data: Transaction?
                let message: String?
            }
            
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            decoder.dateDecodingStrategy = .formatted(formatter)
            let transactionResponse = try decoder.decode(TransactionResponse.self, from: data)
            
            if let transaction = transactionResponse.data {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return transaction
            } else {
                throw APIError(message: transactionResponse.message ?? "Transaction oluşturulamadı", errors: nil)
            }
            
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    // MARK: - Confirm Transaction
    
    func confirmTransaction(transactionId: String, note: String? = nil) async throws {
        isLoading = true
        errorMessage = nil
        
        print("🔄 Onaylama işlemi başlatılıyor - Transaction ID: \(transactionId)")
        
        let requestBody: [String: Any] = [
            "note": note ?? "İşlem onaylandı"
        ]
        
        do {
            guard let url = URL(string: "https://phamorabackend-production.up.railway.app/api/transactions/\(transactionId)/confirm") else {
                print("❌ Geçersiz URL oluşturuldu")
                throw APIError(message: "Geçersiz URL", errors: nil)
            }
            
            print("🌐 URL: \(url.absoluteString)")
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let pharmacistId = UserDefaults.standard.string(forKey: "pharmacistId") {
                request.setValue(pharmacistId, forHTTPHeaderField: "pharmacistid")
                print("👤 PharmacistID: \(pharmacistId)")
            } else {
                print("⚠️ PharmacistID bulunamadı!")
            }
            
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            if let requestBodyString = String(data: request.httpBody!, encoding: .utf8) {
                print("📤 İstek gövdesi: \(requestBodyString)")
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Response'u debug et
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 API Yanıtı: \(responseString)")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🔢 HTTP Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode >= 400 {
                    if let errorResponse = try? JSONDecoder().decode(APIError.self, from: data) {
                        print("❌ API Hatası: \(errorResponse.message)")
                        throw errorResponse
                    } else {
                        let errorMessage = "HTTP Hatası: \(httpResponse.statusCode)"
                        print("❌ \(errorMessage)")
                        throw APIError(message: errorMessage, errors: nil)
                    }
                } else {
                    print("✅ İşlem başarıyla onaylandı")
                }
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
        } catch {
            print("❌ Onaylama hatası: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    // MARK: - Reject Transaction
    
    func rejectTransaction(transactionId: String, reason: String) async throws {
        isLoading = true
        errorMessage = nil
        
        print("🔄 Reddetme işlemi başlatılıyor - Transaction ID: \(transactionId)")
        
        let requestBody: [String: Any] = [
            "reason": reason
        ]
        
        do {
            guard let url = URL(string: "https://phamorabackend-production.up.railway.app/api/transactions/\(transactionId)/reject") else {
                print("❌ Geçersiz URL oluşturuldu")
                throw APIError(message: "Geçersiz URL", errors: nil)
            }
            
            print("🌐 URL: \(url.absoluteString)")
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let pharmacistId = UserDefaults.standard.string(forKey: "pharmacistId") {
                request.setValue(pharmacistId, forHTTPHeaderField: "pharmacistid")
                print("👤 PharmacistID: \(pharmacistId)")
            } else {
                print("⚠️ PharmacistID bulunamadı!")
            }
            
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            if let requestBodyString = String(data: request.httpBody!, encoding: .utf8) {
                print("📤 İstek gövdesi: \(requestBodyString)")
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Response'u debug et
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 API Yanıtı: \(responseString)")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🔢 HTTP Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode >= 400 {
                    if let errorResponse = try? JSONDecoder().decode(APIError.self, from: data) {
                        print("❌ API Hatası: \(errorResponse.message)")
                        throw errorResponse
                    } else {
                        let errorMessage = "HTTP Hatası: \(httpResponse.statusCode)"
                        print("❌ \(errorMessage)")
                        throw APIError(message: errorMessage, errors: nil)
                    }
                } else {
                    print("✅ İşlem başarıyla reddedildi")
                }
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
        } catch {
            print("❌ Reddetme hatası: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    // MARK: - Fetch Transactions
    
    func fetchTransactions() async throws -> [Transaction] {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let url = URL(string: "https://phamorabackend-production.up.railway.app/api/transactions") else {
                throw APIError(message: "Geçersiz URL", errors: nil)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            if let pharmacistId = UserDefaults.standard.string(forKey: "pharmacistId") {
                request.setValue(pharmacistId, forHTTPHeaderField: "pharmacistid")
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 400 {
                    if let errorResponse = try? JSONDecoder().decode(APIError.self, from: data) {
                        throw errorResponse
                    } else {
                        throw APIError(message: "HTTP Error: \(httpResponse.statusCode)", errors: nil)
                    }
                }
            }
            
            struct TransactionsResponse: Codable {
                let success: Bool
                let data: [Transaction]
            }
            
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            decoder.dateDecodingStrategy = .formatted(formatter)
            let transactionsResponse = try decoder.decode(TransactionsResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.transactions = transactionsResponse.data
            }
            
            return transactionsResponse.data
            
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    func clearError() {
        errorMessage = nil
    }
    
    func refreshTransactions() {
        Task {
            do {
                try await fetchTransactions()
            } catch {
                print("❌ Error refreshing transactions: \(error)")
            }
        }
    }
}

// MARK: - Codable Extension
extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
} 