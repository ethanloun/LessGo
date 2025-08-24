import SwiftUI

struct ListingCardView: View {
    let listing: Listing
    let onMessageSeller: (() -> Void)?
    @State private var isFavorite = false
    @State private var showSellerContact = false
    
    private let persistenceController = PersistenceController.shared
    
    init(listing: Listing, onMessageSeller: (() -> Void)? = nil) {
        self.listing = listing
        self.onMessageSeller = onMessageSeller
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Design.spacing) {
            // Image Section
            ZStack(alignment: .topTrailing) {
                // Placeholder image (replace with actual image loading)
                Rectangle()
                    .fill(Constants.Colors.sampleCardBackground)
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        VStack {
                            Image(systemName: listing.category.iconName)
                                .font(.system(size: 40))
                                .foregroundColor(Constants.Colors.secondaryLabel)
                            Text(listing.category.displayName)
                                .font(.caption)
                                .foregroundColor(Constants.Colors.secondaryLabel)
                        }
                    )
                
                // Favorite Button
                Button(action: {
                    toggleFavorite()
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundColor(isFavorite ? .red : Constants.Colors.label)
                        .padding(Constants.Design.smallPadding)
                        .background(Constants.Colors.background.opacity(0.9))
                        .clipShape(Circle())
                }
                .padding(Constants.Design.smallPadding)
            }
            .cornerRadius(Constants.Design.cornerRadius)
            
            // Content Section
            VStack(alignment: .leading, spacing: Constants.Design.smallSpacing) {
                // Title and Price
                HStack {
                    Text(listing.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.label)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Text(listing.formattedPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Colors.primary)
                }
                
                // Condition and Category
                HStack(spacing: Constants.Design.smallSpacing) {
                    Text(listing.condition.displayName)
                        .font(.caption)
                        .padding(.horizontal, Constants.Design.smallPadding)
                        .padding(.vertical, 4)
                        .background(Color(listing.condition.color).opacity(0.2))
                        .foregroundColor(Color(listing.condition.color))
                        .cornerRadius(Constants.Design.smallCornerRadius)
                    
                    Text(listing.category.displayName)
                        .font(.caption)
                        .padding(.horizontal, Constants.Design.smallPadding)
                        .padding(.vertical, 4)
                        .background(Constants.Colors.tertiaryBackground)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                        .cornerRadius(Constants.Design.smallCornerRadius)
                }
                
                // Description
                if !listing.description.isEmpty {
                    Text(listing.description)
                        .font(.subheadline)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                        .lineLimit(2)
                }
                
                // Location and Time
                HStack {
                    HStack(spacing: Constants.Design.smallSpacing) {
                        Image(systemName: "location")
                            .font(.caption)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                        
                        Text(listing.location.formattedAddress())
                            .font(.caption)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Text(listing.createdAt.timeAgo)
                        .font(.caption)
                        .foregroundColor(Constants.Colors.tertiaryLabel)
                }
                
                // Stats
                HStack(spacing: Constants.Design.largeSpacing) {
                    HStack(spacing: Constants.Design.smallSpacing) {
                        Image(systemName: "eye")
                            .font(.caption)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                        Text("\(listing.views)")
                            .font(.caption)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                    
                    HStack(spacing: Constants.Design.smallSpacing) {
                        Image(systemName: "heart")
                            .font(.caption)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                        Text("\(listing.favorites)")
                            .font(.caption)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                    
                    if listing.isNegotiable {
                        HStack(spacing: Constants.Design.smallSpacing) {
                            Image(systemName: "handshake")
                                .font(.caption)
                                .foregroundColor(Constants.Colors.secondaryLabel)
                            Text("Negotiable")
                                .font(.caption)
                                .foregroundColor(Constants.Colors.secondaryLabel)
                        }
                    }
                }
                
                // Message Seller Button
                Button(action: {
                    showSellerContact = true
                }) {
                    HStack {
                        Image(systemName: "message")
                            .font(.caption)
                        Text("Message Seller")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, Constants.Design.spacing)
                    .padding(.vertical, 8)
                    .background(Constants.Colors.label)
                    .cornerRadius(Constants.Design.smallCornerRadius)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, Constants.Design.spacing)
            .padding(.bottom, Constants.Design.spacing)
        }
        .background(Constants.Colors.background)
        .cornerRadius(Constants.Design.cornerRadius)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showSellerContact) {
            SellerContactView(
                listing: listing,
                onDismiss: {
                    showSellerContact = false
                }
            )
        }
        .onAppear {
            checkFavoriteStatus()
        }
    }
    
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

#Preview {
    ListingCardView(
        listing: Listing(
            id: "1",
            sellerId: "seller1",
            title: "iPhone 13 Pro - Excellent Condition",
            description: "iPhone 13 Pro in excellent condition. 128GB storage, Pacific Blue. Includes original box and charger.",
            price: 699.99,
            category: .electronics,
            condition: .excellent,
            location: Location(city: "San Francisco", state: "CA")
        ),
        onMessageSeller: {
            print("Message seller tapped")
        }
    )
    .padding()
}





