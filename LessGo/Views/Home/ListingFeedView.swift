import SwiftUI
import MapKit

// MARK: - Main View

struct ListingFeedView: View {
    let onMessageSeller: (() -> Void)?
    @EnvironmentObject var listingViewModel: ListingViewModel
    @State private var showingFilters = false
    @State private var showingMap = false
    
    init(onMessageSeller: (() -> Void)? = nil) {
        self.onMessageSeller = onMessageSeller
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Text("LessGo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.label)
                Spacer()
                Button(action: {
                    showingFilters.toggle()
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(Constants.Colors.label)
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
            .background(Constants.Colors.background)
            
            // Content
            Group {
                // Header extracted to its own view
                ListingFeedHeaderView(showingMap: $showingMap)
                    .environmentObject(listingViewModel)
                
                // Main content
                ListingFeedContentView(onMessageSeller: onMessageSeller, showingMap: showingMap)
                    .environmentObject(listingViewModel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        // Make the whole screen white, including above the notch and above the custom tab bar
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Constants.Colors.background)
        .ignoresSafeArea(edges: [.top, .bottom])
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
            ListingSearchBarView(searchText: $listingViewModel.searchText)
            
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
                        .background(Constants.Colors.sampleCardBackground)
                        .foregroundColor(Constants.Colors.label)
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
                        .background(Constants.Colors.sampleCardBackground)
                        .foregroundColor(Constants.Colors.label)
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
                        .background(Constants.Colors.label)
                        .foregroundColor(.white)
                        .cornerRadius(Constants.Design.cornerRadius)
                    }
                }
                .padding(.horizontal, Constants.Design.largePadding)
            }
        }
        .background(Constants.Colors.background)
    }
}

// MARK: - Content View

struct ListingFeedContentView: View {
    let onMessageSeller: (() -> Void)?
    @EnvironmentObject var listingViewModel: ListingViewModel
    var showingMap: Bool
    
    var body: some View {
        if showingMap {
            MapView(listings: listingViewModel.filteredListings)
                .environmentObject(listingViewModel)
        } else {
            // Always show the listings view to avoid white space
            ListingsListView(listings: listingViewModel.filteredListings, onMessageSeller: onMessageSeller)
                .environmentObject(listingViewModel)
        }
    }
}

// MARK: - Listing Empty State View

struct ListingEmptyStateView: View {
    var body: some View {
        VStack(spacing: Constants.Design.largeSpacing) {
            Image(systemName: "bag.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Constants.Colors.label)
            VStack(spacing: Constants.Design.spacing) {
                Text("Welcome to LessGo!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                Text("Start exploring amazing deals in your local marketplace. Browse listings below or use the search to find exactly what you need.")
                    .font(.subheadline)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, Constants.Design.largePadding)
        .padding(.top, Constants.Design.largeSpacing)
        .background(Constants.Colors.background)
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

// MARK: - Listing Search Bar View

struct ListingSearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Constants.Colors.label)
            
            TextField("Search listings...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(Constants.Colors.label)
            
            if !searchText.isEmpty {
                Button("Clear") {
                    searchText = ""
                }
                .foregroundColor(Constants.Colors.label)
            }
        }
        .padding(.horizontal, Constants.Design.padding)
        .padding(.vertical, Constants.Design.smallPadding)
        .background(Constants.Colors.sampleCardBackground)
        .cornerRadius(Constants.Design.cornerRadius)
    }
}

// MARK: - Preview

#Preview {
    ListingFeedView()
        .environmentObject(ListingViewModel())
}

