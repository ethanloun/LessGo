import Foundation

struct Review: Identifiable, Codable {
    let id: String
    let reviewerId: String
    let reviewedUserId: String
    let listingId: String?
    let rating: Int
    let title: String?
    let comment: String
    let timestamp: Date
    var isVerified: Bool
    
    init(id: String, reviewerId: String, reviewedUserId: String, rating: Int, comment: String, listingId: String? = nil, title: String? = nil) {
        self.id = id
        self.reviewerId = reviewerId
        self.reviewedUserId = reviewedUserId
        self.rating = max(1, min(5, rating)) // Ensure rating is between 1-5
        self.comment = comment
        self.listingId = listingId
        self.title = title
        self.timestamp = Date()
        self.isVerified = false
    }
    
    var ratingDescription: String {
        switch rating {
        case 1: return "Poor"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Very Good"
        case 5: return "Excellent"
        default: return "Unknown"
        }
    }
}

struct NotificationItem: Identifiable, Codable {
    let id: String
    let userId: String
    let type: NotificationType
    let title: String
    let message: String
    let data: [String: String]?
    let timestamp: Date
    var isRead: Bool
    
    init(id: String, userId: String, type: NotificationType, title: String, message: String, data: [String: String]? = nil) {
        self.id = id
        self.userId = userId
        self.type = type
        self.title = title
        self.message = message
        self.data = data
        self.timestamp = Date()
        self.isRead = false
    }
}

enum NotificationType: String, Codable {
    case message = "message"
    case offer = "offer"
    case listing = "listing"
    case review = "review"
    case system = "system"
    
    var iconName: String {
        switch self {
        case .message: return "message"
        case .offer: return "dollarsign.circle"
        case .listing: return "tag"
        case .review: return "star"
        case .system: return "bell"
        }
    }
}

