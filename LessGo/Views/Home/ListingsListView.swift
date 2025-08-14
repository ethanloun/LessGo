import SwiftUI

struct ListingsListView: View {
    let listings: [Listing]
    @EnvironmentObject var listingViewModel: ListingViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: Constants.Design.spacing) {
                ForEach(listings) { listing in
                    ListingCardView(listing: listing)
                        .onTapGesture {
                            // TODO: Navigate to listing detail
                        }
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
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(Constants.Design.cornerRadius)
                    }
                    .disabled(listingViewModel.isLoading)
                    .padding(.horizontal, Constants.Design.largePadding)
                }
            }
            .padding(.horizontal, Constants.Design.largePadding)
            .padding(.bottom, Constants.Design.spacing)
        }
        .background(Color.blue.ignoresSafeArea(.all))
    }
}

#Preview {
    ListingsListView(listings: [])
        .environmentObject(ListingViewModel())
}



