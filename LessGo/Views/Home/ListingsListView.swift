import SwiftUI

struct ListingsListView: View {
    let listings: [Listing]
    let onMessageSeller: (() -> Void)?
    @EnvironmentObject var listingViewModel: ListingViewModel
    
    init(listings: [Listing], onMessageSeller: (() -> Void)? = nil) {
        self.listings = listings
        self.onMessageSeller = onMessageSeller
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: Constants.Design.spacing) {
                if listings.isEmpty {
                    // Show empty state without creating white space
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
                } else {
                    ForEach(listings) { listing in
                        NavigationLink(destination: ListingDetailView(listing: listing)) {
                            ListingCardView(listing: listing, onMessageSeller: onMessageSeller)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Load more button
                    if listingViewModel.hasMoreListings {
                        Button(action: {
                            Task {
                                await listingViewModel.loadMoreListings()
                            }
                        }) {
                            HStack {
                                if listingViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                } else {
                                    Text("Load More")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: Constants.Design.buttonHeight)
                            .background(Constants.Colors.sampleCardBackground)
                            .foregroundColor(Constants.Colors.label)
                            .cornerRadius(Constants.Design.cornerRadius)
                        }
                        .disabled(listingViewModel.isLoading)
                        .padding(.horizontal, Constants.Design.largePadding)
                    }
                }
            }
            .padding(.horizontal, Constants.Design.largePadding)
            .padding(.bottom, Constants.Design.spacing)
        }
        .background(Constants.Colors.background.ignoresSafeArea(.all))
    }
}

#Preview {
    ListingsListView(listings: [])
        .environmentObject(ListingViewModel())
}



