import SwiftUI

struct FavoriteListingRow: View {
    let listing: Listing
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    
    var body: some View {
        NavigationLink(destination: ListingDetailView(listing: listing)) {
            HStack(spacing: 12) {
            // Listing image
            if let firstImage = listing.images.first {
                AsyncImage(url: URL(string: firstImage)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 60, height: 60)
                .clipped()
                .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            }
            
            // Listing details
            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text("$\(String(format: "%.2f", listing.price))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Text(listing.condition.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
            
            Spacer()
            
            // Favorite button
            Button(action: {
                toggleFavorite()
            }) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle()) // Prevent NavigationLink default styling
    }
    
    private func toggleFavorite() {
        let currentUserId = "currentUser"
        let _ = PersistenceController.shared.toggleFavorite(userId: currentUserId, listingId: listing.id)
        favoritesViewModel.refreshFavorites()
    }
}

#Preview {
    FavoriteListingRow(listing: Listing(
        id: "preview",
        sellerId: "seller",
        title: "Sample Item",
        description: "A sample item for preview",
        price: 99.99,
        category: .electronics,
        condition: .good,
        location: Location(latitude: 0, longitude: 0, address: "123 Main St", city: "City")
    ))
}
