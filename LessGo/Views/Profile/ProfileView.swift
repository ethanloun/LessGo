import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingMyListings = false
    @State private var showingFavorites = false
    @State private var showingPurchaseHistory = false
    @State private var showingReviews = false
    @State private var showingSettings = false
    @State private var showingHelpSupport = false
    @State private var showingAbout = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.label)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
            .background(Constants.Colors.background)
            
            // Content
            Group {
                // Profile Content
                ZStack {
                    Constants.Colors.background.ignoresSafeArea(.all)
                    ScrollView {
                        VStack(spacing: 20) {
                        // Profile Header
                        VStack(spacing: 16) {
                            // Profile Picture
                            Button(action: {
                                showingSettings = true
                            }) {
                                Circle()
                                    .fill(Constants.Colors.sampleCardBackground)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Text("ET")
                                            .font(.largeTitle)
                                            .fontWeight(.bold)
                                            .foregroundColor(Constants.Colors.label)
                                    )
                                    .overlay(
                                        // Add a subtle edit indicator
                                        Circle()
                                            .stroke(Constants.Colors.secondaryLabel.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            
                            VStack(spacing: 4) {
                                Text("Ethan Thompson")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Constants.Colors.label)
                                
                                Text("Member since December 2024")
                                    .font(.subheadline)
                                    .foregroundColor(Constants.Colors.secondaryLabel)
                            }
                            
                            // Stats
                            HStack(spacing: 40) {
                                Button(action: {
                                    showingMyListings = true
                                }) {
                                    VStack {
                                        Text("12")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(Constants.Colors.label)
                                        Text("Sold")
                                            .font(.caption)
                                            .foregroundColor(Constants.Colors.secondaryLabel)
                                    }
                                }
                                
                                Button(action: {
                                    showingPurchaseHistory = true
                                }) {
                                    VStack {
                                        Text("8")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(Constants.Colors.label)
                                        Text("Bought")
                                            .font(.caption)
                                            .foregroundColor(Constants.Colors.secondaryLabel)
                                    }
                                }
                                
                                Button(action: {
                                    showingReviews = true
                                }) {
                                    VStack {
                                        Text("4.9")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(Constants.Colors.label)
                                        Text("Rating")
                                            .font(.caption)
                                            .foregroundColor(Constants.Colors.secondaryLabel)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Constants.Colors.sampleCardBackground)
                        .cornerRadius(12)
                        
                        // Menu Options
                        VStack(spacing: 0) {
                            ProfileMenuRow(icon: "list.bullet", title: "My Listings", action: {
                                showingMyListings = true
                            })
                            ProfileMenuRow(icon: "heart", title: "Favorites", action: {
                                showingFavorites = true
                            })
                            ProfileMenuRow(icon: "clock", title: "Purchase History", action: {
                                showingPurchaseHistory = true
                            })
                            ProfileMenuRow(icon: "star", title: "Reviews", action: {
                                showingReviews = true
                            })
                            ProfileMenuRow(icon: "gearshape", title: "Settings", action: {
                                showingSettings = true
                            })
                            ProfileMenuRow(icon: "questionmark.circle", title: "Help & Support", action: {
                                showingHelpSupport = true
                            })
                            ProfileMenuRow(icon: "info.circle", title: "About", action: {
                                showingAbout = true
                            })
                        }
                        .background(Constants.Colors.sampleCardBackground)
                        .cornerRadius(12)
                        
                        Spacer(minLength: 100)
                        }
                        .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        // Make the whole screen white, including above the notch and above the custom tab bar
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Constants.Colors.background)
        .ignoresSafeArea(edges: [.top, .bottom])
        .sheet(isPresented: $showingMyListings) {
            MyListingsView()
        }
        .sheet(isPresented: $showingFavorites) {
            FavoritesView()
        }
        .sheet(isPresented: $showingPurchaseHistory) {
            PurchaseHistoryView()
        }
        .sheet(isPresented: $showingReviews) {
            ReviewsView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingHelpSupport) {
            HelpSupportView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
}

struct ProfileMenuRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Constants.Colors.label)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(Constants.Colors.label)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .font(.caption)
            }
            .padding()
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
