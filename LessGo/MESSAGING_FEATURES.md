# LessGo Messaging System Features

## Overview
The LessGo messaging system provides a comprehensive chat experience for users to communicate about listings, negotiate prices, and build relationships within the marketplace.

## Core Features

### 1. Chat Management
- **Recent Chats List**: View all conversations with other users
- **Search Functionality**: Search through chats by user name, listing title, or message content
- **Chat Organization**: 
  - Pinned chats (stay at top)
  - Regular chats (chronological order)
  - Archived chats (hidden from main view)

### 2. Messaging Capabilities
- **Text Messages**: Send and receive text messages
- **Image Sharing**: Upload and share images in conversations
- **Read Receipts**: See when messages are delivered and read
- **Typing Indicators**: Know when the other user is typing
- **Message Timestamps**: Track when messages were sent

### 3. User Management
- **User Profiles**: View other users' profiles and information
- **Block Users**: Block unwanted users from contacting you
- **Report Users**: Report inappropriate behavior with reason
- **User Search**: Find and start conversations with new users

### 4. Chat Actions
- **Pin Chats**: Keep important conversations at the top
- **Archive Chats**: Hide old conversations
- **Delete Chats**: Remove unwanted conversations
- **Context Menus**: Long press for quick actions

### 5. Listing Integration
- **Message Seller**: Start conversations directly from listings
- **Listing Context**: See listing details in chat headers
- **Quick Contact**: Contact sellers about specific items

### 6. Navigation & UI
- **Tab Integration**: Dedicated Messages tab in main navigation
- **New Message Button**: Quick access to start new conversations
- **Empty State**: Helpful guidance when no messages exist
- **Modern Design**: Clean, intuitive interface following iOS design guidelines

## Technical Implementation

### View Models
- **MessagingViewModel**: Manages chat list, search, and chat actions
- **ChatViewModel**: Handles individual chat conversations and messages

### Data Models
- **Message**: Individual message with content, type, and status
- **Chat**: Conversation between users with metadata
- **ChatPreview**: Lightweight chat representation for lists
- **User**: User information and profile data

### Key Features Implementation

#### Search & Filtering
```swift
// Debounced search with real-time filtering
$searchText
    .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
    .sink { [weak self] searchText in
        self?.filterChats(searchText: searchText)
    }
```

#### Read Receipts
```swift
// Simulate message delivery and read status
if let index = messages.firstIndex(where: { $0.id == message.id }) {
    messages[index].isDelivered = true
    messages[index].deliveredAt = Date()
}
```

#### Image Upload
```swift
// Handle image selection and upload
func sendImage(_ image: UIImage) {
    isUploadingImage = true
    // Simulate upload process
    // Create image message
}
```

#### Chat Actions
```swift
// Pin, archive, and delete chats
func togglePinChat(_ chat: ChatPreview)
func archiveChat(_ chat: ChatPreview)
func deleteChat(_ chat: ChatPreview)
```

## User Experience Features

### 1. Seamless Navigation
- Tap "Message Seller" on any listing to start a conversation
- Automatic navigation to Messages tab when starting chats
- Easy access to user profiles and chat actions

### 2. Visual Indicators
- Orange dot for unread messages
- Pin icon for pinned conversations
- Read receipt icons (circle, checkmark, filled checkmark)
- Typing indicators

### 3. Smart Organization
- Pinned chats always visible
- Recent conversations prioritized
- Archived chats easily accessible
- Search across all chat content

### 4. Privacy & Safety
- Block unwanted users
- Report inappropriate behavior
- Delete sensitive conversations
- Archive old chats

## Future Enhancements

### Planned Features
- **Push Notifications**: Real-time message alerts
- **Voice Messages**: Audio message support
- **File Sharing**: Document and file uploads
- **Group Chats**: Multi-user conversations
- **Message Reactions**: Like, love, and other reactions
- **Message Search**: Search within specific conversations
- **Message Forwarding**: Share messages between chats
- **Message Editing**: Edit sent messages
- **Message Deletion**: Remove individual messages

### Technical Improvements
- **Real-time Updates**: WebSocket integration for live messaging
- **Offline Support**: Message queuing and sync
- **Media Optimization**: Image compression and caching
- **Security**: End-to-end encryption
- **Performance**: Lazy loading and pagination

## Usage Examples

### Starting a New Conversation
1. Tap "Message Seller" on any listing
2. Choose contact method (message or call)
3. Start typing your message
4. Send and begin conversation

### Managing Chats
1. Long press any chat for quick actions
2. Pin important conversations
3. Archive old chats
4. Block unwanted users

### Searching Messages
1. Use the search bar in Messages tab
2. Search by user name, listing, or content
3. Results update in real-time
4. Clear search to see all chats

## Architecture Notes

The messaging system follows MVVM architecture with:
- **Views**: UI components for chat lists and conversations
- **ViewModels**: Business logic and state management
- **Models**: Data structures for messages, chats, and users
- **Services**: Future integration points for backend APIs

The system is designed to be easily extensible for additional features like push notifications, real-time updates, and advanced media handling.

