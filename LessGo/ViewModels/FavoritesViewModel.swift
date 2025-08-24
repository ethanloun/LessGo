import Foundation
import CoreData
import Combine

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Listing] = []
    @Published var isLoading = false
    
    private let persistenceController = PersistenceController.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadFavorites()
    }
    
    func loadFavorites() {
        isLoading = true
        
        // For now, use a hardcoded user ID. In a real app, this would come from authentication
        let currentUserId = "currentUser"
        
        let coreDataFavorites = persistenceController.fetchUserFavoritesAsListings(userId: currentUserId)
        favorites = coreDataFavorites.map { $0.toListing() }
        
        isLoading = false
    }
    
    func refreshFavorites() {
        loadFavorites()
    }
}
