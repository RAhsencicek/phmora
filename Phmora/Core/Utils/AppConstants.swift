import SwiftUI
import CoreLocation
import MapKit

// MARK: - App Constants
/// Central location for all app constants and configuration values
struct AppConstants {
    
    // MARK: - Colors
    struct Colors {
        static let primary = Color(red: 0.4, green: 0.5, blue: 0.4)
        static let secondary = Color(red: 0.85, green: 0.5, blue: 0.2)
        static let background = Color(red: 0.95, green: 0.97, blue: 0.95)
        static let cardBackground = Color.white
        static let success = Color.green
        static let error = Color.red
        static let warning = Color.orange
    }
    
    // MARK: - Sizes
    struct Sizes {
        static let buttonHeight: CGFloat = 44
        static let iconSize: CGFloat = 28
        static let cornerRadius: CGFloat = 10
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
    }
    
    // MARK: - API Configuration
    struct API {
        static let baseURL = "https://phamorabackend-production.up.railway.app/api"
        static let timeoutInterval: TimeInterval = 30
        
        struct Endpoints {
            static let login = "/auth/login"
            static let register = "/auth/register"
            static let pharmacies = "/pharmacy"
            static let nearbyPharmacies = "/pharmacy/nearby"
            static let medications = "/medications"
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
        static let userToken = "userToken"
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
        static let minPasswordLength = 6
        static let maxPasswordLength = 50
        static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        static let phoneRegex = "^[0-9]{10,11}$"
    }
    
    // MARK: - App Information
    struct AppInfo {
        static let name = "Pharmora"
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
} 