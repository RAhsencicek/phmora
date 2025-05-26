import SwiftUI
import MapKit
import Foundation

struct Pharmacy: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let owner: PharmacyOwner?
    let address: PharmacyAddress
    let location: PharmacyLocation
    let phone: String
    let email: String?
    let licenseNumber: String
    let isActive: Bool
    let isOnDuty: Bool
    let workingHours: WorkingHours?
    let rating: PharmacyRating?
    let description: String?
    let services: [String]?
    let imageUrl: String?
    let availableMedications: [Medication]
    let createdAt: Date
    let updatedAt: Date
    
    // Computed property for CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: location.coordinates[1],
            longitude: location.coordinates[0]
        )
    }
    
    // Computed property for full address string (backward compatibility)
    var fullAddress: String {
        return address.fullAddress ?? "\(address.street), \(address.district)/\(address.city)"
    }
    
    // Legacy init for backward compatibility with mock data
    init(name: String, address: String, phone: String, coordinate: CLLocationCoordinate2D, availableMedications: [Medication]) {
        self.id = UUID().uuidString
        self.name = name
        self.owner = nil
        self.address = PharmacyAddress(street: address, city: "Elazığ", district: "Merkez", postalCode: nil, fullAddress: address)
        self.location = PharmacyLocation(type: "Point", coordinates: [coordinate.longitude, coordinate.latitude])
        self.phone = phone
        self.email = nil
        self.licenseNumber = "ECZ-\(Int.random(in: 10000...99999))"
        self.isActive = true
        self.isOnDuty = true
        self.workingHours = nil
        self.rating = nil
        self.description = nil
        self.services = nil
        self.imageUrl = nil
        self.availableMedications = availableMedications
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, owner, address, location, phone, email
        case licenseNumber, isActive, isOnDuty
        case workingHours, rating, description, services
        case imageUrl, availableMedications
        case createdAt, updatedAt
    }
    
    // Equatable implementation
    static func == (lhs: Pharmacy, rhs: Pharmacy) -> Bool {
        return lhs.id == rhs.id
    }
}

struct PharmacyAddress: Codable {
    let street: String
    let city: String
    let district: String
    let postalCode: String?
    let fullAddress: String?
}

struct PharmacyLocation: Codable {
    let type: String
    let coordinates: [Double] // [longitude, latitude]
}

struct WorkingHours: Codable {
    let monday: DayHours?
    let tuesday: DayHours?
    let wednesday: DayHours?
    let thursday: DayHours?
    let friday: DayHours?
    let saturday: DayHours?
    let sunday: DayHours?
}

struct DayHours: Codable {
    let open: String?
    let close: String?
}

struct PharmacyRating: Codable {
    let average: Double
    let count: Int
}

// Medication Models
enum MedicationStatus: String, Codable, CaseIterable {
    case available = "available"
    case forSale = "forSale"
    case outOfStock = "outOfStock"
    case reserved = "reserved"
    case sold = "sold"
    
    var displayName: String {
        switch self {
        case .available: return "Mevcut"
        case .forSale: return "Satışta"
        case .outOfStock: return "Stokta Yok"
        case .reserved: return "Rezerve"
        case .sold: return "Satıldı"
        }
    }
}

struct Medication: Identifiable, Codable {
    let backendId: String? // Backend'den gelen gerçek ID (varsa)
    let name: String
    let description: String
    let price: Double
    let quantity: Int
    let expiryDate: Date?
    let imageURL: URL?
    let status: MedicationStatus
    
    // Computed property for Identifiable
    var id: String {
        return backendId ?? "\(name)-\(description.hashValue)"
    }
    
    enum CodingKeys: String, CodingKey {
        case backendId = "_id" // Backend'den gelen ID alanı
        case name, description, price, quantity, expiryDate, imageURL, status
    }
    
    init(backendId: String? = nil, name: String, description: String, price: Double, quantity: Int, expiryDate: Date?, imageURL: URL?, status: MedicationStatus) {
        self.backendId = backendId
        self.name = name
        self.description = description
        self.price = price
        self.quantity = quantity
        self.expiryDate = expiryDate
        self.imageURL = imageURL
        self.status = status
    }
    
    // Custom decoder to handle both formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Backend ID (optional)
        self.backendId = try container.decodeIfPresent(String.self, forKey: .backendId)
        
        // Required fields
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.price = try container.decode(Double.self, forKey: .price)
        self.quantity = try container.decode(Int.self, forKey: .quantity)
        
        // Optional fields
        self.expiryDate = try container.decodeIfPresent(Date.self, forKey: .expiryDate)
        self.imageURL = try container.decodeIfPresent(URL.self, forKey: .imageURL)
        self.status = try container.decodeIfPresent(MedicationStatus.self, forKey: .status) ?? .available
    }
}

// Auth Models
struct LoginRequest: Codable {
    let pharmacistId: String
    let password: String
}

struct LoginResponse: Codable {
    let message: String
    let user: UserResponse
}

struct UserResponse: Codable {
    let id: String
    let pharmacistId: String
    let name: String
    let email: String
    let role: String
}

struct APIError: LocalizedError, Codable {
    let message: String?
    let errors: [ValidationError]?
    
    var errorDescription: String? {
        if let validationErrors = errors {
            return validationErrors.map { $0.msg }.joined(separator: "\n")
        }
        return message ?? "Bilinmeyen bir hata oluştu"
    }
}

struct ValidationError: Codable {
    let type: String
    let msg: String
    let path: String
    let location: String
}

// MARK: - API Response Models
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let message: String?
    let data: T?
    let pagination: PaginationInfo?
}

struct PaginationInfo: Codable {
    let current: Int
    let total: Int
    let count: Int
    let totalItems: Int
    let unreadCount: Int?
    
    // Computed properties for compatibility
    var currentPage: Int { current }
    var totalPages: Int { total }
    var hasNext: Bool { current < total }
    var hasPrev: Bool { current > 1 }
}

// MARK: - Backend Medicine Models
struct Medicine: Identifiable, Codable {
    let _id: String
    let name: String
    let genericName: String?
    let manufacturer: String
    let dosageForm: String
    let strength: String?
    let packageSize: String?
    let description: String?
    let price: MedicinePrice?
    let barcode: String?
    let prescriptionRequired: Bool?
    let isActive: Bool?
    let createdAt: String
    let updatedAt: String
    
    // Identifiable protokolü için computed property
    var id: String { _id }
    
    enum CodingKeys: String, CodingKey {
        case _id
        case name, genericName, manufacturer, dosageForm
        case strength, packageSize, description, price, barcode
        case prescriptionRequired, isActive, createdAt, updatedAt
    }
}

struct MedicinePrice: Codable {
    let amount: Double
    let currency: String
    
    var formattedPrice: String {
        return String(format: "%.2f %@", amount, currency)
    }
}

enum DosageForm: String, Codable, CaseIterable {
    case tablet = "tablet"
    case capsule = "capsule"
    case syrup = "syrup"
    case injection = "injection"
    case cream = "cream"
    case drops = "drops"
    case spray = "spray"
    case powder = "powder"
    case solution = "solution"
    case ointment = "ointment"
    
    var displayName: String {
        switch self {
        case .tablet: return "Tablet"
        case .capsule: return "Kapsül"
        case .syrup: return "Şurup"
        case .injection: return "Enjeksiyon"
        case .cream: return "Krem"
        case .drops: return "Damla"
        case .spray: return "Sprey"
        case .powder: return "Toz"
        case .solution: return "Solüsyon"
        case .ointment: return "Merhem"
        }
    }
}

struct MedicineSearchParams {
    let query: String?
    let manufacturer: String?
    let dosageForm: DosageForm?
    let page: Int
    let limit: Int
    
    func toQueryParams() -> [String] {
        var params: [String] = []
        
        if let query = query, !query.isEmpty {
            params.append("search=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        }
        
        if let manufacturer = manufacturer, !manufacturer.isEmpty {
            params.append("manufacturer=\(manufacturer.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        }
        
        if let dosageForm = dosageForm {
            params.append("dosage_form=\(dosageForm.rawValue)")
        }
        
        params.append("page=\(page)")
        params.append("limit=\(limit)")
        
        return params
    }
}

// MARK: - Medicine Extensions
extension Medicine {
    /// Convert to local Medication model for compatibility
    func toMedication() -> Medication {
        return Medication(
            backendId: _id,
            name: name,
            description: description ?? "\(manufacturer) - \(dosageForm.capitalized)",
            price: price?.amount ?? 0.0,
            quantity: 1,
            expiryDate: nil,
            imageURL: nil,
            status: .available
        )
    }
    
    /// Display name for dosage form
    var dosageFormDisplayName: String {
        switch dosageForm.lowercased() {
        case "tablet": return "Tablet"
        case "capsule": return "Kapsül"
        case "syrup": return "Şurup"
        case "injection": return "Enjeksiyon"
        case "cream": return "Krem"
        case "drops": return "Damla"
        case "spray": return "Sprey"
        case "powder": return "Toz"
        case "solution": return "Solüsyon"
        case "ointment": return "Merhem"
        default: return dosageForm.capitalized
        }
    }
}

struct PharmacyOwner: Codable {
    let id: String
    let pharmacistId: String
    let name: String
    let surname: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case pharmacistId, name, surname
    }
}

// MARK: - Notification Models
struct NotificationModel: Identifiable, Codable {
    let id: String
    let title: String
    let message: String
    let type: NotificationTypeModel
    let isRead: Bool
    let date: Date
    let data: NotificationData?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title, message, type, isRead, date, data
    }
}

enum NotificationTypeModel: String, Codable, CaseIterable {
    case offer = "offer"
    case purchase = "purchase"
    case transaction = "transaction"
    case expiry = "expiry"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .offer: return "Yeni Teklif"
        case .purchase: return "Satın Alma"
        case .transaction: return "İşlem Güncellemesi"
        case .expiry: return "Son Kullanma Tarihi"
        case .system: return "Sistem"
        }
    }
    
    var iconName: String {
        switch self {
        case .offer: return "text.badge.plus"
        case .purchase: return "bag"
        case .transaction: return "arrow.left.arrow.right"
        case .expiry: return "calendar"
        case .system: return "bell"
        }
    }
    
    var color: Color {
        switch self {
        case .offer: return .blue
        case .purchase: return Color(red: 0.4, green: 0.5, blue: 0.4)
        case .transaction: return .orange
        case .expiry: return .red
        case .system: return .gray
        }
    }
}

struct NotificationData: Codable {
    // Transaction related data
    let transactionId: NotificationTransactionReference?
    
    // Medicine related data (for expiry/system notifications)
    let medicineId: NotificationMedicineReference?
    let inventoryId: NotificationInventoryReference?
    let expiryDate: String?
    let quantity: Int?
    let minStockLevel: Int?
    
    // Legacy fields for backward compatibility
    let pharmacyId: String?
    let amount: Double?
    let currency: String?
}

struct NotificationTransactionReference: Codable {
    let _id: String
    let transactionId: String
    let status: String
    
    var id: String { _id }
}

struct NotificationMedicineReference: Codable {
    let _id: String
    let barcode: String?
    let name: String
    let dosageForm: String?
    
    var id: String { _id }
}

struct NotificationInventoryReference: Codable {
    let _id: String
    let quantity: Int
    let expiryDate: String?
    
    var id: String { _id }
}

// MARK: - Transaction Models
struct Transaction: Identifiable, Codable {
    let id: String
    let transactionId: String
    let type: TransactionType
    let seller: TransactionPartyResponse
    let buyer: TransactionPartyResponse
    let items: [TransactionItemResponse]
    let totalAmount: TransactionAmount
    let status: TransactionStatus
    let paymentMethod: PaymentMethod?
    let paymentStatus: String?
    let deliveryInfo: DeliveryInfo?
    let notes: String?
    let timeline: [TransactionTimeline]?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case transactionId, type, seller, buyer, items
        case totalAmount, status, paymentMethod, paymentStatus
        case deliveryInfo, notes, timeline
        case createdAt, updatedAt
    }
}

// Backend'den gelen response formatı
struct TransactionPartyResponse: Codable {
    let _id: String
    let name: String
    let owner: String
    
    var id: String { _id }
}

struct TransactionItemResponse: Codable {
    let medicine: TransactionMedicineReference
    let quantity: Int
    let unitPrice: TransactionAmount
    let totalPrice: TransactionAmount
    let batchNumber: String?
    let expiryDate: String?
    let _id: String
    
    var id: String { _id }
}

struct TransactionMedicineReference: Codable {
    let _id: String
    let name: String
    
    var id: String { _id }
}

struct DeliveryInfo: Codable {
    let deliveryFee: TransactionAmount?
    let method: String?
}

struct TransactionTimeline: Codable {
    let status: String
    let date: String
    let note: String?
    let updatedBy: String?
    let _id: String
    
    var id: String { _id }
}

enum TransactionType: String, Codable, CaseIterable {
    case sale = "sale"
    case purchase = "purchase"
    case exchange = "exchange"
    case transfer = "transfer"
    
    var displayName: String {
        switch self {
        case .sale: return "Satış"
        case .purchase: return "Satın Alma"
        case .exchange: return "Takas"
        case .transfer: return "Transfer"
        }
    }
}

enum TransactionStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case confirmed = "confirmed"
    case inTransit = "in_transit"
    case delivered = "delivered"
    case completed = "completed"
    case cancelled = "cancelled"
    case refunded = "refunded"
    
    var displayName: String {
        switch self {
        case .pending: return "Beklemede"
        case .confirmed: return "Onaylandı"
        case .inTransit: return "Yolda"
        case .delivered: return "Teslim Edildi"
        case .completed: return "Tamamlandı"
        case .cancelled: return "İptal Edildi"
        case .refunded: return "İade Edildi"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .confirmed: return .blue
        case .inTransit: return .purple
        case .delivered: return .green
        case .completed: return Color(red: 0.4, green: 0.5, blue: 0.4)
        case .cancelled: return .red
        case .refunded: return .gray
        }
    }
}

enum PaymentMethod: String, Codable, CaseIterable {
    case bankTransfer = "bank_transfer"
    case creditCard = "credit_card"
    case cash = "cash"
    case check = "check"
    
    var displayName: String {
        switch self {
        case .bankTransfer: return "Havale/EFT"
        case .creditCard: return "Kredi Kartı"
        case .cash: return "Nakit"
        case .check: return "Çek"
        }
    }
}

struct TransactionAmount: Codable {
    let currency: String
    let amount: Double
    
    var formattedAmount: String {
        return String(format: "%.2f %@", amount, currency)
    }
}

// MARK: - Transaction Request Models (for creating transactions)
struct TransactionParty: Codable {
    let pharmacy: String
    let user: String
}

struct TransactionItem: Codable {
    let medicine: String
    let quantity: Int
    let unitPrice: TransactionAmount
    let totalPrice: TransactionAmount
    let batchNumber: String?
    let expiryDate: String?
}

struct CreateTransactionRequest: Codable {
    let type: TransactionType
    let seller: TransactionParty
    let buyer: TransactionParty
    let items: [TransactionItem]
    let totalAmount: TransactionAmount
    let paymentMethod: PaymentMethod
    let notes: String?
    let transactionId: String
}

// MARK: - Notification Response Models
struct NotificationResponse: Codable {
    let success: Bool
    let data: [NotificationModel]
    let pagination: NotificationPagination?
}

struct NotificationPagination: Codable {
    let current: Int
    let total: Int
    let count: Int
    let totalItems: Int
    let unreadCount: Int
}

struct NotificationStatsResponse: Codable {
    let success: Bool
    let data: NotificationStats
}

struct NotificationStats: Codable {
    let total: Int
    let unread: Int
    let read: Int
    let byType: [String: Int]
    let recent: RecentStats
}

struct RecentStats: Codable {
    let today: Int
    let thisWeek: Int
    let thisMonth: Int
}