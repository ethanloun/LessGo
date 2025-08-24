import Foundation
import CoreData
import Combine
import UIKit

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isTyping = false
    @Published var isUploadingImage = false
    @Published var chatExists = false
    
    private let persistenceController = PersistenceController.shared
    private var cancellables = Set<AnyCancellable>()
    private let chatId: String
    private let currentUserId: String
    
    init(chatId: String, currentUserId: String) {
        self.chatId = chatId
        self.currentUserId = currentUserId
        checkIfChatExists()
        loadMessages()
    }
    
    func loadMessages() {
        isLoading = true
        
        // Load messages from Core Data
        let coreDataMessages = persistenceController.fetchMessages(for: chatId)
        
        // Convert to Message structs
        messages = coreDataMessages.map { $0.toMessage() }
            .sorted { $0.timestamp < $1.timestamp }
        
        isLoading = false
    }
    
    func checkIfChatExists() {
        let existingChat = persistenceController.fetchChat(chatId: chatId)
        chatExists = existingChat != nil
    }
    
    func createChatInCoreData(chat: ChatPreview) {
        // Create the chat in Core Data with the specific chat ID
        _ = persistenceController.createChat(
            id: chatId,
            participants: chat.participants,
            listingId: chat.listing?.id,
            lastMessageContent: nil,
            lastMessageSenderId: nil
        )
        
        // Mark chat as existing
        chatExists = true
        
        // Save the chat
        persistenceController.save()
    }
    
    func sendMessage(_ content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let message = persistenceController.sendMessage(
            id: UUID().uuidString,
            chatId: chatId,
            senderId: currentUserId,
            receiverId: "", // Will be determined from chat participants
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            messageType: "text"
        )
        
        // Add to local messages
        let messageStruct = message.toMessage()
        messages.append(messageStruct)
        
        // Update chat's last message in Core Data
        persistenceController.updateChatLastMessage(
            chatId: chatId,
            messageId: message.id ?? "",
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            senderId: currentUserId
        )
        
        // Notify MessagingViewModel to update the chat preview
        NotificationCenter.default.post(
            name: NSNotification.Name("ChatMessageSent"),
            object: nil,
            userInfo: [
                "chatId": chatId,
                "messageId": message.id ?? "",
                "content": content.trimmingCharacters(in: .whitespacesAndNewlines),
                "senderId": currentUserId
            ]
        )
        
        // Simulate message delivery and read status
        simulateMessageStatus(messageId: message.id ?? "")
    }
    
    func sendImage(_ image: UIImage) {
        isUploadingImage = true
        
        // Simulate image upload process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Convert image to base64 for storage (in real app, upload to server)
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let base64String = imageData.base64EncodedString()
                
                let message = self.persistenceController.sendMessage(
                    id: UUID().uuidString,
                    chatId: self.chatId,
                    senderId: self.currentUserId,
                    receiverId: "",
                    content: "Image",
                    messageType: "image",
                    imageURL: base64String
                )
                
                // Add to local messages
                let messageStruct = message.toMessage()
                self.messages.append(messageStruct)
                
                // Update chat's last message
                self.persistenceController.updateChatLastMessage(
                    chatId: self.chatId,
                    messageId: message.id ?? "",
                    content: "Image",
                    senderId: self.currentUserId
                )
                
                // Notify MessagingViewModel to update the chat preview
                NotificationCenter.default.post(
                    name: NSNotification.Name("ChatMessageSent"),
                    object: nil,
                    userInfo: [
                        "chatId": self.chatId,
                        "messageId": message.id ?? "",
                        "content": "Image",
                        "senderId": self.currentUserId
                    ]
                )
                
                // Simulate message status
                self.simulateMessageStatus(messageId: message.id ?? "")
            }
            
            self.isUploadingImage = false
        }
    }
    
    private func simulateMessageStatus(messageId: String) {
        // Simulate message delivery
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.markMessageAsDelivered(messageId: messageId)
        }
        
        // Simulate message read
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.markMessageAsRead(messageId: messageId)
        }
    }
    
    private func markMessageAsDelivered(messageId: String) {
        // Find the message in Core Data and mark it as delivered
        let coreDataMessages = persistenceController.fetchMessages(for: chatId)
        if let message = coreDataMessages.first(where: { $0.id == messageId }) {
            persistenceController.markMessageAsDelivered(message)
        }
        
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].isDelivered = true
            messages[index].deliveredAt = Date()
        }
    }
    
    private func markMessageAsRead(messageId: String) {
        // Find the message in Core Data and mark it as read
        let coreDataMessages = persistenceController.fetchMessages(for: chatId)
        if let message = coreDataMessages.first(where: { $0.id == messageId }) {
            persistenceController.markMessageAsRead(message)
        }
        
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].isRead = true
            messages[index].readAt = Date()
        }
    }
    
    func markAllMessagesAsRead() {
        // Mark all messages from other users as read
        let coreDataMessages = persistenceController.fetchMessages(for: chatId)
        for message in coreDataMessages {
            if message.senderId != "currentUser" {
                persistenceController.markMessageAsRead(message)
            }
        }
        
        // Update local messages
        for index in messages.indices {
            if !messages[index].isRead {
                messages[index].isRead = true
                messages[index].readAt = Date()
            }
        }
        
        // Reset the chat's unread count since we're viewing it
        persistenceController.markChatAsRead(chatId: chatId)
    }
    
    func deleteMessage(_ message: Message) {
        persistenceController.deleteMessage(messageId: message.id)
        
        // Remove from local messages
        messages.removeAll { $0.id == message.id }
    }
    
    func reportMessage(_ message: Message, reason: String) {
        // In real app, this would call an API to report the message
        showError(message: "Message reported successfully")
    }
    
    func blockUser(_ userId: String) {
        persistenceController.blockUser(userId: userId)
        showError(message: "User blocked successfully")
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    func dismissError() {
        showError = false
        errorMessage = ""
    }
}
