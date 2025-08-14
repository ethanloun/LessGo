import SwiftUI

struct BasicInfoView: View {
    @Binding var draftListing: DraftListing
    let onUpdateTitle: (String) -> Void
    let onUpdateDescription: (String) -> Void
    let onUpdatePrice: (Double) -> Void
    let onUpdateCategory: (Category) -> Void
    let onUpdateCondition: (ItemCondition) -> Void
    
    @State private var priceText: String = ""
    @State private var showCategoryPicker = false
    @State private var showConditionPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Basic Information")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Provide the essential details about your item.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Title
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Title")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(draftListing.title.count)/60")
                        .font(.caption)
                        .foregroundColor(draftListing.title.count > 50 ? .orange : .secondary)
                }
                
                TextField("Enter a descriptive title", text: $draftListing.title)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: draftListing.title) { newValue in
                        if newValue.count <= 60 {
                            onUpdateTitle(newValue)
                        } else {
                            draftListing.title = String(newValue.prefix(60))
                        }
                    }
                
                if draftListing.title.count > 50 {
                    Text("Title is getting long. Keep it concise and descriptive.")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            // Category
            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Button(action: { showCategoryPicker = true }) {
                    HStack {
                        if let category = draftListing.category {
                            HStack {
                                Image(systemName: category.iconName)
                                    .foregroundColor(.blue)
                                Text(category.displayName)
                                    .foregroundColor(.primary)
                            }
                        } else {
                            Text("Select a category")
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)
                }
            }
            
            // Condition
            VStack(alignment: .leading, spacing: 8) {
                Text("Item Condition")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Button(action: { showConditionPicker = true }) {
                    HStack {
                        if let condition = draftListing.condition {
                            HStack {
                                Circle()
                                    .fill(Color(condition.color))
                                    .frame(width: 12, height: 12)
                                Text(condition.displayName)
                                    .foregroundColor(.primary)
                            }
                        } else {
                            Text("Select condition")
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)
                }
            }
            
            // Price
            VStack(alignment: .leading, spacing: 8) {
                Text("Price")
                    .font(.headline)
                    .fontWeight(.medium)
                
                HStack {
                    Text("$")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    TextField("0.00", text: $priceText)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .onChange(of: priceText) { newValue in
                            if let price = Double(newValue) {
                                onUpdatePrice(price)
                            }
                        }
                        .onAppear {
                            priceText = String(format: "%.2f", draftListing.price)
                        }
                }
                
                Text("Set a fair price to attract buyers")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Description
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Description")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(draftListing.description.count)/1000")
                        .font(.caption)
                        .foregroundColor(draftListing.description.count > 900 ? .orange : .secondary)
                }
                
                TextEditor(text: $draftListing.description)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)
                    .onChange(of: draftListing.description) { newValue in
                        if newValue.count <= 1000 {
                            onUpdateDescription(newValue)
                        } else {
                            draftListing.description = String(newValue.prefix(1000))
                        }
                    }
                
                if draftListing.description.count < 50 {
                    Text("Add more details to help buyers understand your item")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else if draftListing.description.count > 900 {
                    Text("Description is getting long. Consider being more concise.")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                // Description tips
                DescriptionTipsView()
            }
        }
        .padding(.horizontal, Constants.Design.largePadding)
        .sheet(isPresented: $showCategoryPicker) {
            CategoryPickerView(
                selectedCategory: $draftListing.category,
                onSelect: onUpdateCategory
            )
        }
        .sheet(isPresented: $showConditionPicker) {
            ConditionPickerView(
                selectedCondition: $draftListing.condition,
                onSelect: onUpdateCondition
            )
        }
    }
}

// MARK: - Category Picker
struct CategoryPickerView: View {
    @Binding var selectedCategory: Category?
    let onSelect: (Category) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(Category.allCases, id: \.self) { category in
                Button(action: {
                    selectedCategory = category
                    onSelect(category)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: category.iconName)
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text(category.displayName)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedCategory == category {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Condition Picker
struct ConditionPickerView: View {
    @Binding var selectedCondition: ItemCondition?
    let onSelect: (ItemCondition) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(ItemCondition.allCases, id: \.self) { condition in
                Button(action: {
                    selectedCondition = condition
                    onSelect(condition)
                    dismiss()
                }) {
                    HStack {
                        Circle()
                            .fill(Color(condition.color))
                            .frame(width: 16, height: 16)
                        
                        Text(condition.displayName)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedCondition == condition {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Condition")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Description Tips
struct DescriptionTipsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description Tips")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                TipRow(icon: "checkmark.circle", text: "Include dimensions, materials, and brand")
                TipRow(icon: "checkmark.circle", text: "Mention any flaws or wear honestly")
                TipRow(icon: "checkmark.circle", text: "Explain why you're selling")
                TipRow(icon: "checkmark.circle", text: "Add relevant keywords for search")
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(8)
    }
}

#Preview {
    BasicInfoView(
        draftListing: .constant(DraftListing(id: "test", sellerId: "test")),
        onUpdateTitle: { _ in },
        onUpdateDescription: { _ in },
        onUpdatePrice: { _ in },
        onUpdateCategory: { _ in },
        onUpdateCondition: { _ in }
    )
    .padding()
}
