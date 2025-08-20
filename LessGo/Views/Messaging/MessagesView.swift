import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var viewModel: MessagingViewModel
    @State private var showNewMessageSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Messages")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.label)
                Spacer()
                Button(action: { showNewMessageSheet = true }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(Constants.Colors.label)
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8) // spacing inside
            .padding(.bottom, 12)
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) // <-- push below notch
            .background(Constants.Colors.background)

            // Search Bar
            SearchBarView(searchText: $viewModel.searchText)
                .padding(.horizontal)
                .padding(.top, 8)

            // Content
            Group {
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView("Loading chats...")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else if viewModel.filteredChats.isEmpty {
                    EmptyStateView(onNewMessage: { showNewMessageSheet = true })
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // <-- fill space
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            if !viewModel.pinnedChats.isEmpty {
                                PinnedChatsSection(chats: viewModel.pinnedChats, viewModel: viewModel)
                            }
                            if !viewModel.regularChats.isEmpty {
                                RegularChatsSection(chats: viewModel.regularChats, viewModel: viewModel)
                            }
                            if !viewModel.archivedChats.isEmpty {
                                ArchivedChatsSection(chats: viewModel.archivedChats, viewModel: viewModel)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // <-- expand content area
        }
        // Make the whole screen white, including above the notch and above the custom tab bar
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Constants.Colors.background)
        .ignoresSafeArea(edges: [.top, .bottom]) // <-- remove black bands
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { viewModel.dismissError() }
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $viewModel.showChatView) {
            if let selectedChat = viewModel.selectedChat {
                ChatView(chat: selectedChat)
            }
        }
        .sheet(isPresented: $showNewMessageSheet) {
            NewMessageView(viewModel: viewModel)
        }
    }
}


// MARK: - Search Bar
struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Constants.Colors.secondaryLabel)
            
            TextField("Search chats, users, or messages...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(Constants.Colors.label)
            
            if !searchText.isEmpty {
                Button("Clear") {
                    searchText = ""
                }
                .foregroundColor(Constants.Colors.label)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Constants.Colors.sampleCardBackground)
        .cornerRadius(10)
    }
}

// MARK: - Pinned Chats Section
struct PinnedChatsSection: View {
    let chats: [ChatPreview]
    let viewModel: MessagingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "pin.fill")
                    .foregroundColor(.orange)
                Text("Pinned")
                    .font(.caption)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                Spacer()
            }
            .padding(.horizontal)
            
            ForEach(chats) { chat in
                ChatRowView(chat: chat, viewModel: viewModel)
                    .background(Color.orange.opacity(0.1))
            }
        }
    }
}

// MARK: - Regular Chats Section
struct RegularChatsSection: View {
    let chats: [ChatPreview]
    let viewModel: MessagingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "message.fill")
                    .foregroundColor(Constants.Colors.label)
                Text("Recent")
                    .font(.caption)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                Spacer()
            }
            .padding(.horizontal)
            
            ForEach(chats) { chat in
                ChatRowView(chat: chat, viewModel: viewModel)
            }
        }
    }
}

// MARK: - Archived Chats Section
struct ArchivedChatsSection: View {
    let chats: [ChatPreview]
    let viewModel: MessagingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "archivebox.fill")
                    .foregroundColor(Constants.Colors.secondaryLabel)
                Text("Archived")
                    .font(.caption)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                Spacer()
            }
            .padding(.horizontal)
            
            ForEach(chats) { chat in
                ChatRowView(chat: chat, viewModel: viewModel)
                    .opacity(0.6)
            }
        }
    }
}

// MARK: - Chat Row View
struct ChatRowView: View {
    let chat: ChatPreview
    let viewModel: MessagingViewModel
    @State private var showChatActions = false
    
    var body: some View {
        Button(action: {
            viewModel.selectChat(chat)
        }) {
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(Constants.Colors.sampleCardBackground)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(chat.otherParticipant?.displayName.prefix(1) ?? "?"))
                            .font(.headline)
                            .foregroundColor(Constants.Colors.label)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(chat.otherParticipant?.displayName ?? "Unknown User")
                            .font(.headline)
                            .foregroundColor(Constants.Colors.label)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(timeAgoString(from: chat.updatedAt))
                            .font(.caption)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                    
                    if let listing = chat.listing {
                        Text(listing.title)
                            .font(.caption)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                            .lineLimit(1)
                    }
                    
                    if let lastMessage = chat.lastMessage {
                        Text(lastMessage.content)
                            .font(.subheadline)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                            .lineLimit(2)
                    }
                }
                
                VStack(alignment: .trailing, spacing: 4) {
                    // Unread indicator
                    if chat.unreadCount > 0 {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Text("\(chat.unreadCount)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            )
                    }
                    
                    // Pin indicator
                    if chat.isPinned {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                viewModel.deleteChat(chat)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                viewModel.togglePinChat(chat)
            } label: {
                Label(chat.isPinned ? "Unpin" : "Pin", systemImage: chat.isPinned ? "pin.slash" : "pin")
            }
            .tint(chat.isPinned ? Constants.Colors.secondaryLabel : .orange)
        }
        .contextMenu {
            Button(chat.isPinned ? "Unpin" : "Pin") {
                viewModel.togglePinChat(chat)
            }
            
            Button(chat.isArchived ? "Unarchive" : "Archive") {
                viewModel.archiveChat(chat)
            }
            
            Button("Delete", role: .destructive) {
                viewModel.deleteChat(chat)
            }
            
            Divider()
            
            Button("Block User", role: .destructive) {
                if let otherUserId = chat.participants.first(where: { $0 != "currentUser" }) {
                    viewModel.blockUser(otherUserId)
                }
            }
            
            Button("Report User") {
                // Show report sheet
            }
        }
        .onLongPressGesture {
            showChatActions = true
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "now"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h"
        } else {
            return "\(Int(interval / 86400))d"
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let onNewMessage: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "message.circle")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.secondaryLabel)
            
            Text("No Messages Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            Text("Start a conversation by messaging sellers about their items or responding to buyer inquiries.")
                .font(.body)
                .foregroundColor(Constants.Colors.secondaryLabel)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: onNewMessage) {
                HStack {
                    Image(systemName: "square.and.pencil")
                    Text("Start New Conversation")
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Constants.Colors.label)
                .cornerRadius(25)
            }
        }
        .padding()
    }
}

#Preview {
    MessagesView()
        .environmentObject(MessagingViewModel(currentUserId: "currentUser"))
}
