import SwiftUI

struct ListingDetailView: View {
    let listing: Listing
    @Environment(\.dismiss) private var dismiss
    @State private var showingChatView = false
    @State private var currentImageIndex = 0
    @State private var isFavorite = false
    
    private let persistenceController = PersistenceController.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Images Section
                    imageCarousel
                    
                    // Content Section
                    VStack(alignment: .leading, spacing: 20) {
                        // Title and Price
                        titleAndPriceSection
                        
                        // Seller Info
                        sellerInfoSection
                        
                        // Description
                        descriptionSection
                        
                        // Details
                        detailsSection
                        
                        // Location
                        locationSection
                        
                        // Tags
                        if !listing.tags.isEmpty {
                            tagsSection
                        }
                        
                        // Action Buttons
                        actionButtonsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100) // Space for floating action button
                }
            }
            .ignoresSafeArea(edges: .top)
            .overlay(
                // Floating Action Button
                VStack {
                    Spacer()
                    Button(action: {
                        showingChatView = true
                    }) {
                        HStack {
                            Image(systemName: "message")
                            Text("Message Seller")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(25)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        toggleFavorite()
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingChatView) {
            // Create a direct chat with the seller
            let seller = User(
                id: listing.sellerId,
                email: "seller@example.com",
                displayName: "Seller"
            )
            
            let directChat = Chat(
                id: UUID().uuidString,
                participants: ["currentUser", listing.sellerId],
                listingId: listing.id
            )
            
            let chatPreview = ChatPreview(from: directChat, otherParticipant: seller, listing: listing)
            
            ChatView(chat: chatPreview)
        }
        .onAppear {
            checkFavoriteStatus()
        }
    }
    
    // MARK: - UI Components
    
    private var imageCarousel: some View {
        TabView(selection: $currentImageIndex) {
            if listing.images.isEmpty {
                // Placeholder when no images
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        VStack {
                            Image(systemName: listing.category.iconName)
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("No Images")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
                    .tag(0)
            } else {
                ForEach(0..<listing.images.count, id: \.self) { index in
                    AsyncImage(url: URL(string: listing.images[index])) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                ProgressView()
                            )
                    }
                    .clipped()
                    .tag(index)
                }
            }
        }
        .frame(height: 300)
        .tabViewStyle(PageTabViewStyle())
    }
    
    private var titleAndPriceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(listing.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            HStack {
                Text(listing.formattedPrice)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                if let originalPrice = listing.originalPrice, originalPrice > listing.price {
                    Text("$\(String(format: "%.2f", originalPrice))")
                        .font(.subheadline)
                        .strikethrough()
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "eye")
                            .font(.caption)
                        Text("\(listing.views)")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "heart")
                            .font(.caption)
                        Text("\(listing.favorites)")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            // Condition and Category
            HStack(spacing: 8) {
                Text(listing.condition.displayName)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(listing.condition.color).opacity(0.2))
                    .foregroundColor(Color(listing.condition.color))
                    .cornerRadius(12)
                
                Text(listing.category.displayName)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.secondary)
                    .cornerRadius(12)
                
                if listing.isNegotiable {
                    Text("Negotiable")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private var sellerInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Seller")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("S")
                            .font(.headline)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Seller")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < 4 ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                        Text("4.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(listing.description.isEmpty ? "No description provided." : listing.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                if let brand = listing.brand, !brand.isEmpty {
                    ListingDetailRow(title: "Brand", value: brand)
                }
                
                if let model = listing.model, !model.isEmpty {
                    ListingDetailRow(title: "Model", value: model)
                }
                
                ListingDetailRow(title: "Quantity", value: "\(listing.quantity)")
                ListingDetailRow(title: "Posted", value: listing.createdAt.timeAgo)
                
                if listing.shippingAvailable {
                    if let shippingCost = listing.shippingCost {
                        ListingDetailRow(title: "Shipping", value: shippingCost > 0 ? "$\(String(format: "%.2f", shippingCost))" : "Free")
                    } else {
                        ListingDetailRow(title: "Shipping", value: "Available")
                    }
                }
                
                if listing.pickupOnly {
                    ListingDetailRow(title: "Pickup", value: "Pickup only")
                }
            }
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(listing.location.city ?? "Unknown City")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if let address = listing.location.address, !address.isEmpty {
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(listing.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Button(action: {
                    toggleFavorite()
                }) {
                    HStack {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                        Text(isFavorite ? "Favorited" : "Add to Favorites")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundColor(isFavorite ? .red : .primary)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Button(action: {
                    // Share functionality
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundColor(.primary)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func toggleFavorite() {
        let currentUserId = "currentUser"
        let newFavoriteState = persistenceController.toggleFavorite(userId: currentUserId, listingId: listing.id)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isFavorite = newFavoriteState
        }
    }
    
    private func checkFavoriteStatus() {
        let currentUserId = "currentUser"
        isFavorite = persistenceController.isFavorited(userId: currentUserId, listingId: listing.id)
    }
}

// MARK: - Helper Views

struct ListingDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    ListingDetailView(listing: Listing(
        id: "preview",
        sellerId: "seller",
        title: "iPhone 13 Pro - Excellent Condition",
        description: "iPhone 13 Pro in excellent condition. 128GB storage, Pacific Blue. Includes original box and charger. No scratches or damage.",
        price: 699.99,
        category: .electronics,
        condition: .excellent,
        location: Location(latitude: 0, longitude: 0, address: "123 Main St", city: "San Francisco", state: "CA", zipCode: "94102")
    ))
}
