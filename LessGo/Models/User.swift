import Foundation
import CoreLocation

struct User: Identifiable, Codable {
    let id: String
    var email: String
    var displayName: String
    var phoneNumber: String?
    var profileImageURL: String?
    var bio: String?
    var location: Location?
    var isVerified: Bool
    var verificationDate: Date?
    var rating: Double
    var totalReviews: Int
    var badges: [Badge]
    var dateJoined: Date
    var lastActive: Date
    var isBlocked: Bool
    var blockedUsers: [String]
    
    init(id: String, email: String, displayName: String) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.isVerified = false
        self.rating = 0.0
        self.totalReviews = 0
        self.badges = []
        self.dateJoined = Date()
        self.lastActive = Date()
        self.isBlocked = false
        self.blockedUsers = []
    }
}

enum Badge: String, CaseIterable, Codable {
    case verified = "verified"
    case topSeller = "top_seller"
    case quickResponder = "quick_responder"
    case trusted = "trusted"
    case newUser = "new_user"
    
    var displayName: String {
        switch self {
        case .verified: return "Verified"
        case .topSeller: return "Top Seller"
        case .quickResponder: return "Quick Responder"
        case .trusted: return "Trusted"
        case .newUser: return "New User"
        }
    }
    
    var iconName: String {
        switch self {
        case .verified: return "checkmark.seal.fill"
        case .topSeller: return "star.fill"
        case .quickResponder: return "bolt.fill"
        case .trusted: return "shield.fill"
        case .newUser: return "person.badge.plus"
        }
    }
}

