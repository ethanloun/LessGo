import SwiftUI
import MapKit

// MARK: - Main View

struct ListingFeedView: View {
    @EnvironmentObject var listingViewModel: ListingViewModel
    @State private var showingFilters = false
    @State private var showingMap = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header extracted to its own view
            ListingFeedHeaderView(showingMap: $showingMap)
                .environmentObject(listingViewModel)
            
            // Content
            ListingFeedContentView(showingMap: showingMap)
                .environmentObject(listingViewModel)
        }
        .background(Color.blue)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("LessGo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingFilters.toggle()
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            FiltersView()
                .environmentObject(listingViewModel)
        }
        .refreshable {
            await listingViewModel.refreshListings()
        }
        .alert("Error", isPresented: $listingViewModel.showError) {
            Button("OK") {
                listingViewModel.dismissError()
            }
        } message: {
            Text(listingViewModel.errorMessage ?? "An error occurred")
        }
    }
}

// MARK: - Header View

struct ListingFeedHeaderView: View {
    @EnvironmentObject var listingViewModel: ListingViewModel
    @Binding var showingMap: Bool
    
    var body: some View {
        VStack(spacing: Constants.Design.spacing) {
            // Search Bar
            SearchBarView(searchText: $listingViewModel.searchText)
            
            // Quick Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Design.spacing) {
                    
                    // Category Filter
                    Menu {
                        ForEach(Category.allCases, id: \.self) { category in
                            Button(action: {
                                listingViewModel.selectedCategory = listingViewModel.selectedCategory == category ? nil : category
                            }) {
                                HStack {
                                    Text(category.displayName)
                                    if listingViewModel.selectedCategory == category {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "tag")
                            Text(listingViewModel.selectedCategory?.displayName ?? "All Categories")
                            Image(systemName: "chevron.down")
                        }
                        .font(.subheadline)
                        .padding(.horizontal, Constants.Design.padding)
                        .padding(.vertical, Constants.Design.smallPadding)
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(Constants.Design.cornerRadius)
                    }
                    
                    // Price Filter
                    Menu {
                        Button("Any Price") {
                            listingViewModel.priceRange = 0...10000
                        }
                        Button("Under $50") {
                            listingViewModel.priceRange = 0...50
                        }
                        Button("$50 - $200") {
                            listingViewModel.priceRange = 50...200
                        }
                        Button("$200 - $500") {
                            listingViewModel.priceRange = 200...500
                        }
                        Button("Over $500") {
                            listingViewModel.priceRange = 500...10000
                        }
                    } label: {
                        HStack {
                            Image(systemName: "dollarsign.circle")
                            Text("Price")
                            Image(systemName: "chevron.down")
                        }
                        .font(.subheadline)
                        .padding(.horizontal, Constants.Design.padding)
                        .padding(.vertical, Constants.Design.smallPadding)
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(Constants.Design.cornerRadius)
                    }
                    
                    // View Toggle
                    Button(action: {
                        showingMap.toggle()
                    }) {
                        HStack {
                            Image(systemName: showingMap ? "list.bullet" : "map")
                            Text(showingMap ? "List" : "Map")
                        }
                        .font(.subheadline)
                        .padding(.horizontal, Constants.Design.padding)
                        .padding(.vertical, Constants.Design.smallPadding)
                        .background(Constants.Colors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(Constants.Design.cornerRadius)
                    }
                }
                .padding(.horizontal, Constants.Design.largePadding)
            }
        }
        .padding(.top, Constants.Design.spacing)
        .background(Color.blue)
    }
}

// MARK: - Content View

struct ListingFeedContentView: View {
    @EnvironmentObject var listingViewModel: ListingViewModel
    var showingMap: Bool
    
    var body: some View {
        if showingMap {
            MapView(listings: listingViewModel.filteredListings)
                .environmentObject(listingViewModel)
        } else {
            if listingViewModel.filteredListings.isEmpty {
                EmptyStateView()
            } else {
                ListingsListView(listings: listingViewModel.filteredListings)
                    .environmentObject(listingViewModel)
            }
        }
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: Constants.Design.largeSpacing) {
            Spacer()
            Image(systemName: "bag.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.white)
            VStack(spacing: Constants.Design.spacing) {
                Text("Welcome to LessGo!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("Start exploring amazing deals in your local marketplace. Browse listings below or use the search to find exactly what you need.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding(.horizontal, Constants.Design.largePadding)
        .background(Color.blue)
    }
}

// MARK: - Placeholder MapView

struct MapView: View {
    var listings: [Listing] // Replace with your model
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        Map(coordinateRegion: $region)
    }
}

// MARK: - Placeholder FiltersView

struct FiltersView: View {
    @EnvironmentObject var listingViewModel: ListingViewModel
    
    var body: some View {
        Text("Filters go here")
            .padding()
    }
}

// MARK: - Preview

#Preview {
    ListingFeedView()
        .environmentObject(ListingViewModel())
}

