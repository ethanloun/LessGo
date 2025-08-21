import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var listingViewModel = ListingViewModel()
    @StateObject private var createListingViewModel = CreateListingViewModel(sellerId: "current_user")
    @StateObject private var messagingViewModel = MessagingViewModel(currentUserId: "currentUser")
    @State private var selectedTab = 0
    @State private var showingCreateListing = false

    var body: some View {
        ZStack {
            // Core content
            TabView(selection: $selectedTab) {
                ListingFeedView(onMessageSeller: { selectedTab = 3 })
                    .environmentObject(listingViewModel)
                    .environmentObject(messagingViewModel)
                    .tag(0)

                SearchView(onMessageSeller: { selectedTab = 3 })
                    .environmentObject(listingViewModel)
                    .environmentObject(messagingViewModel)
                    .tag(1)

                Color.clear.tag(2)

                // Use a placeholder view for messages tab since we need a listing context
                MessagesPlaceholderView()
                    .environmentObject(messagingViewModel)
                    .tag(3)

                ProfileView()
                    .environmentObject(authViewModel)
                    .tag(4)
            }
            .accentColor(Constants.Colors.primary)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .toolbar(.hidden, for: .tabBar)
            .tabViewStyle(.page(indexDisplayMode: .never)) // 👈 forces TabView not to reserve space

            // Full-screen create listing overlay
            if showingCreateListing {
                CreateListingView(dismissAction: {
                    showingCreateListing = false
                    selectedTab = 0
                })
                .environmentObject(listingViewModel)
                .environmentObject(createListingViewModel)
                .transition(.opacity)
            }
        }
        // Our icon-only bar, inset into the safe area so it never blocks content
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CustomTabBar(
                selectedTab: $selectedTab,
                primaryColor: Constants.Colors.primary,
                onSell: { showingCreateListing = true }
            )
            .opacity(showingCreateListing ? 0 : 1)
        }
        .onChange(of: selectedTab) { newTab in
            if newTab == 2 { // if someone sets it programmatically
                showingCreateListing = true
                selectedTab = 0
            }
        }
    }
}

// MARK: - Messages Placeholder View
struct MessagesPlaceholderView: View {
    @EnvironmentObject var messagingViewModel: MessagingViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "message.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                
                Text("Messages")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Select a listing to view and send messages")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Core Data is now integrated directly into the main app
                Text("Core Data is integrated throughout the app")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Custom icon-only tab bar

private struct CustomTabBar: View {
    @Binding var selectedTab: Int
    var primaryColor: Color
    var onSell: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            TabIcon(system: "house", tag: 0, selectedTab: $selectedTab, primary: primaryColor)
            Spacer()
            TabIcon(system: "magnifyingglass", tag: 1, selectedTab: $selectedTab, primary: primaryColor)

            Spacer(minLength: 0)

            Button(action: onSell) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 34, weight: .bold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(primaryColor)
                    .accessibilityLabel("Sell")
            }

            Spacer(minLength: 0)

            TabIcon(system: "message", tag: 3, selectedTab: $selectedTab, primary: primaryColor)
            Spacer()
            TabIcon(system: "person", tag: 4, selectedTab: $selectedTab, primary: primaryColor)
        }
        .padding(.horizontal, 28)
        .padding(.top, 10)
        .padding(.bottom, 10) // safeAreaInset adds the extra bottom inset automatically
        .frame(maxWidth: .infinity)
        .background(
            Color.white
                .ignoresSafeArea(edges: .bottom)
                .overlay(Divider(), alignment: .top)
        )
    }
}

private struct TabIcon: View {
    let system: String
    let tag: Int
    @Binding var selectedTab: Int
    var primary: Color

    var body: some View {
        Button {
            selectedTab = tag
        } label: {
            Image(systemName: system)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(selectedTab == tag ? primary : .secondary)
                .frame(width: 44, height: 34)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(system)
    }
}



