import SwiftUI

struct ChatView: View {
    let chat: ChatPreview
    let onChatCreated: ((ChatPreview) -> Void)?
    @StateObject private var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showUserProfile = false
    @State private var showReportSheet = false
    @State private var reportReason = ""
    
    init(chat: ChatPreview, onChatCreated: ((ChatPreview) -> Void)? = nil) {
        self.chat = chat
        self.onChatCreated = onChatCreated
        let otherUserId = chat.participants.first { $0 != "currentUser" } ?? ""
        
        // Check if this is a temporary chat (starts with "temp_")
        let isTemporaryChat = chat.id.hasPrefix("temp_")
        
        self._viewModel = StateObject(wrappedValue: ChatViewModel(
            chatId: chat.id,
            currentUserId: "currentUser",
            otherUserId: otherUserId,
            isTemporaryChat: isTemporaryChat,
            listing: chat.listing,
            onChatCreated: onChatCreated
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chat Header
                ChatHeaderView(
                    chat: chat,
                    onUserProfile: { showUserProfile = true },
                    onMoreActions: { viewModel.showUserActions = true },
                    onDismiss: {
                        // Call the dismiss method to handle chat creation
                        viewModel.onChatDismissed()
                        dismiss()
                    }
                )
                
                // Messages
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading messages...")
                        .foregroundColor(Constants.Colors.secondaryLabel)
                    Spacer()
                } else {
                    MessagesScrollView(messages: viewModel.messages, currentUserId: "currentUser")
                    
                    // Typing Indicator
                    if viewModel.isOtherUserTyping {
                        HStack {
                            Text("Seller is typing...")
                                .font(.caption)
                                .foregroundColor(Constants.Colors.secondaryLabel)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            Spacer()
                        }
                    }
                }
                
                // Message Input
                MessageInputView(
                    text: $viewModel.newMessageText,
                    canSend: viewModel.canSendMessage,
                    onSend: viewModel.sendMessage,
                    onImagePicker: { viewModel.showImagePicker = true }
                )
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showImagePicker) {
                ChatImagePicker(selectedImage: $viewModel.selectedImage, onImageSelected: viewModel.selectImage)
            }
            .sheet(isPresented: $showUserProfile) {
                UserProfileView(user: chat.otherParticipant ?? User(id: "", email: "", displayName: "Unknown"))
            }
            .actionSheet(isPresented: $viewModel.showUserActions) {
                ActionSheet(
                    title: Text("User Actions"),
                    buttons: [
                        .default(Text("View Profile")) {
                            showUserProfile = true
                        },
                        .destructive(Text("Block User")) {
                            viewModel.blockUser()
                        },
                        .destructive(Text("Report User")) {
                            showReportSheet = true
                        },
                        .destructive(Text("Delete Chat")) {
                            viewModel.deleteChat()
                        },
                        .cancel()
                    ]
                )
            }
            .alert("Report User", isPresented: $showReportSheet) {
                TextField("Reason for reporting", text: $reportReason)
                Button("Submit") {
                    viewModel.reportUser(reason: reportReason)
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please provide a reason for reporting this user.")
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.dismissError()
                }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

// MARK: - Chat Header
struct ChatHeaderView: View {
    let chat: ChatPreview
    let onUserProfile: () -> Void
    let onMoreActions: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Constants.Colors.label)
                    .font(.title2)
                    .padding(8)
            }
            
            Button(action: onUserProfile) {
                Circle()
                    .fill(Constants.Colors.sampleCardBackground)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(chat.otherParticipant?.displayName.prefix(1) ?? "?"))
                            .font(.headline)
                            .foregroundColor(Constants.Colors.label)
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(chat.otherParticipant?.displayName ?? "Unknown User")
                    .font(.headline)
                    .foregroundColor(Constants.Colors.label)
                
                if let listing = chat.listing {
                    Text(listing.title)
                        .font(.caption)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                }
            }
            
            Spacer()
            
            Button(action: onMoreActions) {
                Image(systemName: "ellipsis")
                    .foregroundColor(Constants.Colors.label)
                    .padding(8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .bottom
        )
    }
}

// MARK: - Messages Scroll View
struct MessagesScrollView: View {
    let messages: [Message]
    let currentUserId: String
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(messages) { message in
                        MessageBubbleView(
                            message: message,
                            isFromCurrentUser: message.senderId == currentUserId
                        )
                        .id(message.id)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .onAppear {
                if let lastMessage = messages.last {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: messages.count) { _ in
                if let lastMessage = messages.last {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

// MARK: - Message Bubble View
struct MessageBubbleView: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                // Message content
                if message.messageType == .image {
                    ImageMessageView(message: message)
                } else {
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            isFromCurrentUser ? Constants.Colors.label : Constants.Colors.sampleCardBackground
                        )
                        .foregroundColor(
                            isFromCurrentUser ? .white : Constants.Colors.label
                        )
                        .cornerRadius(16)
                }
                
                // Message metadata
                HStack(spacing: 4) {
                    Text(timeString(from: message.timestamp))
                        .font(.caption2)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                    
                    if isFromCurrentUser {
                        // Read receipt
                        if message.isRead {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Constants.Colors.label)
                                .font(.caption2)
                        } else if message.isDelivered {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(Constants.Colors.secondaryLabel)
                                .font(.caption2)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(Constants.Colors.secondaryLabel)
                                .font(.caption2)
                        }
                    }
                }
            }
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Image Message View
struct ImageMessageView: View {
    let message: Message
    
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray4))
                .frame(width: 200, height: 150)
                .overlay(
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                )
            
            if !message.content.isEmpty && message.content != "Image" {
                Text(message.content)
                    .font(.caption)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Message Input View
struct MessageInputView: View {
    @Binding var text: String
    let canSend: Bool
    let onSend: () -> Void
    let onImagePicker: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onImagePicker) {
                Image(systemName: "photo")
                    .foregroundColor(Constants.Colors.label)
                    .font(.title2)
                    .padding(8)
            }
            
            TextField("Type a message...", text: $text, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .lineLimit(1...4)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Constants.Colors.sampleCardBackground)
                .cornerRadius(20)
            
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(canSend ? Constants.Colors.label : Constants.Colors.secondaryLabel)
                    .font(.title2)
                    .padding(8)
            }
            .disabled(!canSend)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .top
        )
    }
}

// MARK: - User Profile View
struct UserProfileView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Image
                Circle()
                    .fill(Constants.Colors.sampleCardBackground)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text(String(user.displayName.prefix(1)))
                            .font(.largeTitle)
                            .foregroundColor(Constants.Colors.label)
                    )
                
                // User Info
                VStack(spacing: 8) {
                    Text(user.displayName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.label)
                    
                    Text(user.email)
                        .font(.body)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                    
                    if let bio = user.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.body)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

// MARK: - Chat Image Picker
struct ChatImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let onImageSelected: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ChatImagePicker
        
        init(_ parent: ChatImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageSelected(image)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    let sampleChat = ChatPreview(
        from: Chat(id: "1", participants: ["user1", "user2"], listingId: "listing1"),
        otherParticipant: User(id: "user1", email: "john@example.com", displayName: "John Smith"),
        listing: Listing(
            id: "listing1", 
            sellerId: "user1", 
            title: "Vintage Chair", 
            description: "Beautiful vintage chair in excellent condition",
            price: 120.0, 
            category: .furniture,
            condition: .excellent,
            location: Location(city: "San Francisco", state: "CA")
        )
    )
    
    ChatView(chat: sampleChat)
}
