import Foundation
import SwiftUI
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var messages: [Message] = []
    @Published var newMessageText: String = ""
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showImagePicker: Bool = false
    @Published var selectedImage: UIImage?
    @Published var isUploadingImage: Bool = false
    @Published var showUserActions: Bool = false
    @Published var showReportSheet: Bool = false
    @Published var isOtherUserTyping: Bool = false
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let chatId: String
    private let currentUserId: String
    private let otherUserId: String
    private var isTemporaryChat: Bool = false
    private var onChatCreated: ((ChatPreview) -> Void)?
    private var listing: Listing?
    private var actualChatPreview: ChatPreview?
    
    // MARK: - Initialization
    init(chatId: String, currentUserId: String, otherUserId: String, isTemporaryChat: Bool = false, listing: Listing? = nil, onChatCreated: ((ChatPreview) -> Void)? = nil) {
        self.chatId = chatId
        self.currentUserId = currentUserId
        self.otherUserId = otherUserId
        self.isTemporaryChat = isTemporaryChat
        self.listing = listing
        self.onChatCreated = onChatCreated
        loadMessages()
    }
    
    // MARK: - Message Loading
    func loadMessages() {
        isLoading = true
        
        // For temporary chats, don't load sample messages
        if isTemporaryChat {
            self.messages = []
            self.isLoading = false
            return
        }
        
        // Simulate API call
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Load sample messages
            let sampleMessages = createSampleMessages()
            self.messages = sampleMessages
            self.isLoading = false
            
            // Mark messages as read
            markMessagesAsRead()
            
            // Simulate other user typing
            simulateTyping()
        }
    }
    
    private func createSampleMessages() -> [Message] {
        let sampleMessages = [
            Message(id: "1", chatId: chatId, senderId: otherUserId, receiverId: currentUserId, content: "Hi! Is this item still available?"),
            Message(id: "2", chatId: chatId, senderId: currentUserId, receiverId: otherUserId, content: "Yes, it is! Are you interested?"),
            Message(id: "3", chatId: chatId, senderId: otherUserId, receiverId: currentUserId, content: "Definitely! Can you send me more photos?"),
            Message(id: "4", chatId: chatId, senderId: currentUserId, receiverId: otherUserId, content: "Sure! Here are some additional photos", messageType: .image, imageURL: "sample_image_1"),
            Message(id: "5", chatId: chatId, senderId: otherUserId, receiverId: currentUserId, content: "Perfect! What's your best price?"),
            Message(id: "6", chatId: chatId, senderId: currentUserId, receiverId: otherUserId, content: "I can do $120, but I'm firm on that price."),
            Message(id: "7", chatId: chatId, senderId: otherUserId, receiverId: currentUserId, content: "That works for me! When can we meet?"),
            Message(id: "8", chatId: chatId, senderId: currentUserId, receiverId: otherUserId, content: "How about tomorrow at 3 PM? I can meet at the coffee shop downtown.")
        ]
        
        return sampleMessages
    }
    
    private func simulateTyping() {
        // Simulate the other user typing occasionally
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            isOtherUserTyping = true
            
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            isOtherUserTyping = false
        }
    }
    
    // MARK: - Message Actions
    func sendMessage() {
        guard !newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let message = Message(
            id: UUID().uuidString,
            chatId: chatId,
            senderId: currentUserId,
            receiverId: otherUserId,
            content: newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        messages.append(message)
        newMessageText = ""
        
        // If this is a temporary chat, create the actual chat now
        if isTemporaryChat {
            createActualChat()
            isTemporaryChat = false
            // Notify that the chat was created so it can be added to the messaging system
            if let actualChat = actualChatPreview {
                onChatCreated?(actualChat)
            }
        }
        
        // Simulate message delivery
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            if let index = messages.firstIndex(where: { $0.id == message.id }) {
                messages[index].isDelivered = true
                messages[index].deliveredAt = Date()
            }
            
            // Simulate read receipt
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if let index = messages.firstIndex(where: { $0.id == message.id }) {
                messages[index].isRead = true
                messages[index].readAt = Date()
            }
        }
    }
    
    func sendImage(_ image: UIImage) {
        isUploadingImage = true
        
        // Simulate image upload
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            let message = Message(
                id: UUID().uuidString,
                chatId: chatId,
                senderId: currentUserId,
                receiverId: otherUserId,
                content: "Image",
                messageType: .image,
                imageURL: "uploaded_image_\(UUID().uuidString)"
            )
            
            messages.append(message)
            isUploadingImage = false
            selectedImage = nil
            
            // If this is a temporary chat, create the actual chat now
            if isTemporaryChat {
                createActualChat()
                isTemporaryChat = false
                // Notify that the chat was created so it can be added to the messaging system
                if let actualChat = actualChatPreview {
                    onChatCreated?(actualChat)
                }
            }
            
            // Simulate message delivery and read receipt
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000)
                if let index = messages.firstIndex(where: { $0.id == message.id }) {
                    messages[index].isDelivered = true
                    messages[index].deliveredAt = Date()
                }
                
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if let index = messages.firstIndex(where: { $0.id == message.id }) {
                    messages[index].isRead = true
                    messages[index].readAt = Date()
                }
            }
        }
    }
    
    // MARK: - Chat Creation
    private func createActualChat() {
        // Create a new chat with a proper ID
        let newChatId = UUID().uuidString
        
        // Create the actual chat preview
        let actualChat = Chat(
            id: newChatId,
            participants: [currentUserId, otherUserId],
            listingId: listing?.id
        )
        
        // Create a proper chat preview with the other participant info
        let otherParticipant = User(
            id: otherUserId,
            email: "seller@example.com",
            displayName: "Seller"
        )
        
        let actualChatPreview = ChatPreview(from: actualChat, otherParticipant: otherParticipant, listing: listing)
        
        // Store the actual chat for later use - don't call onChatCreated yet
        // The chat should stay open for the user to continue chatting
        self.actualChatPreview = actualChatPreview
        
        // Update the chat ID to the actual one so future messages use the real chat
        // Note: This is a bit of a hack, but it ensures messages are stored in the actual chat
        // In a real app, you'd want to handle this more elegantly
    }
    
    // MARK: - Read Receipts
    private func markMessagesAsRead() {
        // Mark all messages from other user as read
        for (index, message) in messages.enumerated() {
            if message.senderId == otherUserId && !message.isRead {
                messages[index].isRead = true
                messages[index].readAt = Date()
            }
        }
    }
    
    // MARK: - User Actions
    func blockUser() {
        // In real app, this would call an API to block the user
        showError(message: "User blocked successfully")
        showUserActions = false
    }
    
    func reportUser(reason: String) {
        // In real app, this would call an API to report the user
        showError(message: "User reported successfully")
        showReportSheet = false
    }
    
    func deleteChat() {
        // In real app, this would call an API to delete the chat
        showError(message: "Chat deleted successfully")
    }
    
    // MARK: - Image Picker
    func selectImage(_ image: UIImage) {
        selectedImage = image
        showImagePicker = false
        sendImage(image)
    }
    
    // MARK: - Error Handling
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    func dismissError() {
        showError = false
        errorMessage = ""
    }
    
    // MARK: - Chat Dismissal
    func onChatDismissed() {
        // When user dismisses the chat, do nothing special
        // The chat is already created and added to the messaging system
        // The user will return to where they came from (home page)
        // No tab switching occurs
    }
    
    // MARK: - Computed Properties
    var canSendMessage: Bool {
        return !newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var unreadCount: Int {
        return messages.filter { $0.senderId == otherUserId && !$0.isRead }.count
    }
}
