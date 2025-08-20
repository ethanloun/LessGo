import SwiftUI

struct SellerContactView: View {
    let listing: Listing
    let onDismiss: () -> Void
    let onChatStarted: (() -> Void)?
    @EnvironmentObject var viewModel: MessagingViewModel
    @State private var showChatView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Enhanced Listing Information
                VStack(alignment: .leading, spacing: 16) {
                    // Header with image and basic info
                    HStack(alignment: .top, spacing: 16) {
                        // Listing Image Placeholder
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Constants.Colors.sampleCardBackground)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: listing.category.iconName)
                                    .font(.title)
                                    .foregroundColor(Constants.Colors.secondaryLabel)
                            )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(listing.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .lineLimit(3)
                                .foregroundColor(Constants.Colors.label)
                            
                            Text(listing.formattedPrice)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Constants.Colors.label)
                            
                            HStack {
                                Image(systemName: "tag.fill")
                                    .foregroundColor(Constants.Colors.secondaryLabel)
                                    .font(.caption)
                                Text(listing.category.displayName)
                                    .font(.subheadline)
                                    .foregroundColor(Constants.Colors.secondaryLabel)
                            }
                            
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                Text("Condition: \(listing.condition.rawValue.capitalized)")
                                    .font(.subheadline)
                                    .foregroundColor(Constants.Colors.secondaryLabel)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    // Description Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.label)
                        
                        Text(listing.description)
                            .font(.body)
                            .foregroundColor(Constants.Colors.label)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Divider()
                    
                    // Location Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.label)
                        
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.red)
                                .font(.subheadline)
                            Text("\(listing.location.city ?? "Unknown City"), \(listing.location.state ?? "Unknown State")")
                                .font(.body)
                                .foregroundColor(Constants.Colors.label)
                        }
                    }
                    
                    Divider()
                    
                    // Seller Information Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Seller Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.label)
                        
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(Constants.Colors.label)
                                .font(.subheadline)
                            Text("Seller ID: \(listing.sellerId)")
                                .font(.body)
                                .foregroundColor(Constants.Colors.label)
                        }
                        
                        // Additional listing details
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(Constants.Colors.secondaryLabel)
                                .font(.caption)
                            Text("Listed \(listing.daysSinceCreated) days ago")
                                .font(.caption)
                                .foregroundColor(Constants.Colors.secondaryLabel)
                        }
                        
                        if listing.isNegotiable {
                            HStack {
                                Image(systemName: "handshake.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text("Price is negotiable")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .padding()
                .background(Constants.Colors.sampleCardBackground)
                .cornerRadius(16)
                
                // Contact Options
                VStack(spacing: 16) {
                    Button(action: {
                        // Create a temporary seller user and chat preview for immediate chat access
                        let seller = User(
                            id: listing.sellerId,
                            email: "seller@example.com",
                            displayName: "Seller"
                        )
                        
                        // Create a temporary chat preview that will be used to open ChatView
                        let tempChat = Chat(
                            id: "temp_\(UUID().uuidString)",
                            participants: ["currentUser", listing.sellerId],
                            listingId: listing.id
                        )
                        
                        let tempChatPreview = ChatPreview(from: tempChat, otherParticipant: seller, listing: listing)
                        
                        // Store the temporary chat in the view model for later use
                        viewModel.tempChatPreview = tempChatPreview
                        showChatView = true
                        // Don't call onChatStarted here - only call it when chat is actually created
                    }) {
                        HStack {
                            Image(systemName: "message.fill")
                                .font(.title2)
                            Text("Message Seller")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Constants.Colors.label)
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    onDismiss()
                }
            )
            .sheet(isPresented: $showChatView) {
                if let tempChat = viewModel.tempChatPreview {
                    ChatView(
                        chat: tempChat,
                        onChatCreated: { actualChat in
                            // Add the actual chat to the messaging view model
                            viewModel.addNewChat(actualChat)
                            // Clear the temporary chat
                            viewModel.tempChatPreview = nil
                            // Don't close the chat or switch tabs - let the user continue chatting
                            // The chat will only close when they manually dismiss it, returning them to home page
                            // Note: onChatStarted is NOT called here, so no tab switching occurs
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    SellerContactView(
        listing: Listing(
            id: "1",
            sellerId: "seller123",
            title: "iPhone 13 Pro - Excellent Condition",
            description: "iPhone 13 Pro in excellent condition with 128GB storage in Pacific Blue. This device has been well-maintained and comes with the original box, charging cable, and documentation. No scratches or dents, battery health is at 92%. Perfect for anyone looking for a premium smartphone at a great price.",
            price: 699.99,
            category: .electronics,
            condition: .excellent,
            location: Location(city: "San Francisco", state: "CA")
        ),
        onDismiss: {},
        onChatStarted: {}
    )
    .environmentObject(MessagingViewModel(currentUserId: "currentUser"))
}
