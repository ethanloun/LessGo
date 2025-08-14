import SwiftUI

struct ListingPreviewView: View {
    let draftListing: DraftListing
    let selectedImages: [UIImage]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.blue.ignoresSafeArea(.all)
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
                            
                            HStack {
                                Text(String(format: "$%.2f", draftListing.price))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                
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
                                        .foregroundColor(.blue)
                                    Text(category.displayName)
                                        .font(.subheadline)
                                }
                            }
                            
                            if let condition = draftListing.condition {
                                HStack {
                                    Circle()
                                        .fill(Color(condition.color))
                                        .frame(width: 12, height: 12)
                                    Text(condition.displayName)
                                        .font(.subheadline)
                                }
                            }
                            
                            Spacer()
                        }
                        .foregroundColor(.secondary)
                        
                        // Description
                        if !draftListing.description.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text(draftListing.description)
                                    .font(.body)
                                    .lineSpacing(4)
                            }
                        }
                        
                        // Additional Details
                        if !draftListing.tags.isEmpty || draftListing.brand != nil || draftListing.model != nil {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Details")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
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
                                
                                HStack {
                                    Image(systemName: "location.circle.fill")
                                        .foregroundColor(.red)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(location.address ?? "Unknown Address")
                                            .font(.subheadline)
                                        Text("\(location.city), \(location.state) \(location.zipCode)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
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
                            
                            VStack(spacing: 8) {
                                if draftListing.pickupOnly {
                                    HStack {
                                        Image(systemName: "location.circle.fill")
                                            .foregroundColor(.blue)
                                        Text("Pickup only")
                                            .font(.subheadline)
                                        Spacer()
                                    }
                                } else if draftListing.shippingAvailable {
                                    HStack {
                                        Image(systemName: "car.fill")
                                            .foregroundColor(.green)
                                        Text("Delivery available")
                                            .font(.subheadline)
                                        Spacer()
                                    }
                                    
                                    if let shippingCost = draftListing.shippingCost {
                                        HStack {
                                            Text("Shipping cost:")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Text(String(format: "$%.2f", shippingCost))
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Spacer()
                                        }
                                    }
                                    
                                    if let deliveryRadius = draftListing.deliveryRadius, deliveryRadius > 0 {
                                        HStack {
                                            Text("Delivery radius:")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Text("\(Int(deliveryRadius)) miles")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
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
                            
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Your Name")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("Member since 2024")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
                .background(Color.blue)
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
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
            
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
