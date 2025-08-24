import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("About LessGo")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Learn more about our app")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                Spacer()
                
                // Placeholder content
                VStack(spacing: 16) {
                    Text("📱")
                        .font(.system(size: 80))
                    
                    Text("LessGo v1.0")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Your local marketplace for buying and selling items safely and easily. Connect with your community!")
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
    AboutView()
}
