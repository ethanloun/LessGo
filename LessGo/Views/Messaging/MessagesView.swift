import SwiftUI

struct MessagesView: View {
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea(.all)
            VStack(spacing: 0) {
                // Messages List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(sampleMessages, id: \.id) { message in
                            MessageRowView(message: message)
                        }
                    }
                }
            }
        }
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var sampleMessages: [ChatMessage] {
        [
            ChatMessage(id: "1", senderName: "John Smith", lastMessage: "Hi! Is this item still available?", timestamp: Date(), isRead: false),
            ChatMessage(id: "2", senderName: "Sarah Johnson", lastMessage: "Great! I'll take it. When can we meet?", timestamp: Date().addingTimeInterval(-3600), isRead: true),
            ChatMessage(id: "3", senderName: "Mike Wilson", lastMessage: "Can you do $80 for the chair?", timestamp: Date().addingTimeInterval(-7200), isRead: true),
            ChatMessage(id: "4", senderName: "Emma Davis", lastMessage: "Thanks for the quick delivery!", timestamp: Date().addingTimeInterval(-86400), isRead: true),
            ChatMessage(id: "5", senderName: "Alex Chen", lastMessage: "Do you have more photos?", timestamp: Date().addingTimeInterval(-172800), isRead: false)
        ]
    }
}

struct ChatMessage {
    let id: String
    let senderName: String
    let lastMessage: String
    let timestamp: Date
    let isRead: Bool
}

struct MessageRowView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            // Avatar
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(message.senderName.prefix(1)))
                        .font(.headline)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(message.senderName)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Text(timeAgoString(from: message.timestamp))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Text(message.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }
            
            if !message.isRead {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 8, height: 8)
            }
        }
        .padding()
        .background(message.isRead ? Color.clear : Color.white.opacity(0.1))
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle tap
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

#Preview {
    MessagesView()
}
