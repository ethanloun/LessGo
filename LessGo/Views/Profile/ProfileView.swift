import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea(.all)
            ScrollView {
                VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 16) {
                    // Profile Picture
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text("ET")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                    
                    VStack(spacing: 4) {
                        Text("Ethan Thompson")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Member since December 2024")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Stats
                    HStack(spacing: 40) {
                        VStack {
                            Text("12")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Sold")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        VStack {
                            Text("8")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Bought")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        VStack {
                            Text("4.9")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Rating")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
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
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                
                Spacer(minLength: 100)
                }
                .padding()
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
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
                    .foregroundColor(.white)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
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
