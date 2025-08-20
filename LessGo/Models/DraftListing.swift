import Foundation

struct DraftListing: Identifiable, Codable {
    let id: String
    let sellerId: String
    var title: String
    var description: String
    var price: Double
    var category: Category?
    var condition: ItemCondition?
    var images: [String] // URLs
    var location: Location?
    var tags: [String]
    var isNegotiable: Bool
    var pickupOnly: Bool
    var shippingAvailable: Bool
    var shippingCost: Double?
    var quantity: Int
    var brand: String?
    var model: String?
    var deliveryRadius: Double?
    var createdAt: Date
    var updatedAt: Date
    var expiresAt: Date?
    
    init(id: String, sellerId: String) {
        self.id = id
        self.sellerId = sellerId
        self.title = ""
        self.description = ""
        self.price = 0.0
        self.category = nil
        self.condition = nil
        self.images = []
        self.location = nil
        self.tags = []
        self.isNegotiable = true
        self.pickupOnly = true
        self.shippingAvailable = false
        self.shippingCost = nil
        self.quantity = 1
        self.brand = nil
        self.model = nil
        self.deliveryRadius = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.expiresAt = Calendar.current.date(byAdding: .day, value: 30, to: Date())
    }
    
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
    
    var daysUntilExpiry: Int {
        guard let expiresAt = expiresAt else { return 0 }
        return Calendar.current.dateComponents([.day], from: Date(), to: expiresAt).day ?? 0
    }
    
    var canBePosted: Bool {
        return !title.isEmpty && 
               !description.isEmpty && 
               price > 0 && 
               category != nil && 
               condition != nil && 
               images.count >= 1 &&
               location != nil
    }
    
    var validationErrors: [String] {
        var errors: [String] = []
        
        if title.isEmpty {
            errors.append("Title is required")
        } else if title.count > 60 {
            errors.append("Title must be 60 characters or less")
        }
        
        if description.isEmpty {
            errors.append("Description is required")
        } else if description.count > 1000 {
            errors.append("Description must be 1000 characters or less")
        }
        
        if price <= 0 {
            errors.append("Price must be greater than $0")
        }
        
        if category == nil {
            errors.append("Category is required")
        }
        
        if condition == nil {
            errors.append("Item condition is required")
        }
        
        if images.count < 1 {
            errors.append("At least one photo is required")
        }
        
        if location == nil {
            errors.append("Location is required")
        }
        
        return errors
    }
}
