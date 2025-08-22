import SwiftUI
import CoreData

struct MessagesView: View {
    @StateObject private var messagingViewModel = MessagingViewModel()
    @State private var showingNewMessage = false
    @State private var showingUserActions = false
    @State private var selectedChat: ChatPreview?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Chat List
                if messagingViewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if messagingViewModel.filteredChats.isEmpty {
                    emptyStateView
                } else {
                    chatListView
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewMessage = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingNewMessage) {
                NewMessageView()
            }
            .alert("Error", isPresented: $messagingViewModel.showError) {
                Button("OK") { }
            } message: {
                Text(messagingViewModel.errorMessage)
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search chats...", text: $messagingViewModel.searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !messagingViewModel.searchText.isEmpty {
                Button("Clear") {
                    messagingViewModel.searchText = ""
                }
                .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "message.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Messages Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start a conversation by messaging a seller about a listing")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Start New Chat") {
                showingNewMessage = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var chatListView: some View {
        List {
            // Pinned Chats
            if !pinnedChats.isEmpty {
                Section("Pinned") {
                    ForEach(pinnedChats) { chat in
                        ChatRowView(chat: chat, onChatSelected: { selectedChat in
                            self.selectedChat = selectedChat
                        })
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Unpin") {
                                messagingViewModel.togglePinChat(chat)
                            }
                            .tint(.orange)
                            
                            Button("Archive") {
                                messagingViewModel.archiveChat(chat)
                            }
                            .tint(.gray)
                            
                            Button("Delete", role: .destructive) {
                                messagingViewModel.deleteChat(chat)
                            }
                        }
                    }
                }
            }
            
            // Regular Chats
            if !regularChats.isEmpty {
                Section("Recent") {
                    ForEach(regularChats) { chat in
                        ChatRowView(chat: chat, onChatSelected: { selectedChat in
                            self.selectedChat = selectedChat
                        })
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Pin") {
                                messagingViewModel.togglePinChat(chat)
                            }
                            .tint(.orange)
                            
                            Button("Archive") {
                                messagingViewModel.archiveChat(chat)
                            }
                            .tint(.gray)
                            
                            Button("Delete", role: .destructive) {
                                messagingViewModel.deleteChat(chat)
                            }
                        }
                    }
                }
            }
            
            // Archived Chats
            if !archivedChats.isEmpty {
                Section("Archived") {
                    ForEach(archivedChats) { chat in
                        ChatRowView(chat: chat, onChatSelected: { selectedChat in
                            self.selectedChat = selectedChat
                        })
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Unarchive") {
                                messagingViewModel.archiveChat(chat)
                            }
                            .tint(.blue)
                            
                            Button("Delete", role: .destructive) {
                                messagingViewModel.deleteChat(chat)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .refreshable {
            messagingViewModel.loadChats()
        }
        .sheet(item: $selectedChat) { chat in
            ChatView(chat: chat)
        }
    }
    
    private var pinnedChats: [ChatPreview] {
        messagingViewModel.filteredChats.filter { $0.isPinned }
    }
    
    private var regularChats: [ChatPreview] {
        messagingViewModel.filteredChats.filter { !$0.isPinned && !$0.isArchived }
    }
    
    private var archivedChats: [ChatPreview] {
        messagingViewModel.filteredChats.filter { $0.isArchived }
    }
}

struct ChatRowView: View {
    let chat: ChatPreview
    let onChatSelected: (ChatPreview) -> Void
    
    var body: some View {
        Button(action: { onChatSelected(chat) }) {
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String((chat.otherParticipant?.displayName ?? "U").prefix(1).uppercased()))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    )
                
                // Chat Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(chat.otherParticipant?.displayName ?? "Unknown User")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if chat.isPinned {
                            Image(systemName: "pin.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                        
                        Text(chat.updatedAt, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let listing = chat.listing {
                        Text(listing.title)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    if let lastMessage = chat.lastMessage {
                        HStack {
                            Text(lastMessage.content)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            if chat.unreadCount > 0 {
                                Text("\(chat.unreadCount)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MessagesView()
}
