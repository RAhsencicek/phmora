import SwiftUI
import Foundation

// MARK: - Color Extensions
extension Color {
    /// Creates a Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Date Extensions
extension Date {
    /// Formats date for medication expiry display
    var expiryDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    /// Checks if date is within 3 months from now
    var isExpiryClose: Bool {
        let threeMonthsFromNow = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
        return self < threeMonthsFromNow
    }
    
    /// Returns relative time string (e.g., "2 hours ago")
    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - String Extensions
extension String {
    /// Validates email format
    var isValidEmail: Bool {
        let emailRegEx = AppConstants.Validation.emailRegex
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    /// Validates phone number format
    var isValidPhone: Bool {
        let phoneRegEx = AppConstants.Validation.phoneRegex
        let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: self)
    }
    
    /// Formats phone number for display
    var formattedPhone: String {
        guard !isEmpty else { return "Telefon bilgisi yok" }
        return self
    }
    
    /// Checks if string is valid password
    var isValidPassword: Bool {
        return count >= AppConstants.Validation.minPasswordLength && 
               count <= AppConstants.Validation.maxPasswordLength
    }
}

// MARK: - Double Extensions
extension Double {
    /// Formats price with Turkish Lira currency
    var formattedPrice: String {
        return String(format: "%.2f TL", self)
    }
    
    /// Formats distance in km
    var formattedDistance: String {
        return String(format: "%.2f km", self)
    }
}

// MARK: - View Extensions
extension View {
    /// Applies standard card styling
    func cardStyle() -> some View {
        self
            .background(AppConstants.Colors.cardBackground)
            .cornerRadius(AppConstants.Sizes.cornerRadius)
            .shadow(radius: 2)
    }
    
    /// Applies standard button styling
    func primaryButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.Sizes.buttonHeight)
            .background(AppConstants.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(AppConstants.Sizes.cornerRadius)
    }
    
    /// Applies secondary button styling
    func secondaryButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.Sizes.buttonHeight)
            .background(Color.gray.opacity(0.2))
            .foregroundColor(AppConstants.Colors.primary)
            .cornerRadius(AppConstants.Sizes.cornerRadius)
    }
    
    /// Conditional view modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - UserDefaults Extensions
extension UserDefaults {
    /// Gets user token
    var userToken: String? {
        get { string(forKey: AppConstants.UserDefaultsKeys.userToken) }
        set { set(newValue, forKey: AppConstants.UserDefaultsKeys.userToken) }
    }
    
    /// Checks if user is logged in
    var isUserLoggedIn: Bool {
        return userToken != nil && !userToken!.isEmpty
    }
    
    /// Removes user session data
    func clearUserSession() {
        removeObject(forKey: AppConstants.UserDefaultsKeys.userToken)
    }
}

// MARK: - Bundle Extensions
extension Bundle {
    /// App version string
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    /// App build number string
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    /// Full version string
    var fullVersion: String {
        return "\(appVersion) (\(buildNumber))"
    }
} 