import SwiftUI

struct MyListingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("My Listings")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Manage your active and sold items")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                Spacer()
                
                // Placeholder content
                VStack(spacing: 16) {
                    Text("🏷️")
                        .font(.system(size: 80))
                    
                    Text("Your listings will appear here")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("View and manage all your posted items, track their status, and edit details.")
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
    MyListingsView()
}
