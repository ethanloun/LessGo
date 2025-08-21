import CoreData
import Foundation

// MARK: - Core Data Extensions for Better Swift Experience

extension NSManagedObject {
    /// Convenience method to check if the object has been deleted
    var isDeleted: Bool {
        return managedObjectContext == nil
    }
    
    /// Safe way to access optional attributes
    func safeString(for key: String) -> String? {
        return value(forKey: key) as? String
    }
    
    func safeDouble(for key: String) -> Double {
        return value(forKey: key) as? Double ?? 0.0
    }
    
    func safeDate(for key: String) -> Date? {
        return value(forKey: key) as? Date
    }
    
    func safeData(for key: String) -> Data? {
        return value(forKey: key) as? Data
    }
}

// MARK: - CDUser Extensions
extension CDUser {
    /// Computed property for formatted join date
    var formattedJoinDate: String {
        guard let dateJoined = dateJoined else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dateJoined)
    }
    
    /// Computed property for rating display
    var ratingDisplay: String {
        return String(format: "%.1f", rating)
    }
    
    /// Check if user is new (joined within last 7 days)
    var isNewUser: Bool {
        guard let dateJoined = dateJoined else { return false }
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return dateJoined > sevenDaysAgo
    }
    
    /// Get user's listing count
    var listingCount: Int {
        return listings?.count ?? 0
    }
    
    /// Get user's message count
    var messageCount: Int {
        return messages?.count ?? 0
    }
}

// MARK: - CDListing Extensions
extension CDListing {
    /// Computed property for formatted price
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
    
    /// Computed property for formatted timestamp
    var formattedTimestamp: String {
        guard let createdAt = createdAt else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    /// Computed property for relative timestamp
    var relativeTimestamp: String {
        guard let createdAt = createdAt else { return "Unknown" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    /// Check if listing is recent (created within last 24 hours)
    var isRecent: Bool {
        guard let createdAt = createdAt else { return false }
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return createdAt > oneDayAgo
    }
    
    /// Get listing's message count
    var messageCount: Int {
        return messages?.count ?? 0
    }
    
    /// Get owner's username safely
    var ownerUsername: String {
        return owner?.displayName ?? "Unknown Owner"
    }
    
    /// Get owner's email safely
    var ownerEmail: String {
        return owner?.email ?? "No email"
    }
    
    /// Check if listing is active and not sold
    var isAvailable: Bool {
        return isActive && !isSold
    }
    
    /// Get formatted location string
    var locationString: String {
        if let city = locationCity, !city.isEmpty {
            return city
        } else if let address = locationAddress, !address.isEmpty {
            return address
        } else {
            return "Location not specified"
        }
    }
}

// MARK: - CDMessage Extensions
extension CDMessage {
    /// Computed property for formatted timestamp
    var formattedTimestamp: String {
        guard let timestamp = timestamp else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    /// Computed property for relative timestamp
    var relativeTimestamp: String {
        guard let timestamp = timestamp else { return "Unknown" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    /// Get sender's username safely
    var senderUsername: String {
        return sender?.displayName ?? "Unknown Sender"
    }
    
    /// Get listing title safely
    var listingTitle: String {
        return listing?.title ?? "Unknown Listing"
    }
    
    /// Check if message is recent (within last hour)
    var isRecent: Bool {
        guard let timestamp = timestamp else { return false }
        let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
        return timestamp > oneHourAgo
    }
}

// MARK: - Fetch Request Extensions
extension NSFetchRequest where ResultType == CDUser {
    /// Convenience initializer for CDUser fetch requests
    static func users(sortedBy sortDescriptors: [NSSortDescriptor] = []) -> NSFetchRequest<CDUser> {
        let request = NSFetchRequest<CDUser>(entityName: "CDUser")
        request.sortDescriptors = sortDescriptors
        return request
    }
}

extension NSFetchRequest where ResultType == CDListing {
    /// Convenience initializer for CDListing fetch requests
    static func listings(sortedBy sortDescriptors: [NSSortDescriptor] = []) -> NSFetchRequest<CDListing> {
        let request = NSFetchRequest<CDListing>(entityName: "CDListing")
        request.sortDescriptors = sortDescriptors
        return request
    }
}

extension NSFetchRequest where ResultType == CDMessage {
    /// Convenience initializer for CDMessage fetch requests
    static func messages(sortedBy sortDescriptors: [NSSortDescriptor] = []) -> NSFetchRequest<CDMessage> {
        let request = NSFetchRequest<CDMessage>(entityName: "CDMessage")
        request.sortDescriptors = sortDescriptors
        return request
    }
}

// MARK: - Error Handling Extensions
extension Error {
    /// User-friendly error message for Core Data errors
    var userFriendlyMessage: String {
        if let coreDataError = self as? NSError {
            switch coreDataError.code {
            case NSManagedObjectValidationError:
                return "Invalid data provided. Please check your input and try again."
            case NSManagedObjectConstraintValidationError:
                return "This item already exists. Please use a different value."
            case NSManagedObjectContextLockingError:
                return "Database is busy. Please try again in a moment."
            case NSPersistentStoreIncompatibleVersionHashError:
                return "Database version mismatch. Please restart the app."
            default:
                return "An unexpected error occurred. Please try again."
            }
        }
        return localizedDescription
    }
}

// MARK: - Batch Operations
extension PersistenceController {
    /// Perform batch operations with error handling
    func performBatchOperation<T>(_ operation: () throws -> T) throws -> T {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        var result: T?
        var operationError: Error?
        
        context.performAndWait {
            do {
                result = try operation()
                try context.save()
            } catch {
                operationError = error
            }
        }
        
        if let error = operationError {
            throw error
        }
        
        guard let result = result else {
            throw NSError(domain: "CoreDataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Batch operation failed"])
        }
        
        return result
    }
}
