import SwiftUI

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Constants.Colors.secondaryLabel)
                .frame(width: 16)
            
            Text(text)
                .font(.caption)
                .foregroundColor(Constants.Colors.secondaryLabel)
            
            Spacer()
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        TipRow(icon: "lightbulb", text: "Use good lighting and clear backgrounds")
        TipRow(icon: "camera", text: "Take photos from multiple angles")
        TipRow(icon: "exclamationmark.triangle", text: "Show any flaws or damage clearly")
    }
    .padding()
}
