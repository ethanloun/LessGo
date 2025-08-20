import SwiftUI

struct DetailsView: View {
    @Binding var draftListing: DraftListing
    let onUpdateQuantity: (Int) -> Void
    let onUpdateBrand: (String) -> Void
    let onUpdateModel: (String) -> Void
    let onUpdateTags: ([String]) -> Void
    let onToggleNegotiable: () -> Void
    let onTogglePickupOnly: () -> Void
    let onToggleShipping: () -> Void
    let onUpdateShippingCost: (Double?) -> Void
    
    @State private var newTag: String = ""
    @State private var shippingCostText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Additional Details")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Text("Add more specific information to help buyers find your item.")
                    .font(.subheadline)
                    .foregroundColor(Constants.Colors.secondaryLabel)
            }
            
            // Quantity
            VStack(alignment: .leading, spacing: 8) {
                Text("Quantity Available")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.label)
                
                HStack {
                    Button(action: {
                        if draftListing.quantity > 1 {
                            onUpdateQuantity(draftListing.quantity - 1)
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Constants.Colors.label)
                    }
                    .disabled(draftListing.quantity <= 1)
                    
                    Text("\(draftListing.quantity)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(minWidth: 60)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Constants.Colors.label)
                    
                    Button(action: {
                        onUpdateQuantity(draftListing.quantity + 1)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Constants.Colors.label)
                    }
                }
                
                Text("How many of this item do you have?")
                    .font(.caption)
                    .foregroundColor(Constants.Colors.secondaryLabel)
            }
            
            // Brand & Model
            VStack(alignment: .leading, spacing: 16) {
                Text("Brand & Model")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.label)
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Brand")
                            .font(.subheadline)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                        
                        TextField("e.g., Apple, Nike, Samsung", text: Binding(
                            get: { draftListing.brand ?? "" },
                            set: { onUpdateBrand($0) }
                        ))
                        .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Model")
                            .font(.subheadline)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                        
                        TextField("e.g., iPhone 13, Air Max 90", text: Binding(
                            get: { draftListing.model ?? "" },
                            set: { onUpdateModel($0) }
                        ))
                        .textFieldStyle(.roundedBorder)
                    }
                }
                
                Text("Leave blank if generic or unknown")
                    .font(.caption)
                    .foregroundColor(Constants.Colors.secondaryLabel)
            }
            
            // Tags
            VStack(alignment: .leading, spacing: 12) {
                Text("Tags & Keywords")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.label)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TextField("Add a tag", text: $newTag)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("Add") {
                            addTag()
                        }
                        .buttonStyle(.bordered)
                        .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    if !draftListing.tags.isEmpty {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 80))
                        ], spacing: 8) {
                            ForEach(draftListing.tags, id: \.self) { tag in
                                TagView(tag: tag) {
                                    removeTag(tag)
                                }
                            }
                        }
                    }
                }
                
                Text("Add relevant tags to help buyers find your item (max 10)")
                    .font(.caption)
                    .foregroundColor(Constants.Colors.secondaryLabel)
            }
            
            // Pricing Options
            VStack(alignment: .leading, spacing: 12) {
                Text("Pricing Options")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.label)
                
                VStack(spacing: 8) {
                    Toggle("Price is negotiable", isOn: Binding(
                        get: { draftListing.isNegotiable },
                        set: { _ in onToggleNegotiable() }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: Constants.Colors.label))
                    
                    if draftListing.isNegotiable {
                        Text("Buyers can make offers on your item")
                            .font(.caption)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                }
            }
            
            
        }
        .padding(.horizontal, Constants.Design.largePadding)
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTag.isEmpty else { return }
        
        var updatedTags = draftListing.tags
        if !updatedTags.contains(trimmedTag) && updatedTags.count < 10 {
            updatedTags.append(trimmedTag)
            onUpdateTags(updatedTags)
        }
        
        newTag = ""
    }
    
    private func removeTag(_ tag: String) {
        var updatedTags = draftListing.tags
        updatedTags.removeAll { $0 == tag }
        onUpdateTags(updatedTags)
    }
}

// MARK: - Tag View
struct TagView: View {
    let tag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Constants.Colors.sampleCardBackground)
                .foregroundColor(Constants.Colors.label)
                .cornerRadius(12)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(Constants.Colors.label)
            }
        }
    }
}

#Preview {
    DetailsView(
        draftListing: .constant(DraftListing(id: "test", sellerId: "test")),
        onUpdateQuantity: { _ in },
        onUpdateBrand: { _ in },
        onUpdateModel: { _ in },
        onUpdateTags: { _ in },
        onToggleNegotiable: {},
        onTogglePickupOnly: {},
        onToggleShipping: {},
        onUpdateShippingCost: { _ in }
    )
    .padding()
}
