import SwiftUI

struct PurchaseHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("Purchase History")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Your buying activity and transactions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                Spacer()
                
                // Placeholder content
                VStack(spacing: 16) {
                    Text("🛍️")
                        .font(.system(size: 80))
                    
                    Text("No purchases yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Your purchase history, receipts, and transaction details will appear here.")
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
    PurchaseHistoryView()
}
