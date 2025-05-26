import SwiftUI
import CoreLocation
import MapKit
import Foundation

// MARK: - App Constants
/// Central location for all app constants and configuration values
struct AppConstants {
    
    // MARK: - Colors
    struct Colors {
        // Ana tema renkleri - karanlık mod uyumlu
        static let primary = Color(red: 0.4, green: 0.5, blue: 0.4)
        static let secondary = Color.gray
        static let cardBackground = Color.white
        static let background = Color(red: 0.98, green: 0.98, blue: 0.98)
        static let accent = Color.blue
        
        // Text renkler - adaptif
        static let primaryText = Color.primary
        static let secondaryText = Color.secondary
        static let mutedText = Color.gray
        
        // Durum renkleri
        static let success = Color.green
        static let error = Color.red
        static let warning = Color.orange
        
        // Ek renkler
        static let medicationAvailable = success
        static let medicationForSale = secondary
    }
    
    // MARK: - Sizes
    struct Sizes {
        static let buttonHeight: CGFloat = 50
        static let iconSize: CGFloat = 28
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let cardPadding: CGFloat = 16
        static let spacing: CGFloat = 16
    }
    
    // MARK: - API Configuration
    struct API {
        static let baseURL = "https://phamorabackend-production.up.railway.app/api"
        static let timeout: TimeInterval = 30
        
        struct Endpoints {
            static let login = "/auth/login"
            static let register = "/auth/register"
            static let pharmacies = "/pharmacies"
            static let nearbyPharmacies = "/pharmacies/nearby"
            static let medications = "/medicines"
            static let notifications = "/notifications"
            static let transactions = "/transactions"
            static let inventory = "/inventory"
        }
    }
    
    // MARK: - Map Configuration
    struct Map {
        static let defaultCenter = CLLocationCoordinate2D(
            latitude: 38.6748,
            longitude: 39.2225
        ) // Elazığ merkez koordinatları
        
        static let defaultSpan = MKCoordinateSpan(
            latitudeDelta: 0.01,
            longitudeDelta: 0.01
        )
        
        static let regionSpan = MKCoordinateSpan(
            latitudeDelta: 0.05,
            longitudeDelta: 0.05
        )
    }
    
    // MARK: - Animation Configuration
    struct Animation {
        static let defaultDuration: TimeInterval = 0.3
        static let springResponse: Double = 0.3
        static let springDamping: Double = 0.7
        static let pulseAnimation = SwiftUI.Animation.easeInOut(duration: 1).repeatForever(autoreverses: false)
    }
    
    // MARK: - User Defaults Keys
    struct UserDefaultsKeys {
        static let pharmacistId = "pharmacistId"
        static let userId = "userId"
        static let pharmacyId = "pharmacyId"
        static let authToken = "authToken"
        static let isLoggedIn = "isLoggedIn"
        static let isFirstLaunch = "isFirstLaunch"
        static let selectedLanguage = "selectedLanguage"
    }
    
    // MARK: - Notification Names
    struct NotificationNames {
        static let userDidLogin = "userDidLogin"
        static let userDidLogout = "userDidLogout"
        static let medicationAdded = "medicationAdded"
        static let offerReceived = "offerReceived"
    }
    
    // MARK: - Validation Rules
    struct Validation {
        static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        static let phoneRegex = "^[0-9]{10,11}$"
        static let minPasswordLength = 6
        static let maxPasswordLength = 50
    }
    
    // MARK: - App Information
    struct AppInfo {
        static let name = "Pharmora"
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
} 