import SwiftUI

struct ReviewView: View {
    let draftListing: DraftListing
    let selectedImages: [UIImage]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Review Your Listing")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Review all the details before posting. Make sure everything looks correct!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    // Photos Section
                    PhotosReviewSection(selectedImages: selectedImages)
                    
                    // Basic Info Section
                    BasicInfoReviewSection(draftListing: draftListing)
                    
                    // Details Section
                    DetailsReviewSection(draftListing: draftListing)
                    
                    // Location Section
                    LocationReviewSection(draftListing: draftListing)
                    
                    // Validation Summary
                    ValidationSummaryView(draftListing: draftListing)
                }
            }
            .background(Color.blue)
        }
        .padding(.horizontal, Constants.Design.largePadding)
        .background(Color.blue)
    }
}

// MARK: - Photos Review Section
struct PhotosReviewSection: View {
    let selectedImages: [UIImage]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Photos", icon: "photo.on.rectangle")
            
            if selectedImages.isEmpty {
                Text("No photos added")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                            VStack(spacing: 4) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(8)
                                
                                if index == 0 {
                                    Text("Main")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Text("\(selectedImages.count) photo(s) • First photo will be the main image")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
    }
}

// MARK: - Basic Info Review Section
struct BasicInfoReviewSection: View {
    let draftListing: DraftListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Basic Information", icon: "info.circle")
            
            VStack(spacing: 12) {
                ReviewRow(label: "Title", value: draftListing.title.isEmpty ? "Not set" : draftListing.title)
                ReviewRow(label: "Category", value: draftListing.category?.displayName ?? "Not set")
                ReviewRow(label: "Condition", value: draftListing.condition?.displayName ?? "Not set")
                ReviewRow(label: "Price", value: String(format: "$%.2f", draftListing.price))
                ReviewRow(label: "Description", value: draftListing.description.isEmpty ? "Not set" : draftListing.description, isMultiline: true)
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
    }
}

// MARK: - Details Review Section
struct DetailsReviewSection: View {
    let draftListing: DraftListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Additional Details", icon: "list.bullet")
            
            VStack(spacing: 12) {
                ReviewRow(label: "Quantity", value: "\(draftListing.quantity)")
                
                if let brand = draftListing.brand, !brand.isEmpty {
                    ReviewRow(label: "Brand", value: brand)
                }
                
                if let model = draftListing.model, !model.isEmpty {
                    ReviewRow(label: "Model", value: model)
                }
                
                ReviewRow(label: "Negotiable", value: draftListing.isNegotiable ? "Yes" : "No")
                ReviewRow(label: "Pickup Only", value: draftListing.pickupOnly ? "Yes" : "No")
                
                if !draftListing.pickupOnly && draftListing.shippingAvailable {
                    ReviewRow(label: "Shipping Available", value: "Yes")
                    if let shippingCost = draftListing.shippingCost {
                        ReviewRow(label: "Shipping Cost", value: String(format: "$%.2f", shippingCost))
                    }
                }
                
                if !draftListing.tags.isEmpty {
                    ReviewRow(label: "Tags", value: draftListing.tags.joined(separator: ", "), isMultiline: true)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
    }
}

// MARK: - Location Review Section
struct LocationReviewSection: View {
    let draftListing: DraftListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Location & Delivery", icon: "location")
            
            VStack(spacing: 12) {
                if let location = draftListing.location {
                    ReviewRow(label: "Address", value: location.address ?? "Unknown Address", isMultiline: true)
                    ReviewRow(label: "City", value: "\(location.city), \(location.state) \(location.zipCode)")
                } else {
                    ReviewRow(label: "Location", value: "Not set", isMultiline: true)
                }
                
                if let deliveryRadius = draftListing.deliveryRadius, deliveryRadius > 0 {
                    ReviewRow(label: "Delivery Radius", value: "\(Int(deliveryRadius)) miles")
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
    }
}

// MARK: - Validation Summary
struct ValidationSummaryView: View {
    let draftListing: DraftListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Validation Summary", icon: "checkmark.circle")
            
            if draftListing.canBePosted {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("All required fields are complete!")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                        Spacer()
                    }
                    
                    Text("Your listing is ready to be posted. Review the details above and click 'Post Listing' when you're satisfied.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Some required fields are missing")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(draftListing.validationErrors, id: \.self) { error in
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Text("Please go back and complete these fields before posting.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(draftListing.canBePosted ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(draftListing.canBePosted ? Color.green : Color.orange, lineWidth: 1)
        )
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
        }
    }
}

// MARK: - Review Row
struct ReviewRow: View {
    let label: String
    let value: String
    var isMultiline: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(isMultiline ? nil : 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ReviewView(
        draftListing: DraftListing(id: "test", sellerId: "test"),
        selectedImages: []
    )
    .padding()
}
