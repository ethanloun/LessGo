import CoreData
import Foundation

// MARK: - Core Data Helper Functions
extension PersistenceController {
    
    // MARK: - User Management
    func addUser(id: String, email: String, displayName: String, phoneNumber: String? = nil, bio: String? = nil) -> CDUser {
        let user = CDUser(context: viewContext)
        user.id = id
        user.email = email
        user.displayName = displayName
        user.phoneNumber = phoneNumber
        user.bio = bio
        user.dateJoined = Date()
        user.lastActive = Date()
        user.rating = 0.0
        user.totalReviews = 0
        user.isVerified = false
        user.isBlocked = false
        user.badges = []
        user.blockedUsers = []
        
        save()
        return user
    }
    
    func fetchUsers() -> [CDUser] {
        let request: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDUser.displayName, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching users: \(error)")
            return []
        }
    }
    
    func findUser(by id: String) -> CDUser? {
        let request: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let users = try viewContext.fetch(request)
            return users.first
        } catch {
            print("Error finding user: \(error)")
            return nil
        }
    }
    
    func deleteUser(_ user: CDUser) {
        viewContext.delete(user)
        save()
    }
    
    // MARK: - Listing Management
    func addListing(
        id: String,
        sellerId: String,
        title: String,
        description: String,
        price: Double,
        category: String,
        condition: String,
        images: [String] = [],
        latitude: Double = 0.0,
        longitude: Double = 0.0,
        locationName: String? = nil,
        locationAddress: String? = nil,
        locationCity: String? = nil,
        isNegotiable: Bool = true,
        pickupOnly: Bool = true,
        shippingAvailable: Bool = false,
        shippingCost: Double = 0.0,
        quantity: Int = 1,
        tags: [String] = [],
        brand: String? = nil,
        model: String? = nil
    ) -> CDListing {
        let listing = CDListing(context: viewContext)
        listing.id = id
        listing.sellerId = sellerId
        listing.title = title
        listing.desc = description
        listing.price = price
        listing.category = category
        listing.condition = condition
        listing.images = images
        listing.latitude = latitude
        listing.longitude = longitude
        listing.locationName = locationName
        listing.locationAddress = locationAddress
        listing.locationCity = locationCity
        listing.isActive = true
        listing.isSold = false
        listing.isFeatured = false
        listing.isDraft = false
        listing.isNegotiable = isNegotiable
        listing.pickupOnly = pickupOnly
        listing.shippingAvailable = shippingAvailable
        listing.shippingCost = shippingCost
        listing.quantity = Int32(quantity)
        listing.tags = tags
        listing.brand = brand
        listing.model = model
        listing.views = 0
        listing.favorites = 0
        listing.createdAt = Date()
        listing.updatedAt = Date()
        
        save()
        return listing
    }
    
    func fetchListings() -> [CDListing] {
        let request: NSFetchRequest<CDListing> = CDListing.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDListing.createdAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching listings: \(error)")
            return []
        }
    }
    
    func fetchActiveListings() -> [CDListing] {
        let request: NSFetchRequest<CDListing> = CDListing.fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES AND isSold == NO")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDListing.createdAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching active listings: \(error)")
            return []
        }
    }
    
    func fetchListings(for sellerId: String) -> [CDListing] {
        let request: NSFetchRequest<CDListing> = CDListing.fetchRequest()
        request.predicate = NSPredicate(format: "sellerId == %@", sellerId)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDListing.createdAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching user listings: \(error)")
            return []
        }
    }
    
    func findListing(by id: String) -> CDListing? {
        let request: NSFetchRequest<CDListing> = CDListing.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let listings = try viewContext.fetch(request)
            return listings.first
        } catch {
            print("Error finding listing: \(error)")
            return nil
        }
    }
    
    func fetchListings(for user: CDUser) -> [CDListing] {
        let request: NSFetchRequest<CDListing> = CDListing.fetchRequest()
        request.predicate = NSPredicate(format: "owner == %@", user)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDListing.createdAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching user listings: \(error)")
            return []
        }
    }
    
    func deleteListing(_ listing: CDListing) {
        viewContext.delete(listing)
        save()
    }
    
    // MARK: - Message Management
    func sendMessage(
        id: String,
        chatId: String,
        senderId: String,
        receiverId: String,
        content: String,
        messageType: String = "text",
        imageURL: String? = nil,
        thumbnailURL: String? = nil
    ) -> CDMessage {
        let message = CDMessage(context: viewContext)
        message.id = id
        message.chatId = chatId
        message.senderId = senderId
        message.receiverId = receiverId
        message.content = content
        message.messageType = messageType
        message.imageURL = imageURL
        message.thumbnailURL = thumbnailURL
        message.timestamp = Date()
        message.isRead = false
        message.isDelivered = false
        
        save()
        return message
    }
    
    func fetchMessages(for chatId: String) -> [CDMessage] {
        let request: NSFetchRequest<CDMessage> = CDMessage.fetchRequest()
        request.predicate = NSPredicate(format: "chatId == %@", chatId)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDMessage.timestamp, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching messages: \(error)")
            return []
        }
    }
    
    func fetchMessages(for listing: CDListing) -> [CDMessage] {
        let request: NSFetchRequest<CDMessage> = CDMessage.fetchRequest()
        request.predicate = NSPredicate(format: "listing == %@", listing)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDMessage.timestamp, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching messages: \(error)")
            return []
        }
    }
    
    func markMessageAsRead(_ message: CDMessage) {
        message.isRead = true
        message.readAt = Date()
        save()
    }
    
    func markMessageAsDelivered(_ message: CDMessage) {
        message.isDelivered = true
        message.deliveredAt = Date()
        save()
    }
    
    func fetchMessages(for user: CDUser) -> [CDMessage] {
        let request: NSFetchRequest<CDMessage> = CDMessage.fetchRequest()
        request.predicate = NSPredicate(format: "sender == %@", user)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDMessage.timestamp, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching user messages: \(error)")
            return []
        }
    }
    
    func deleteMessage(_ message: CDMessage) {
        viewContext.delete(message)
        save()
    }
    
    // MARK: - Search and Filter
    func searchListings(query: String) -> [CDListing] {
        let request: NSFetchRequest<CDListing> = CDListing.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR desc CONTAINS[cd] %@", query, query)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDListing.createdAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error searching listings: \(error)")
            return []
        }
    }
    
    func fetchListingsByPriceRange(minPrice: Double, maxPrice: Double) -> [CDListing] {
        let request: NSFetchRequest<CDListing> = CDListing.fetchRequest()
        request.predicate = NSPredicate(format: "price >= %f AND price <= %f", minPrice, maxPrice)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDListing.price, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching listings by price range: \(error)")
            return []
        }
    }
    
    // MARK: - Statistics
    func getUserStats(for user: CDUser) -> (totalListings: Int, totalMessages: Int, averageRating: Double) {
        let listings = fetchListings(for: user)
        let messages = fetchMessages(for: user)
        let avgRating = user.rating
        
        return (listings.count, messages.count, avgRating)
    }
    
    func getListingStats(for listing: CDListing) -> (totalMessages: Int, daysActive: Int) {
        let messages = fetchMessages(for: listing)
        let daysActive = Calendar.current.dateComponents([.day], from: listing.createdAt ?? Date(), to: Date()).day ?? 0
        
        return (messages.count, daysActive)
    }
}
