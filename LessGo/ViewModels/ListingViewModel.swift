import Foundation
import SwiftUI
import Combine

@MainActor
class ListingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var listings: [Listing] = []
    @Published var filteredListings: [Listing] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: Category?
    @Published var priceRange: ClosedRange<Double> = 0...10000
    @Published var isLoading: Bool = false
    @Published var hasMoreListings: Bool = true
    @Published var showError: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private var currentPage: Int = 1
    private let listingsPerPage: Int = 20
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var totalListings: Int {
        return listings.count
    }
    
    var isSearching: Bool {
        return !searchText.isEmpty
    }
    
    // MARK: - Initialization
    init() {
        setupBindings()
        // Load sample data immediately
        loadSampleData()
        Task {
            await loadInitialListings()
        }
    }
    
    // MARK: - Sample Data Loading
    private func loadSampleData() {
        let sampleListings = generateMockListings()
        listings = sampleListings
        filterListings(searchText: searchText, category: selectedCategory, priceRange: priceRange)
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Combine search text and category changes to update filtered listings
        Publishers.CombineLatest3(
            $searchText,
            $selectedCategory,
            $priceRange
        )
        .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
        .sink { [weak self] searchText, category, priceRange in
            self?.filterListings(searchText: searchText, category: category, priceRange: priceRange)
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func loadInitialListings() async {
        guard !isLoading else { return }
        
        isLoading = true
        currentPage = 1
        
        do {
            // For now, generate mock data
            let mockListings = generateMockListings()
            listings = mockListings
            filterListings(searchText: searchText, category: selectedCategory, priceRange: priceRange)
            hasMoreListings = mockListings.count >= listingsPerPage
        } catch {
            showError(message: "Failed to load listings: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func refreshListings() async {
        await loadInitialListings()
    }
    
    func loadMoreListings() async {
        guard !isLoading && hasMoreListings else { return }
        
        isLoading = true
        currentPage += 1
        
        do {
            // Simulate API call delay
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            // Generate more mock data
            let moreListings = generateMockListings(page: currentPage)
            listings.append(contentsOf: moreListings)
            filterListings(searchText: searchText, category: selectedCategory, priceRange: priceRange)
            hasMoreListings = moreListings.count >= listingsPerPage
        } catch {
            showError(message: "Failed to load more listings: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func dismissError() {
        showError = false
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    private func filterListings(searchText: String, category: Category?, priceRange: ClosedRange<Double>) {
        var filtered = listings
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { listing in
                listing.title.localizedCaseInsensitiveContains(searchText) ||
                listing.description.localizedCaseInsensitiveContains(searchText) ||
                listing.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Filter by category
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by price range
        filtered = filtered.filter { listing in
            priceRange.contains(listing.price)
        }
        
        // Sort by relevance (featured first, then by date)
        filtered.sort { listing1, listing2 in
            if listing1.isFeatured != listing2.isFeatured {
                return listing1.isFeatured
            }
            return listing1.createdAt > listing2.createdAt
        }
        
        filteredListings = filtered
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    // MARK: - Mock Data Generation
    private func generateMockListings(page: Int = 1) -> [Listing] {
        let categories: [Category] = Category.allCases
        let conditions: [ItemCondition] = ItemCondition.allCases
        
        var mockListings: [Listing] = []
        let startIndex = (page - 1) * listingsPerPage
        
        for i in startIndex..<(startIndex + listingsPerPage) {
            let category = categories[i % categories.count]
            let condition = conditions[i % conditions.count]
            let price = Double.random(in: 10...1000)
            
            let listing = Listing(
                id: "listing_\(i)",
                sellerId: "seller_\(i % 10)",
                title: "Sample \(category.displayName) Item \(i + 1)",
                description: "This is a sample description for a \(category.displayName.lowercased()) item in \(condition.displayName.lowercased()) condition. Great value for money!",
                price: price,
                category: category,
                condition: condition,
                location: Location(
                    latitude: Double.random(in: 37.7...37.8),
                    longitude: Double.random(in: -122.5...(-122.4)),
                    address: "Sample Address \(i + 1)",
                    city: "San Francisco",
                    state: "CA",
                    zipCode: "94102"
                )
            )
            
            // Add some random properties
            var modifiedListing = listing
            modifiedListing.images = ["image_\(i % 5)"]
            modifiedListing.isFeatured = i % 7 == 0
            modifiedListing.views = Int.random(in: 0...500)
            modifiedListing.favorites = Int.random(in: 0...50)
            modifiedListing.tags = ["sample", "demo", category.rawValue]
            modifiedListing.isNegotiable = Bool.random()
            modifiedListing.pickupOnly = Bool.random()
            modifiedListing.shippingAvailable = !modifiedListing.pickupOnly
            if modifiedListing.shippingAvailable {
                modifiedListing.shippingCost = Double.random(in: 5...25)
            }
            
            mockListings.append(modifiedListing)
        }
        
        return mockListings
    }
}

// MARK: - Extensions
extension ListingViewModel {
    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        priceRange = 0...10000
    }
    
    func toggleCategory(_ category: Category) {
        selectedCategory = selectedCategory == category ? nil : category
    }
    
    func setPriceRange(_ range: ClosedRange<Double>) {
        priceRange = range
    }
}
