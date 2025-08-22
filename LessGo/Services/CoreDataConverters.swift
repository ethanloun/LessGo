import Foundation
import CoreData

// MARK: - Model Converters
// These extensions help convert between your existing Swift models and Core Data entities

extension CDUser {
    /// Convert CDUser to the User struct
    func toUser() -> User {
        var user = User(
            id: self.id ?? "",
            email: self.email ?? "",
            displayName: self.displayName ?? ""
        )
        
        user.phoneNumber = self.phoneNumber
        user.profileImageURL = self.profileImageURL
        user.bio = self.bio
        user.isVerified = self.isVerified
        user.verificationDate = self.verificationDate
        user.rating = self.rating
        user.totalReviews = Int(self.totalReviews)
        user.dateJoined = self.dateJoined ?? Date()
        user.lastActive = self.lastActive ?? Date()
        user.isBlocked = self.isBlocked
        user.blockedUsers = self.blockedUsers ?? []
        
        // Convert badges from String array to Badge enum array
        if let badgeStrings = self.badges {
            user.badges = badgeStrings.compactMap { Badge(rawValue: $0) }
        }
        
        // Convert location if available
        if self.locationName != nil {
            user.location = Location(
                latitude: self.latitude,
                longitude: self.longitude,
                address: self.locationAddress ?? "",
                city: self.locationCity ?? ""
            )
        }
        
        return user
    }
    
    /// Update CDUser from User struct
    func update(from user: User) {
        self.id = user.id
        self.email = user.email
        self.displayName = user.displayName
        self.phoneNumber = user.phoneNumber
        self.profileImageURL = user.profileImageURL
        self.bio = user.bio
        self.isVerified = user.isVerified
        self.verificationDate = user.verificationDate
        self.rating = user.rating
        self.totalReviews = Int32(user.totalReviews)
        self.dateJoined = user.dateJoined
        self.lastActive = user.lastActive
        self.isBlocked = user.isBlocked
        self.blockedUsers = user.blockedUsers
        
        // Convert badges to string array
        self.badges = user.badges.map { $0.rawValue }
        
        // Convert location
        if let location = user.location {
            self.locationName = location.address
            self.locationAddress = location.address
            self.locationCity = location.city
            self.latitude = location.latitude ?? 0.0
            self.longitude = location.longitude ?? 0.0
        }
    }
}

// MARK: - CDChat Extensions
extension CDChat {
    /// Convert CDChat to the Chat struct
    func toChat() -> Chat {
        var chat = Chat(
            id: self.id ?? UUID().uuidString,
            participants: self.participants as? [String] ?? []
        )
        
        // Note: listingId is a let constant, so we can't modify it after creation
        // This will need to be handled in the Chat initializer if needed
        chat.updatedAt = self.lastMessageAt ?? Date()
        
        return chat
    }
    
    /// Update CDChat from Chat struct
    func update(from chat: Chat) {
        self.id = chat.id
        self.participants = chat.participants
        self.lastMessageAt = chat.updatedAt
    }
}

extension CDListing {
    /// Convert CDListing to the Listing struct
    func toListing() -> Listing {
        var listing = Listing(
            id: self.id ?? "",
            sellerId: self.sellerId ?? "",
            title: self.title ?? "",
            description: self.desc ?? "",
            price: self.price,
            category: Category(rawValue: self.category ?? "other") ?? .other,
            condition: ItemCondition(rawValue: self.condition ?? "good") ?? .good,
            location: Location(
                latitude: self.latitude,
                longitude: self.longitude,
                address: self.locationAddress ?? "",
                city: self.locationCity ?? ""
            )
        )
        
        listing.originalPrice = self.originalPrice > 0 ? self.originalPrice : nil
        listing.images = self.images ?? []
        listing.isActive = self.isActive
        listing.isSold = self.isSold
        listing.isFeatured = self.isFeatured
        listing.views = Int(self.views)
        listing.favorites = Int(self.favorites)
        listing.createdAt = self.createdAt ?? Date()
        listing.updatedAt = self.updatedAt ?? Date()
        listing.expiresAt = self.expiresAt
        listing.tags = self.tags ?? []
        listing.isNegotiable = self.isNegotiable
        listing.pickupOnly = self.pickupOnly
        listing.shippingAvailable = self.shippingAvailable
        listing.shippingCost = self.shippingCost > 0 ? self.shippingCost : nil
        listing.quantity = Int(self.quantity)
        listing.brand = self.brand
        listing.model = self.model
        listing.deliveryRadius = self.deliveryRadius > 0 ? self.deliveryRadius : nil
        listing.isDraft = self.isDraft
        
        return listing
    }
    
    /// Update CDListing from Listing struct
    func update(from listing: Listing) {
        self.id = listing.id
        self.sellerId = listing.sellerId
        self.title = listing.title
        self.desc = listing.description
        self.price = listing.price
        self.originalPrice = listing.originalPrice ?? 0.0
        self.category = listing.category.rawValue
        self.condition = listing.condition.rawValue
        self.images = listing.images
        self.isActive = listing.isActive
        self.isSold = listing.isSold
        self.isFeatured = listing.isFeatured
        self.views = Int32(listing.views)
        self.favorites = Int32(listing.favorites)
        self.createdAt = listing.createdAt
        self.updatedAt = listing.updatedAt
        self.expiresAt = listing.expiresAt
        self.tags = listing.tags
        self.isNegotiable = listing.isNegotiable
        self.pickupOnly = listing.pickupOnly
        self.shippingAvailable = listing.shippingAvailable
        self.shippingCost = listing.shippingCost ?? 0.0
        self.quantity = Int32(listing.quantity)
        self.brand = listing.brand
        self.model = listing.model
        self.deliveryRadius = listing.deliveryRadius ?? 0.0
        self.isDraft = listing.isDraft
        
        // Location
        self.locationName = listing.location.address
        self.locationAddress = listing.location.address
        self.locationCity = listing.location.city
        self.latitude = listing.location.latitude ?? 0.0
        self.longitude = listing.location.longitude ?? 0.0
    }
}

extension CDMessage {
    /// Convert CDMessage to the Message struct
    func toMessage() -> Message {
        var message = Message(
            id: self.id ?? "",
            chatId: self.chatId ?? "",
            senderId: self.senderId ?? "",
            receiverId: self.receiverId ?? "",
            content: self.content ?? "",
            messageType: MessageType(rawValue: self.messageType ?? "text") ?? .text,
            imageURL: self.imageURL
        )
        
        message.isRead = self.isRead
        message.isDelivered = self.isDelivered
        message.readAt = self.readAt
        message.deliveredAt = self.deliveredAt
        message.thumbnailURL = self.thumbnailURL
        
        return message
    }
    
    /// Update CDMessage from Message struct
    func update(from message: Message) {
        self.id = message.id
        self.chatId = message.chatId
        self.senderId = message.senderId
        self.receiverId = message.receiverId
        self.content = message.content
        self.messageType = message.messageType.rawValue
        self.imageURL = message.imageURL
        self.thumbnailURL = message.thumbnailURL
        self.timestamp = message.timestamp
        self.isRead = message.isRead
        self.isDelivered = message.isDelivered
        self.readAt = message.readAt
        self.deliveredAt = message.deliveredAt
    }
}

// MARK: - PersistenceController Extensions for Model Conversion
extension PersistenceController {
    
    /// Save or update a User
    func saveUser(_ user: User) -> CDUser {
        if let existingUser = findUser(by: user.id) {
            existingUser.update(from: user)
            save()
            return existingUser
        } else {
            let cdUser = CDUser(context: viewContext)
            cdUser.update(from: user)
            save()
            return cdUser
        }
    }
    
    /// Save or update a Listing
    func saveListing(_ listing: Listing) -> CDListing {
        if let existingListing = findListing(by: listing.id) {
            existingListing.update(from: listing)
            save()
            return existingListing
        } else {
            let cdListing = CDListing(context: viewContext)
            cdListing.update(from: listing)
            save()
            return cdListing
        }
    }
    
    /// Save a Message
    func saveMessage(_ message: Message) -> CDMessage {
        let cdMessage = CDMessage(context: viewContext)
        cdMessage.update(from: message)
        save()
        return cdMessage
    }
    
    /// Fetch all users as User structs
    func fetchUsersAsStructs() -> [User] {
        return fetchUsers().map { $0.toUser() }
    }
    
    /// Fetch all listings as Listing structs
    func fetchListingsAsStructs() -> [Listing] {
        return fetchListings().map { $0.toListing() }
    }
    
    /// Fetch active listings as Listing structs
    func fetchActiveListingsAsStructs() -> [Listing] {
        return fetchActiveListings().map { $0.toListing() }
    }
    
    /// Fetch messages for a chat as Message structs
    func fetchMessagesAsStructs(for chatId: String) -> [Message] {
        return fetchMessages(for: chatId).map { $0.toMessage() }
    }
}
