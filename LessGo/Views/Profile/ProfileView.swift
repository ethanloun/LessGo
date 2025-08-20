import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
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
                            Circle()
                                .fill(Constants.Colors.sampleCardBackground)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text("ET")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(Constants.Colors.label)
                                )
                            
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
                                VStack {
                                    Text("12")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Constants.Colors.label)
                                    Text("Sold")
                                        .font(.caption)
                                        .foregroundColor(Constants.Colors.secondaryLabel)
                                }
                                
                                VStack {
                                    Text("8")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Constants.Colors.label)
                                    Text("Bought")
                                        .font(.caption)
                                        .foregroundColor(Constants.Colors.secondaryLabel)
                                }
                                
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
                        .padding()
                        .background(Constants.Colors.sampleCardBackground)
                        .cornerRadius(12)
                        
                        // Menu Options
                        VStack(spacing: 0) {
                            ProfileMenuRow(icon: "list.bullet", title: "My Listings", action: {})
                            ProfileMenuRow(icon: "heart", title: "Favorites", action: {})
                            ProfileMenuRow(icon: "clock", title: "Purchase History", action: {})
                            ProfileMenuRow(icon: "star", title: "Reviews", action: {})
                            ProfileMenuRow(icon: "gearshape", title: "Settings", action: {})
                            ProfileMenuRow(icon: "questionmark.circle", title: "Help & Support", action: {})
                            ProfileMenuRow(icon: "info.circle", title: "About", action: {})
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
