import Foundation

extension UserDefaults {
    var pharmacistId: String? {
        get { string(forKey: "pharmacistId") }
        set { set(newValue, forKey: "pharmacistId") }
    }
    
    var userId: String? {
        get { string(forKey: "userId") }
        set { set(newValue, forKey: "userId") }
    }
    
    var pharmacyId: String? {
        get { string(forKey: "pharmacyId") }
        set { set(newValue, forKey: "pharmacyId") }
    }
    
    var authToken: String? {
        get { string(forKey: "authToken") }
        set { set(newValue, forKey: "authToken") }
    }
    
    var isLoggedIn: Bool {
        return pharmacistId != nil && authToken != nil
    }
    
    func clearUserData() {
        removeObject(forKey: "pharmacistId")
        removeObject(forKey: "userId")
        removeObject(forKey: "pharmacyId")
        removeObject(forKey: "authToken")
    }
} 