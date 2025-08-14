import SwiftUI

struct ListingCardView: View {
    let listing: Listing
    @State private var isFavorite = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Design.spacing) {
            // Image Section
            ZStack(alignment: .topTrailing) {
                // Placeholder image (replace with actual image loading)
                Rectangle()
                    .fill(Constants.Colors.secondaryBackground)
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
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isFavorite.toggle()
                    }
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundColor(isFavorite ? .red : .white)
                        .padding(Constants.Design.smallPadding)
                        .background(.ultraThinMaterial)
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
            }
            .padding(.horizontal, Constants.Design.spacing)
            .padding(.bottom, Constants.Design.spacing)
        }
        .background(Constants.Colors.background)
        .cornerRadius(Constants.Design.cornerRadius)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    ListingCardView(listing: Listing(
        id: "1",
        sellerId: "seller1",
        title: "iPhone 13 Pro - Excellent Condition",
        description: "iPhone 13 Pro in excellent condition. 128GB storage, Pacific Blue. Includes original box and charger.",
        price: 699.99,
        category: .electronics,
        condition: .excellent,
        location: Location(latitude: 37.7749, longitude: -122.4194, city: "San Francisco", state: "CA")
    ))
    .padding()
}




