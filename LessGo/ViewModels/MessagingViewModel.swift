import Foundation
import CoreData
import Combine

class MessagingViewModel: ObservableObject {
    @Published var chats: [ChatPreview] = []
    @Published var filteredChats: [ChatPreview] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let persistenceController = PersistenceController.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadChats()
    }
    
    private func setupBindings() {
        // Debounced search with real-time filtering
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.filterChats(searchText: searchText)
            }
            .store(in: &cancellables)
        
        // Listen for chat message updates
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ChatMessageSent"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let userInfo = notification.userInfo,
               let chatId = userInfo["chatId"] as? String,
               let messageId = userInfo["messageId"] as? String,
               let content = userInfo["content"] as? String,
               let senderId = userInfo["senderId"] as? String {
                self?.updateChatLastMessage(
                    chatId: chatId,
                    messageId: messageId,
                    content: content,
                    senderId: senderId
                )
            }
        }
    }
    
    func loadChats() {
        isLoading = true
        
        // Load chats from Core Data
        let coreDataChats = persistenceController.fetchChatsAsStructs()
        
        // If no chats in Core Data, generate sample data
        if coreDataChats.isEmpty {
            generateSampleChatsInCoreData()
            chats = persistenceController.fetchChatsAsStructs()
        } else {
            chats = coreDataChats
        }
        
        filterChats(searchText: searchText)
        isLoading = false
    }
    
    private func filterChats(searchText: String) {
        if searchText.isEmpty {
            filteredChats = chats
        } else {
            filteredChats = chats.filter { chat in
                let otherParticipantName = chat.otherParticipant?.displayName.lowercased() ?? ""
                let listingTitle = chat.listing?.title.lowercased() ?? ""
                let lastMessage = chat.lastMessage?.content.lowercased() ?? ""
                
                return otherParticipantName.contains(searchText.lowercased()) ||
                       listingTitle.contains(searchText.lowercased()) ||
                       lastMessage.contains(searchText.lowercased())
            }
        }
    }
    
    func togglePinChat(_ chat: ChatPreview) {
        persistenceController.togglePinChat(chatId: chat.id)
        loadChats() // Reload to reflect changes
    }
    
    func archiveChat(_ chat: ChatPreview) {
        persistenceController.archiveChat(chatId: chat.id)
        loadChats() // Reload to reflect changes
    }
    
    func deleteChat(_ chat: ChatPreview) {
        persistenceController.deleteChat(chatId: chat.id)
        loadChats() // Reload to reflect changes
    }
    
    func markChatAsRead(_ chat: ChatPreview) {
        persistenceController.markChatAsRead(chatId: chat.id)
        loadChats() // Reload to reflect changes
    }
    
    // MARK: - Real-time Updates
    func updateChatLastMessage(chatId: String, messageId: String, content: String, senderId: String) {
        persistenceController.updateChatLastMessage(
            chatId: chatId,
            messageId: messageId,
            content: content,
            senderId: senderId
        )
        loadChats() // Reload to reflect changes
    }
    
    private func generateSampleChatsInCoreData() {
        // Create sample users first
        let user1 = persistenceController.addUser(
            id: "user1",
            email: "john@example.com",
            displayName: "John Smith"
        )
        
        let user2 = persistenceController.addUser(
            id: "user2",
            email: "sarah@example.com",
            displayName: "Sarah Johnson"
        )
        
        let user3 = persistenceController.addUser(
            id: "user3",
            email: "mike@example.com",
            displayName: "Mike Wilson"
        )
        
        // Create sample listings
        let sampleLocation = Location(
            latitude: 37.7749,
            longitude: -122.4194,
            address: "123 Main St",
            city: "San Francisco"
        )
        
        var listing1 = Listing(
            id: UUID().uuidString,
            sellerId: user1.id ?? "",
            title: "iPhone 14 Pro Max",
            description: "Excellent condition iPhone 14 Pro Max, 256GB.",
            price: 899.99,
            category: .electronics,
            condition: .excellent,
            location: sampleLocation
        )
        listing1.images = ["sample1.jpg"]
        let _ = persistenceController.saveListing(listing1)
        
        var listing2 = Listing(
            id: UUID().uuidString,
            sellerId: user2.id ?? "",
            title: "Nike Air Jordan 1",
            description: "Authentic Nike Air Jordan 1 in size 10.",
            price: 150.00,
            category: .clothing,
            condition: .good,
            location: sampleLocation
        )
        listing2.images = ["sample2.jpg"]
        let _ = persistenceController.saveListing(listing2)
        
        // Create sample chats
        let chat1 = persistenceController.createChat(
            participants: [user1.id ?? "", user2.id ?? ""],
            listingId: listing1.id,
            lastMessageContent: "Is this still available?",
            lastMessageSenderId: user2.id ?? ""
        )
        
        let chat2 = persistenceController.createChat(
            participants: [user1.id ?? "", user3.id ?? ""],
            listingId: listing2.id,
            lastMessageContent: "What's your best price?",
            lastMessageSenderId: user3.id ?? ""
        )
        
        // Create sample messages
        let _ = persistenceController.sendMessage(
            id: UUID().uuidString,
            chatId: chat1.id ?? "",
            senderId: user2.id ?? "",
            receiverId: user1.id ?? "",
            content: "Is this still available?",
            messageType: "text"
        )
        
        let _ = persistenceController.sendMessage(
            id: UUID().uuidString,
            chatId: chat2.id ?? "",
            senderId: user3.id ?? "",
            receiverId: user1.id ?? "",
            content: "What's your best price?",
            messageType: "text"
        )
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
