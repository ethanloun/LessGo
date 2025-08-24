import SwiftUI
import CoreData

struct FavoritesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text("Favorites")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Items you've saved for later")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                Spacer()
                
                // Favorites content
                if favoritesViewModel.favorites.isEmpty {
                    VStack(spacing: 16) {
                        Text("❤️")
                            .font(.system(size: 80))
                        
                        Text("No favorites yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Save items you're interested in by tapping the heart icon on any listing.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(favoritesViewModel.favorites, id: \.id) { listing in
                            FavoriteListingRow(listing: listing)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        favoritesViewModel.refreshFavorites()
                    }
                }
            }
            .onAppear {
                favoritesViewModel.refreshFavorites()
            }
        }
    }
}

#Preview {
    FavoritesView()
}
