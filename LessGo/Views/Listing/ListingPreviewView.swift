import SwiftUI

struct ListingPreviewView: View {
    let draftListing: DraftListing
    let selectedImages: [UIImage]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background.ignoresSafeArea(.all)
                ScrollView {
                VStack(spacing: 0) {
                    // Photos
                    if !selectedImages.isEmpty {
                        PhotoPreviewSection(selectedImages: selectedImages)
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 20) {
                        // Title and Price
                        VStack(alignment: .leading, spacing: 8) {
                            Text(draftListing.title.isEmpty ? "Your Title Here" : draftListing.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Constants.Colors.label)
                            
                            HStack {
                                Text(String(format: "$%.2f", draftListing.price))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Constants.Colors.label)
                                
                                if draftListing.isNegotiable {
                                    Text("Negotiable")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.orange.opacity(0.2))
                                        .foregroundColor(.orange)
                                        .cornerRadius(4)
                                }
                                
                                Spacer()
                            }
                        }
                        
                        // Category and Condition
                        HStack(spacing: 16) {
                            if let category = draftListing.category {
                                HStack {
                                    Image(systemName: category.iconName)
                                        .foregroundColor(Constants.Colors.label)
                                    Text(category.displayName)
                                        .font(.subheadline)
                                        .foregroundColor(Constants.Colors.label)
                                }
                            }
                            
                            if let condition = draftListing.condition {
                                HStack {
                                    Circle()
                                        .fill(Color(condition.color))
                                        .frame(width: 12, height: 12)
                                    Text(condition.displayName)
                                        .font(.subheadline)
                                        .foregroundColor(Constants.Colors.label)
                                }
                            }
                            
                            Spacer()
                        }
                        .foregroundColor(Constants.Colors.secondaryLabel)
                        
                        // Description
                        if !draftListing.description.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Constants.Colors.label)
                                
                                Text(draftListing.description)
                                    .font(.body)
                                    .foregroundColor(Constants.Colors.label)
                                    .lineSpacing(4)
                            }
                        }
                        
                        // Additional Details
                        if !draftListing.tags.isEmpty || draftListing.brand != nil || draftListing.model != nil {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Details")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Constants.Colors.label)
                                
                                VStack(spacing: 8) {
                                    if let brand = draftListing.brand, !brand.isEmpty {
                                        DetailRow(label: "Brand", value: brand)
                                    }
                                    
                                    if let model = draftListing.model, !model.isEmpty {
                                        DetailRow(label: "Model", value: model)
                                    }
                                    
                                    DetailRow(label: "Quantity", value: "\(draftListing.quantity)")
                                    
                                    if !draftListing.tags.isEmpty {
                                        DetailRow(label: "Tags", value: draftListing.tags.joined(separator: ", "))
                                    }
                                }
                            }
                        }
                        
                        // Location
                        if let location = draftListing.location {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Location")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Constants.Colors.label)
                                
                                HStack {
                                    Image(systemName: "location.circle.fill")
                                        .foregroundColor(.red)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(location.address ?? "Unknown Address")
                                            .font(.subheadline)
                                            .foregroundColor(Constants.Colors.label)
                                        Text("\(location.city ?? "Unknown"), \(location.state ?? "Unknown") \(location.zipCode ?? "")")
                                            .font(.caption)
                                            .foregroundColor(Constants.Colors.secondaryLabel)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        
                        // Shipping & Pickup
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Shipping & Pickup")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.label)
                            
                            VStack(spacing: 8) {
                                if draftListing.pickupOnly {
                                    HStack {
                                        Image(systemName: "location.circle.fill")
                                            .foregroundColor(Constants.Colors.label)
                                        Text("Pickup only")
                                            .font(.subheadline)
                                            .foregroundColor(Constants.Colors.label)
                                        Spacer()
                                    }
                                } else if draftListing.shippingAvailable {
                                    HStack {
                                        Image(systemName: "car.fill")
                                            .foregroundColor(.green)
                                        Text("Delivery available")
                                            .font(.subheadline)
                                            .foregroundColor(Constants.Colors.label)
                                        Spacer()
                                    }
                                    
                                    if let shippingCost = draftListing.shippingCost {
                                        HStack {
                                            Text("Shipping cost:")
                                                .font(.subheadline)
                                                .foregroundColor(Constants.Colors.secondaryLabel)
                                            Text(String(format: "$%.2f", shippingCost))
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(Constants.Colors.label)
                                            Spacer()
                                        }
                                    }
                                    
                                    if let deliveryRadius = draftListing.deliveryRadius, deliveryRadius > 0 {
                                        HStack {
                                            Text("Delivery radius:")
                                                .font(.subheadline)
                                                .foregroundColor(Constants.Colors.secondaryLabel)
                                            Text("\(Int(deliveryRadius)) miles")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(Constants.Colors.label)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Seller Info (placeholder)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Seller")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.label)
                            
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(Constants.Colors.label)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Your Name")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(Constants.Colors.label)
                                    Text("Member since 2024")
                                        .font(.caption)
                                        .foregroundColor(Constants.Colors.secondaryLabel)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
                .background(Constants.Colors.background)
            }
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Photo Preview Section
struct PhotoPreviewSection: View {
    let selectedImages: [UIImage]
    
    var body: some View {
        TabView {
            ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 300)
        .overlay(
            VStack {
                HStack {
                    Spacer()
                    Text("\(selectedImages.count) photos")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Spacer()
            }
            .padding()
        )
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(Constants.Colors.secondaryLabel)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Constants.Colors.label)
            
            Spacer()
        }
    }
}

#Preview {
    ListingPreviewView(
        draftListing: DraftListing(id: "test", sellerId: "test"),
        selectedImages: []
    )
}
