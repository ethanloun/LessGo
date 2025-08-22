import SwiftUI
import CoreData

struct NewMessageView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var searchText = ""
    @State private var selectedUser: CDUser?
    @State private var showChatView = false
    
    private var filteredUsers: [CDUser] {
        let users = fetchUsers()
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { user in
                let username = user.displayName ?? ""
                let email = user.email ?? ""
                return username.localizedCaseInsensitiveContains(searchText) ||
                       email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Simple Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search users...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button("Clear") {
                            searchText = ""
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                
                if filteredUsers.isEmpty {
                    Spacer()
                    Text("No users found")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    List(filteredUsers) { user in
                        HStack {
                            Text(user.displayName ?? "Unknown")
                            Spacer()
                            Text(user.email ?? "")
                                .foregroundColor(.secondary)
                        }
                            .onTapGesture {
                                selectedUser = user
                                showChatView = true
                            }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color(.systemBackground))
                }
            }
            .background(Color(.systemBackground))
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
                        from: Chat(id: UUID().uuidString, participants: ["currentUser", user.id ?? ""]),
                        otherParticipant: User(id: user.id ?? "", email: user.email ?? "", displayName: user.displayName ?? "")
                    )
                    ChatView(chat: newChat)
                }
            }
        }
    }
    
    private func fetchUsers() -> [CDUser] {
        let request: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDUser.displayName, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching users: \(error)")
            return []
        }
    }
}

#Preview {
    NewMessageView()
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
