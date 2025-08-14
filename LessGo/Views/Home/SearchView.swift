import SwiftUI

struct SearchView: View {
    @EnvironmentObject var listingViewModel: ListingViewModel
    @State private var showingFilters = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Header
            VStack(spacing: Constants.Design.spacing) {
                SearchBarView(searchText: $listingViewModel.searchText)
                
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
                                    .background(Color.white.opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(Constants.Design.cornerRadius)
                            }
                        }
                    }
                    .padding(.horizontal, Constants.Design.largePadding)
                }
            }
            .padding(.top, Constants.Design.spacing)
            .background(Color.blue)
            
            // Search Results
            if listingViewModel.searchText.isEmpty {
                SearchSuggestionsView()
            } else if listingViewModel.filteredListings.isEmpty {
                NoSearchResultsView(searchText: listingViewModel.searchText)
            } else {
                ListingsListView(listings: listingViewModel.filteredListings)
                    .environmentObject(listingViewModel)
            }
        }
        .background(Color.blue)
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
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
    }
}

struct SearchSuggestionsView: View {
    var body: some View {
        VStack(spacing: Constants.Design.largeSpacing) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.7))
            
            VStack(spacing: Constants.Design.spacing) {
                Text("Search for Items")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Find exactly what you're looking for by searching our local marketplace.")
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

struct NoSearchResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: Constants.Design.largeSpacing) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.7))
            
            VStack(spacing: Constants.Design.spacing) {
                Text("No Results Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("We couldn't find any items matching \"\(searchText)\". Try adjusting your search terms or filters.")
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

#Preview {
    SearchView()
        .environmentObject(ListingViewModel())
}

