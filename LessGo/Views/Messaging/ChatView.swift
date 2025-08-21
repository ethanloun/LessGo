import SwiftUI

struct ChatView: View {
    let chat: ChatPreview
    let onChatCreated: ((ChatPreview) -> Void)?
    
    var body: some View {
        VStack {
            Text("Chat View")
                .font(.title)
            Text("Chat ID: \(chat.id)")
                .font(.caption)
            Text("This is a placeholder view")
                .foregroundColor(.secondary)
        }
        .navigationTitle("Chat")
    }
}
