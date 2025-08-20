import Foundation
import SwiftUI
import Combine

@MainActor
class MessagingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var chats: [ChatPreview] = []
    @Published var filteredChats: [ChatPreview] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var selectedChat: ChatPreview?
    @Published var showChatView: Bool = false
    @Published var tempChatPreview: ChatPreview?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let userId: String
    
    // MARK: - Initialization
    init(currentUserId: String) {
        self.userId = currentUserId
        setupSearchSubscription()
        loadChats()
    }
    
    // MARK: - Search Setup
    private func setupSearchSubscription() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.filterChats(searchText: searchText)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Chat Loading
    func loadChats() {
        isLoading = true
        
        // Simulate API call
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            // Start with empty chats - only show real user chats
            // Sample chats are only loaded for demo purposes when explicitly requested
            self.chats = []
            self.filteredChats = []
            self.isLoading = false
        }
    }
    
    private func createSampleChats() -> [ChatPreview] {
        let sampleUsers = [
            User(id: "user1", email: "john@example.com", displayName: "John Smith"),
            User(id: "user2", email: "sarah@example.com", displayName: "Sarah Johnson"),
            User(id: "user3", email: "mike@example.com", displayName: "Mike Wilson"),
            User(id: "user4", email: "emma@example.com", displayName: "Emma Davis"),
            User(id: "user5", email: "alex@example.com", displayName: "Alex Chen")
        ]
        
        let sampleListings = [
            Listing(
                id: "listing1", 
                sellerId: "user1", 
                title: "Vintage Chair", 
                description: "Beautiful vintage chair in excellent condition",
                price: 120.0, 
                category: .furniture,
                condition: .excellent,
                location: Location(city: "San Francisco", state: "CA")
            ),
            Listing(
                id: "listing2", 
                sellerId: "user2", 
                title: "iPhone 12", 
                description: "iPhone 12 in great condition with original box",
                price: 450.0, 
                category: .electronics,
                condition: .good,
                location: Location(city: "Los Angeles", state: "CA")
            ),
            Listing(
                id: "listing3", 
                sellerId: "user3", 
                title: "Bicycle", 
                description: "Mountain bike perfect for outdoor adventures",
                price: 200.0, 
                category: .sports,
                condition: .fair,
                location: Location(city: "Seattle", state: "WA")
            )
        ]
        
        let sampleMessages = [
            Message(id: "msg1", chatId: "chat1", senderId: "user1", receiverId: userId, content: "Hi! Is this item still available?"),
            Message(id: "msg2", chatId: "chat2", senderId: "user2", receiverId: userId, content: "Great! I'll take it. When can we meet?"),
            Message(id: "msg3", chatId: "chat3", senderId: "user3", receiverId: userId, content: "Can you do $80 for the chair?"),
            Message(id: "msg4", chatId: "chat4", senderId: "user4", receiverId: userId, content: "Thanks for the quick delivery!"),
            Message(id: "msg5", chatId: "chat5", senderId: "user5", receiverId: userId, content: "Do you have more photos?")
        ]
        
        let sampleChats = [
            Chat(id: "chat1", participants: [userId, "user1"], listingId: "listing1"),
            Chat(id: "chat2", participants: [userId, "user2"], listingId: "listing2"),
            Chat(id: "chat3", participants: [userId, "user3"], listingId: "listing3"),
            Chat(id: "chat4", participants: [userId, "user4"]),
            Chat(id: "chat5", participants: [userId, "user5"])
        ]
        
        // Update chats with last messages and unread counts
        var updatedChats: [ChatPreview] = []
        
        for (index, chat) in sampleChats.enumerated() {
            var updatedChat = chat
            updatedChat.lastMessage = sampleMessages[index]
            updatedChat.unreadCount = index % 2 == 0 ? 1 : 0 // Alternate unread status
            updatedChat.isPinned = index == 0 // First chat is pinned
            
            let otherUserId = chat.participants.first { $0 != userId } ?? ""
            let otherUser = sampleUsers.first { $0.id == otherUserId }
            let listing = sampleListings.first { $0.id == chat.listingId }
            
            let chatPreview = ChatPreview(from: updatedChat, otherParticipant: otherUser, listing: listing)
            updatedChats.append(chatPreview)
        }
        
        return updatedChats.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    // MARK: - Search and Filtering
    private func filterChats(searchText: String) {
        if searchText.isEmpty {
            filteredChats = chats
        } else {
            filteredChats = chats.filter { chat in
                let otherUserName = chat.otherParticipant?.displayName ?? ""
                let listingTitle = chat.listing?.title ?? ""
                let lastMessage = chat.lastMessage?.content ?? ""
                
                return otherUserName.localizedCaseInsensitiveContains(searchText) ||
                       listingTitle.localizedCaseInsensitiveContains(searchText) ||
                       lastMessage.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Chat Actions
    func selectChat(_ chat: ChatPreview) {
        selectedChat = chat
        showChatView = true
    }
    
    func createChatWithUser(_ user: User, listing: Listing? = nil) {
        let newChat = Chat(
            id: UUID().uuidString,
            participants: [userId, user.id],
            listingId: listing?.id
        )
        
        let chatPreview = ChatPreview(from: newChat, otherParticipant: user, listing: listing)
        chats.insert(chatPreview, at: 0)
        filterChats(searchText: searchText)
        
        // Select the new chat
        selectedChat = chatPreview
        showChatView = true
    }
    
    func togglePinChat(_ chat: ChatPreview) {
        if let index = chats.firstIndex(where: { $0.id == chat.id }) {
            chats[index].isPinned.toggle()
            filterChats(searchText: searchText)
        }
    }
    
    func archiveChat(_ chat: ChatPreview) {
        if let index = chats.firstIndex(where: { $0.id == chat.id }) {
            chats[index].isArchived.toggle()
            filterChats(searchText: searchText)
        }
    }
    
    func deleteChat(_ chat: ChatPreview) {
        chats.removeAll { $0.id == chat.id }
        filterChats(searchText: searchText)
    }
    
    func blockUser(_ userId: String) {
        // In real app, this would call an API to block the user
        // For now, we'll remove all chats with this user
        chats.removeAll { chat in
            chat.participants.contains(userId)
        }
        filterChats(searchText: searchText)
    }
    
    func reportUser(_ userId: String, reason: String) {
        // In real app, this would call an API to report the user
        showError(message: "User reported successfully")
    }
    
    func addNewChat(_ chat: ChatPreview) {
        // Add the new chat to the beginning of the list
        chats.insert(chat, at: 0)
        filterChats(searchText: searchText)
    }
    
    func markChatAsRead(_ chatId: String) {
        if let index = chats.firstIndex(where: { $0.id == chatId }) {
            chats[index].unreadCount = 0
            filterChats(searchText: searchText)
        }
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
    
    // MARK: - Computed Properties
    var pinnedChats: [ChatPreview] {
        return filteredChats.filter { $0.isPinned }
    }
    
    var regularChats: [ChatPreview] {
        return filteredChats.filter { !$0.isPinned && !$0.isArchived }
    }
    
    var archivedChats: [ChatPreview] {
        return filteredChats.filter { $0.isArchived }
    }
}
