import SwiftUI

struct ReviewsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                    
                    Text("Reviews")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Your ratings and feedback")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                Spacer()
                
                // Placeholder content
                VStack(spacing: 16) {
                    Text("⭐")
                        .font(.system(size: 80))
                    
                    Text("No reviews yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Reviews from buyers and sellers will appear here. Build your reputation by providing great service!")
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
    ReviewsView()
}
