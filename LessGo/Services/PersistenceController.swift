import CoreData
import Foundation

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: "LessGo")
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                // Handle migration issues by deleting and recreating the store
                if error.localizedDescription.contains("migration") || error.localizedDescription.contains("mapping model") {
                    print("Migration error detected. Deleting and recreating store...")
                    self.deleteAndRecreateStore()
                } else {
                    fatalError("Failed to load Core Data stack: \(error.localizedDescription)")
                }
            }
        }
        
        // Configure the view context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Preview Helper
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Create sample data for previews
        let sampleUser = CDUser(context: viewContext)
        sampleUser.id = "preview_user_1"
        sampleUser.displayName = "John Doe"
        sampleUser.email = "john@example.com"
        sampleUser.dateJoined = Date()
        sampleUser.rating = 4.5
        sampleUser.isVerified = false
        sampleUser.isBlocked = false
        sampleUser.totalReviews = 0
        sampleUser.badges = []
        sampleUser.blockedUsers = []
        
        let sampleListing = CDListing(context: viewContext)
        sampleListing.id = "preview_listing_1"
        sampleListing.title = "iPhone 13 Pro"
        sampleListing.desc = "Excellent condition, barely used"
        sampleListing.price = 799.99
        sampleListing.category = "electronics"
        sampleListing.condition = "excellent"
        sampleListing.sellerId = "preview_user_1"
        sampleListing.isActive = true
        sampleListing.isSold = false
        sampleListing.isFeatured = false
        sampleListing.isDraft = false
        sampleListing.views = 0
        sampleListing.favorites = 0
        sampleListing.createdAt = Date()
        sampleListing.updatedAt = Date()
        sampleListing.owner = sampleUser
        
        let sampleMessage = CDMessage(context: viewContext)
        sampleMessage.id = "preview_message_1"
        sampleMessage.content = "Is this still available?"
        sampleMessage.chatId = "preview_chat_1"
        sampleMessage.senderId = "preview_user_1"
        sampleMessage.receiverId = "preview_user_2"
        sampleMessage.messageType = "text"
        sampleMessage.timestamp = Date()
        sampleMessage.isRead = false
        sampleMessage.isDelivered = false
        sampleMessage.sender = sampleUser
        sampleMessage.listing = sampleListing
        
        do {
            try viewContext.save()
        } catch {
            fatalError("Failed to create preview data: \(error.localizedDescription)")
        }
        
        return controller
    }()
    
    // MARK: - In-Memory Initializer for Testing
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "LessGo")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Save Context
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - Migration Helper
    private func deleteAndRecreateStore() {
        guard let storeURL = container.persistentStoreDescriptions.first?.url else {
            return
        }
        
        do {
            // Delete the existing store files
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: storeURL.path) {
                try fileManager.removeItem(at: storeURL)
            }
            
            // Remove related files (-wal, -shm)
            let walURL = storeURL.appendingPathExtension("wal")
            let shmURL = storeURL.appendingPathExtension("shm")
            
            if fileManager.fileExists(atPath: walURL.path) {
                try fileManager.removeItem(at: walURL)
            }
            
            if fileManager.fileExists(atPath: shmURL.path) {
                try fileManager.removeItem(at: shmURL)
            }
            
            print("Deleted existing Core Data store files")
            
            // Recreate the store
            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Failed to recreate Core Data store: \(error.localizedDescription)")
                } else {
                    print("Successfully recreated Core Data store")
                }
            }
            
        } catch {
            print("Error deleting store: \(error.localizedDescription)")
            fatalError("Could not delete and recreate store")
        }
    }
}
