import Foundation

struct Listing: Identifiable, Codable {
    let id: String
    let sellerId: String
    var title: String
    var description: String
    var price: Double
    var originalPrice: Double?
    var category: Category
    var condition: ItemCondition
    var images: [String] // URLs
    var location: Location
    var isActive: Bool
    var isSold: Bool
    var isFeatured: Bool
    var views: Int
    var favorites: Int
    var createdAt: Date
    var updatedAt: Date
    var expiresAt: Date?
    var tags: [String]
    var isNegotiable: Bool
    var pickupOnly: Bool
    var shippingAvailable: Bool
    var shippingCost: Double?
    var quantity: Int
    var brand: String?
    var model: String?
    var deliveryRadius: Double?
    var isDraft: Bool
    
    init(id: String, sellerId: String, title: String, description: String, price: Double, category: Category, condition: ItemCondition, location: Location) {
        self.id = id
        self.sellerId = sellerId
        self.title = title
        self.description = description
        self.price = price
        self.category = category
        self.condition = condition
        self.location = location
        self.images = []
        self.isActive = true
        self.isSold = false
        self.isFeatured = false
        self.views = 0
        self.favorites = 0
        self.createdAt = Date()
        self.updatedAt = Date()
        self.tags = []
        self.isNegotiable = true
        self.pickupOnly = true
        self.shippingAvailable = false
        self.quantity = 1
        self.brand = nil
        self.model = nil
        self.deliveryRadius = nil
        self.isDraft = false
    }
    
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
    
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
    
    var daysSinceCreated: Int {
        return Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
    }
}

enum Category: String, CaseIterable, Codable {
    case electronics = "electronics"
    case clothing = "clothing"
    case home = "home"
    case sports = "sports"
    case books = "books"
    case vehicles = "vehicles"
    case furniture = "furniture"
    case toys = "toys"
    case beauty = "beauty"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .electronics: return "Electronics"
        case .clothing: return "Clothing"
        case .home: return "Home & Garden"
        case .sports: return "Sports & Outdoors"
        case .books: return "Books & Media"
        case .vehicles: return "Vehicles"
        case .furniture: return "Furniture"
        case .toys: return "Toys & Games"
        case .beauty: return "Beauty & Health"
        case .other: return "Other"
        }
    }
    
    var iconName: String {
        switch self {
        case .electronics: return "laptopcomputer"
        case .clothing: return "tshirt"
        case .home: return "house"
        case .sports: return "sportscourt"
        case .books: return "book"
        case .vehicles: return "car"
        case .furniture: return "bed.double"
        case .toys: return "gamecontroller"
        case .beauty: return "sparkles"
        case .other: return "ellipsis.circle"
        }
    }
}

enum ItemCondition: String, CaseIterable, Codable {
    case new = "new"
    case likeNew = "like_new"
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"
    
    var displayName: String {
        switch self {
        case .new: return "New"
        case .likeNew: return "Like New"
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .fair: return "Fair"
        case .poor: return "Poor"
        }
    }
    
    var color: String {
        switch self {
        case .new: return "green"
        case .likeNew: return "blue"
        case .excellent: return "cyan"
        case .good: return "yellow"
        case .fair: return "orange"
        case .poor: return "red"
        }
    }
}

