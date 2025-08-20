import SwiftUI

struct SearchView: View {
    let onMessageSeller: (() -> Void)?
    @EnvironmentObject var listingViewModel: ListingViewModel
    @State private var showingFilters = false
    
    init(onMessageSeller: (() -> Void)? = nil) {
        self.onMessageSeller = onMessageSeller
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Text("Search")
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
                // Search Header
                VStack(spacing: Constants.Design.spacing) {
                    HomeSearchBarView(searchText: $listingViewModel.searchText)
                    
                    // Quick Search Suggestions
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Constants.Design.spacing) {
                            ForEach(["Electronics", "Furniture", "Clothing", "Sports", "Books"], id: \.self) { suggestion in
                                Button(action: {
                                    listingViewModel.searchText = suggestion
                                }) {
                                    Text(suggestion)
                                        .font(.subheadline)
                                        .padding(.horizontal, Constants.Design.padding)
                                        .padding(.vertical, Constants.Design.smallPadding)
                                        .background(Constants.Colors.sampleCardBackground)
                                        .foregroundColor(Constants.Colors.label)
                                        .cornerRadius(Constants.Design.cornerRadius)
                                }
                            }
                        }
                        .padding(.horizontal, Constants.Design.largePadding)
                    }
                }
                .padding(.top, Constants.Design.spacing)
                .background(Constants.Colors.background)
                
                // Search Results
                if listingViewModel.searchText.isEmpty {
                    SearchSuggestionsView()
                } else if listingViewModel.filteredListings.isEmpty {
                    NoSearchResultsView(searchText: listingViewModel.searchText)
                } else {
                    ListingsListView(listings: listingViewModel.filteredListings, onMessageSeller: onMessageSeller)
                        .environmentObject(listingViewModel)
                }
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
    }
}

struct SearchSuggestionsView: View {
    var body: some View {
        VStack(spacing: Constants.Design.largeSpacing) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.secondaryLabel)
            
            VStack(spacing: Constants.Design.spacing) {
                Text("Search for Items")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Text("Find exactly what you're looking for by searching our local marketplace.")
                    .font(.subheadline)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, Constants.Design.largePadding)
        .background(Constants.Colors.background)
    }
}

struct NoSearchResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: Constants.Design.largeSpacing) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.secondaryLabel)
            
            VStack(spacing: Constants.Design.spacing) {
                Text("No Results Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Text("We couldn't find any items matching \"\(searchText)\". Try adjusting your search terms or filters.")
                    .font(.subheadline)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, Constants.Design.largePadding)
        .background(Constants.Colors.background)
    }
}

#Preview {
    SearchView()
        .environmentObject(ListingViewModel())
}

