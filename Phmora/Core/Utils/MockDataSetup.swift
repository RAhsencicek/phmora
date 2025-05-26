import Foundation

struct MockDataSetup {
    static func setupMockUserData() {
        // Geçerli MongoDB ObjectId formatında mock veriler
        UserDefaults.standard.set("507f1f77bcf86cd799439011", forKey: "userId")
        UserDefaults.standard.set("507f1f77bcf86cd799439012", forKey: "pharmacyId")
        UserDefaults.standard.set("PHARM001", forKey: "pharmacistId")
        UserDefaults.standard.set("mock-auth-token", forKey: "authToken")
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        
        print("✅ Mock user data setup completed with valid ObjectIds")
    }
    
    static func clearMockUserData() {
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "pharmacyId")
        UserDefaults.standard.removeObject(forKey: "pharmacistId")
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        
        print("🗑️ Mock user data cleared")
    }
    
    // MongoDB ObjectId validation
    static func isValidObjectId(_ id: String) -> Bool {
        return id.count == 24 && id.allSatisfy { $0.isHexDigit }
    }
    
    // Generate valid MongoDB ObjectId
    static func generateObjectId() -> String {
        let hexChars = "0123456789abcdef"
        return String((0..<24).map { _ in hexChars.randomElement()! })
    }
} 