import SwiftUI

struct NewMessageView: View {
    let viewModel: MessagingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedUser: User?
    @State private var showChatView = false
    
    // Sample users for demonstration
    private let sampleUsers = [
        User(id: "user1", email: "john@example.com", displayName: "John Smith"),
        User(id: "user2", email: "sarah@example.com", displayName: "Sarah Johnson"),
        User(id: "user3", email: "mike@example.com", displayName: "Mike Wilson"),
        User(id: "user4", email: "emma@example.com", displayName: "Emma Davis"),
        User(id: "user5", email: "alex@example.com", displayName: "Alex Chen")
    ]
    
    private var filteredUsers: [User] {
        if searchText.isEmpty {
            return sampleUsers
        } else {
            return sampleUsers.filter { user in
                user.displayName.localizedCaseInsensitiveContains(searchText) ||
                user.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBarView(searchText: $searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                if filteredUsers.isEmpty {
                    Spacer()
                    Text("No users found")
                        .foregroundColor(.secondary) // adaptive
                    Spacer()
                } else {
                    List(filteredUsers) { user in
                        UserRowView(user: user) {
                            selectedUser = user
                            showChatView = true
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color(.systemBackground)) // adaptive
                }
            }
            .background(Color(.systemBackground)) // adaptive
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Search") {
                    // search action
                }
                    .disabled(searchText.isEmpty)
            )
            .sheet(isPresented: $showChatView) {
                if let user = selectedUser {
                    let newChat = ChatPreview(
                        from: Chat(id: UUID().uuidString, participants: ["currentUser", user.id]),
                        otherParticipant: user
                    )
                    ChatView(chat: newChat)
                }
            }
        }
    }
}
// MARK: - User Row View
struct UserRowView: View {
    let user: User
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(Color(.systemGray5)) // adaptive background
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(user.displayName.prefix(1)))
                            .font(.headline)
                            .foregroundColor(.primary) // adaptive text
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.displayName)
                        .font(.headline)
                        .foregroundColor(.primary) // adaptive
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary) // adaptive
                    
                    if let bio = user.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.caption)
                            .foregroundColor(.secondary) // adaptive
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary) // adaptive
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NewMessageView(viewModel: MessagingViewModel(currentUserId: "currentUser"))
}
