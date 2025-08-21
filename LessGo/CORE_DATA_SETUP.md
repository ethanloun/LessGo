# Core Data Setup for LessGo Reselling App

This document outlines the Core Data implementation for the LessGo reselling app, providing local data persistence for users, listings, and messages.

## Overview

The Core Data setup includes:
- **PersistenceController**: Singleton managing the Core Data stack
- **Three Core Data Entities**: CDUser, CDListing, and CDMessage
- **Helper Functions**: CRUD operations and data management
- **SwiftUI Views**: Demo views showcasing Core Data functionality
- **Extensions**: Swift-friendly extensions for better developer experience

## Core Data Model

### Entity: CDUser
- `id`: UUID (primary key)
- `username`: String
- `email`: String
- `joinDate`: Date
- `rating`: Double
- **Relationships**:
  - `listings`: One-to-many with CDListing (cascade delete)
  - `messages`: One-to-many with CDMessage (cascade delete)

### Entity: CDListing
- `id`: UUID (primary key)
- `title`: String
- `desc`: String
- `price`: Double
- `image`: Binary Data (with external storage)
- `timestamp`: Date
- **Relationships**:
  - `owner`: To-one with CDUser (nullify delete)
  - `messages`: One-to-many with CDMessage (cascade delete)

### Entity: CDMessage
- `id`: UUID (primary key)
- `content`: String
- `timestamp`: Date
- **Relationships**:
  - `sender`: To-one with CDUser (nullify delete)
  - `listing`: To-one with CDListing (nullify delete)

## Key Components

### 1. PersistenceController
```swift
class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext { container.viewContext }
}
```

**Features**:
- Singleton pattern for app-wide access
- Automatic context merging
- Preview data generation for SwiftUI previews
- In-memory storage option for testing

### 2. Core Data Helper Functions
Located in `CoreDataHelpers.swift`, these functions provide:

**User Management**:
- `addUser(username:email:rating:)` → CDUser
- `fetchUsers()` → [CDUser]
- `deleteUser(_:)` → Void

**Listing Management**:
- `addListing(title:desc:price:image:owner:)` → CDListing
- `fetchListings()` → [CDListing]
- `fetchListings(for:)` → [CDListing]
- `deleteListing(_:)` → Void

**Message Management**:
- `sendMessage(content:sender:listing:)` → CDMessage
- `fetchMessages(for:)` → [CDMessage]
- `deleteMessage(_:)` → Void

**Search & Filter**:
- `searchListings(query:)` → [CDListing]
- `fetchListingsByPriceRange(min:max:)` → [CDListing]

### 3. SwiftUI Views

#### ListingsView
- Displays all listings with search functionality
- Shows title, description, price, and owner
- Supports deletion with swipe actions
- Navigation to add new listings

#### UsersView
- Lists all registered users
- Shows user stats (listings, messages, rating)
- Search and filter capabilities
- User management actions

#### MessagesView
- Displays messages for a specific listing
- Real-time message sending
- User selection for message attribution
- Chronological message display

#### AddUserView & AddListingView
- Form-based entity creation
- Input validation
- Preview functionality
- Image handling for listings

### 4. Core Data Extensions
Located in `CoreDataExtensions.swift`, providing:

**Safe Property Access**:
```swift
extension NSManagedObject {
    func safeString(for key: String) -> String?
    func safeDouble(for key: String) -> Double
    func safeDate(for key: String) -> Date?
}
```

**Computed Properties**:
```swift
extension CDUser {
    var displayName: String
    var formattedJoinDate: String
    var isNewUser: Bool
}
```

**Convenience Initializers**:
```swift
extension NSFetchRequest where ResultType == CDUser {
    static func users(sortedBy:) -> NSFetchRequest<CDUser>
}
```

## Usage Examples

### Creating a New User
```swift
let user = PersistenceController.shared.addUser(
    username: "john_doe",
    email: "john@example.com",
    rating: 4.5
)
```

### Fetching Listings with Search
```swift
let searchResults = PersistenceController.shared.searchListings(query: "iPhone")
```

### Using @FetchRequest in SwiftUI
```swift
@FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \CDListing.timestamp, ascending: false)],
    animation: .default)
private var listings: FetchedResults<CDListing>
```

### Batch Operations
```swift
try PersistenceController.shared.performBatchOperation {
    // Perform multiple operations
    let user = CDUser(context: context)
    user.id = UUID()
    user.username = "newuser"
    
    let listing = CDListing(context: context)
    listing.id = UUID()
    listing.owner = user
    // ... more operations
}
```

## Demo Features

The `CoreDataDemoView` provides:
- **Sample Data Generation**: Pre-populated users, listings, and messages
- **Database Management**: Clear data, view statistics
- **Quick Navigation**: Access to all Core Data views
- **Interactive Testing**: Real-time data manipulation

## Best Practices Implemented

1. **Error Handling**: Comprehensive error handling with user-friendly messages
2. **Memory Management**: Proper use of weak references and context management
3. **Performance**: Efficient fetch requests with appropriate predicates and sort descriptors
4. **Data Consistency**: Proper relationship management and deletion rules
5. **SwiftUI Integration**: Seamless integration with SwiftUI environment and @FetchRequest
6. **Preview Support**: In-memory Core Data stack for SwiftUI previews

## Migration Considerations

- The Core Data model uses `codeGenerationType = "class"` for automatic NSManagedObject subclass generation
- External binary storage for images to prevent memory issues
- Proper deletion rules to maintain referential integrity
- Context merging policies for background operations
- **Naming Convention**: Uses `CD` prefix (CDUser, CDListing, CDMessage) to avoid conflicts with existing Swift models

## Testing

- In-memory Core Data stack for unit tests
- Sample data generation for UI testing
- Preview data for SwiftUI previews
- Error simulation for edge case testing

## Future Enhancements

Potential improvements could include:
- CloudKit integration for sync
- Advanced search and filtering
- Data analytics and reporting
- Offline-first architecture
- Migration support for schema changes
- Performance monitoring and optimization

## Troubleshooting

### Common Issues:
1. **Context Save Failures**: Check validation errors and required attributes
2. **Memory Issues**: Ensure proper image compression and external storage usage
3. **Relationship Errors**: Verify deletion rules and cascade relationships
4. **Performance**: Use appropriate fetch request batch sizes and predicates

### Debug Tips:
- Enable Core Data debugging in Xcode scheme
- Monitor context save operations
- Check relationship integrity
- Validate data constraints

This Core Data setup provides a robust foundation for local data persistence in the LessGo reselling app, with comprehensive functionality for managing users, listings, and messages.
