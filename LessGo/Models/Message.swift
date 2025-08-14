import Foundation

struct Message: Identifiable, Codable {
    let id: String
    let chatId: String
    let senderId: String
    let receiverId: String
    let content: String
    let messageType: MessageType
    let timestamp: Date
    var isRead: Bool
    var isDelivered: Bool
    
    init(id: String, chatId: String, senderId: String, receiverId: String, content: String, messageType: MessageType = .text) {
        self.id = id
        self.chatId = chatId
        self.senderId = senderId
        self.receiverId = receiverId
        self.content = content
        self.messageType = messageType
        self.timestamp = Date()
        self.isRead = false
        self.isDelivered = false
    }
}

enum MessageType: String, Codable {
    case text = "text"
    case image = "image"
    case offer = "offer"
    case location = "location"
    
    var displayName: String {
        switch self {
        case .text: return "Text"
        case .image: return "Image"
        case .offer: return "Offer"
        case .location: return "Location"
        }
    }
}

struct Chat: Identifiable, Codable {
    let id: String
    let participants: [String]
    let listingId: String?
    let lastMessage: Message?
    let createdAt: Date
    var updatedAt: Date
    
    init(id: String, participants: [String], listingId: String? = nil) {
        self.id = id
        self.participants = participants
        self.listingId = listingId
        self.lastMessage = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct Offer: Identifiable, Codable {
    let id: String
    let chatId: String
    let senderId: String
    let receiverId: String
    let amount: Double
    let message: String?
    let timestamp: Date
    var status: OfferStatus
    
    init(id: String, chatId: String, senderId: String, receiverId: String, amount: Double, message: String? = nil) {
        self.id = id
        self.chatId = chatId
        self.senderId = senderId
        self.receiverId = receiverId
        self.amount = amount
        self.message = message
        self.timestamp = Date()
        self.status = .pending
    }
    
    var formattedAmount: String {
        return String(format: "$%.2f", amount)
    }
}

enum OfferStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
    case expired = "expired"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .accepted: return "Accepted"
        case .declined: return "Declined"
        case .expired: return "Expired"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .accepted: return "green"
        case .declined: return "red"
        case .expired: return "gray"
        }
    }
}

