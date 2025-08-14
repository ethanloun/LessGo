import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var listingViewModel = ListingViewModel()
    @StateObject private var createListingViewModel = CreateListingViewModel(sellerId: "current_user")
    @State private var selectedTab = 0
    @State private var showingCreateListing = false
    
    var body: some View {
        ZStack {
            // Main TabView (hidden when creating listing)
            TabView(selection: $selectedTab) {
                NavigationView {
                    ListingFeedView()
                        .environmentObject(listingViewModel)
                }
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
                
                NavigationView {
                    SearchView()
                        .environmentObject(listingViewModel)
                }
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(1)
                
                // Sell tab - just a placeholder that triggers the full-screen view
                Color.clear
                    .tabItem {
                        Image(systemName: "plus.circle")
                        Text("Sell")
                    }
                    .tag(2)
                    .onTapGesture {
                        showingCreateListing = true
                    }
                
                NavigationView {
                    MessagesView()
                }
                .tabItem {
                    Image(systemName: "message")
                    Text("Messages")
                }
                .tag(3)
                
                NavigationView {
                    ProfileView()
                        .environmentObject(authViewModel)
                }
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(4)
            }
            .accentColor(Constants.Colors.primary)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onAppear {
                configureTabBarAppearance()
                configureNavigationBarAppearance()
            }
            .toolbarBackground(.hidden, for: .tabBar)
            .opacity(showingCreateListing ? 0 : 1)
            .disabled(showingCreateListing)
            
            // Full-screen CreateListingView (overlays when active)
            if showingCreateListing {
                CreateListingView(dismissAction: {
                    showingCreateListing = false
                    selectedTab = 0 // Return to home tab
                })
                .environmentObject(listingViewModel)
                .environmentObject(createListingViewModel)
                .transition(.opacity)
            }
        }
        .onChange(of: selectedTab) { newTab in
            if newTab == 2 {
                showingCreateListing = true
                selectedTab = 0 // Reset to home tab
            }
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        
        // Configure normal state - white for visibility on blue
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.8)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.8)
        ]
        
        // Configure selected state - light blue for selected items
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemYellow
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemYellow
        ]
        
        // Apply appearance to both standard and scroll edge
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Make tab bar more subtle and background-like
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().barTintColor = UIColor.systemBlue.withAlphaComponent(0.8)
        UITabBar.appearance().backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        
        // Remove any default tab bar styling that might cause gaps
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
    }
    
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor.white
    }
}





#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}


