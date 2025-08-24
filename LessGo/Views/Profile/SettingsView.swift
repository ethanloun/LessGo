import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("Settings")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Customize your app experience")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                Spacer()
                
                // Placeholder content
                VStack(spacing: 16) {
                    Text("⚙️")
                        .font(.system(size: 80))
                    
                    Text("Settings coming soon")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Manage notifications, privacy settings, account preferences, and more.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
