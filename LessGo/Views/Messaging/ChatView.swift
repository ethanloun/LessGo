import SwiftUI
import CoreData
import UIKit

struct ChatView: View {
    let chat: ChatPreview
    @StateObject private var chatViewModel: ChatViewModel
    @State private var messageText = ""
    @State private var showingImagePicker = false
    @State private var showingUserActions = false
    @State private var showingReportSheet = false
    @State private var reportReason = ""
    @Environment(\.dismiss) private var dismiss
    
    init(chat: ChatPreview) {
        self.chat = chat
        self._chatViewModel = StateObject(wrappedValue: ChatViewModel(
            chatId: chat.id,
            currentUserId: "currentUser" // In real app, get from auth
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Messages
            messagesView
            
            // Input
            inputView
        }
        .navigationBarHidden(true)
        .onAppear {
            // Check if this is a new chat and create it in Core Data if needed
            if !chatViewModel.chatExists {
                chatViewModel.createChatInCoreData(chat: chat)
            }
            
            chatViewModel.markAllMessagesAsRead()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImages: .constant([]), onAddImage: { image in
                chatViewModel.sendImage(image)
            })
        }
        .alert("Error", isPresented: $chatViewModel.showError) {
            Button("OK") { }
        } message: {
            Text(chatViewModel.errorMessage)
        }
    }
    
    private var headerView: some View {
        HStack {
            Button("Back") {
                dismiss()
            }
            .foregroundColor(.blue)
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(chat.otherParticipant?.displayName ?? "Unknown User")
                    .font(.headline)
                
                if let listing = chat.listing {
                    Text(listing.title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: { showingUserActions = true }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.separator)),
            alignment: .bottom
        )
        .actionSheet(isPresented: $showingUserActions) {
            ActionSheet(
                title: Text("User Actions"),
                buttons: [
                    .default(Text("View Profile")) {
                        // Navigate to user profile
                    },
                    .destructive(Text("Block User")) {
                        if let userId = chat.otherParticipant?.id {
                            chatViewModel.blockUser(userId)
                        }
                    },
                    .destructive(Text("Report User")) {
                        showingReportSheet = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingReportSheet) {
            reportSheet
        }
    }
    
    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(chatViewModel.messages) { message in
                        MessageBubbleView(
                            message: message,
                            isFromCurrentUser: message.senderId == "currentUser",
                            onLongPress: {
                                // Show message actions
                            }
                        )
                        .id(message.id)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .onChange(of: chatViewModel.messages.count) { _ in
                if let lastMessage = chatViewModel.messages.last {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var inputView: some View {
        HStack(spacing: 12) {
            Button(action: { showingImagePicker = true }) {
                Image(systemName: "photo")
                    .foregroundColor(.blue)
                    .font(.title2)
            }
            .disabled(chatViewModel.isUploadingImage)
            
            TextField("Type a message...", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(chatViewModel.isUploadingImage)
            
            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .font(.title2)
                    .padding(8)
                    .background(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                    .clipShape(Circle())
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatViewModel.isUploadingImage)
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.separator)),
            alignment: .top
        )
    }
    
    private var reportSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Report User")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Please provide a reason for reporting this user:")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                TextField("Reason for report...", text: $reportReason, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
                
                Button("Submit Report") {
                    chatViewModel.reportMessage(Message(id: "", chatId: "", senderId: "", receiverId: "", content: ""), reason: reportReason)
                    showingReportSheet = false
                    reportReason = ""
                }
                .buttonStyle(.borderedProminent)
                .disabled(reportReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Report User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingReportSheet = false
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        let content = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        
        chatViewModel.sendMessage(content)
        messageText = ""
    }
}

struct MessageBubbleView: View {
    let message: Message
    let isFromCurrentUser: Bool
    let onLongPress: () -> Void
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                // Message content
                if message.messageType == .image {
                    // Image message
                    if let imageURL = message.imageURL {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 200, maxHeight: 200)
                                .cornerRadius(12)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 200, height: 200)
                                .cornerRadius(12)
                                .overlay(
                                    ProgressView()
                                )
                        }
                    }
                } else {
                    // Text message
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isFromCurrentUser ? Color.blue : Color(.systemGray5))
                        .foregroundColor(isFromCurrentUser ? .white : .primary)
                        .cornerRadius(16)
                }
                
                // Message metadata
                HStack(spacing: 4) {
                    Text(message.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if isFromCurrentUser {
                        // Read receipts
                        if message.isRead {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .font(.caption2)
                        } else if message.isDelivered {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.secondary)
                                .font(.caption2)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.secondary)
                                .font(.caption2)
                        }
                    }
                }
            }
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
        .onLongPressGesture {
            onLongPress()
        }
    }
}

#Preview {
    ChatView(chat: ChatPreview(
        from: Chat(id: "preview", participants: ["user1", "user2"]),
        otherParticipant: User(id: "user2", email: "test@example.com", displayName: "John Doe"),
        listing: nil
    ))
}
