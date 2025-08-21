import SwiftUI
import CoreData

struct AddListingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var price = ""
    @State private var selectedUser: CDUser? = nil
    @State private var showingImagePicker = false
    @State private var selectedImages: [UIImage] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("Listing Information") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    HStack {
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $price)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section("Owner") {
                    ownerSection
                }
                
                Section("Image") {
                    imageSection
                }
                
                Section("Preview") {
                    previewSection
                }
            }
            .navigationTitle("Add Listing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveListing() }
                        .disabled(title.isEmpty || description.isEmpty || price.isEmpty || selectedUser == nil || selectedImages.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImages: $selectedImages, onAddImage: { image in
                    selectedImages.append(image)
                })
            }
        }
    }
    
    private var ownerSection: some View {
        Group {
            if let user = selectedUser {
                HStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Text(String(user.displayName?.prefix(1).uppercased() ?? "U"))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.displayName ?? "Unknown")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(user.email ?? "No email")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Change") { 
                        selectedUser = nil 
                    }
                    .font(.caption)
                }
            } else {
                Menu("Select Owner") {
                    ForEach(fetchUsers(), id: \.id) { user in
                        Button(user.displayName ?? "Unknown") {
                            selectedUser = user
                        }
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    private var imageSection: some View {
        Group {
            if let selectedImage = selectedImages.first {
                VStack {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(8)
                    
                    Button("Change Image") { showingImagePicker = true }
                        .buttonStyle(.bordered)
                }
            } else {
                Button("Select Image") { showingImagePicker = true }
                    .buttonStyle(.bordered)
            }
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let selectedImage = selectedImages.first {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title.isEmpty ? "Listing Title" : title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(description.isEmpty ? "Listing description will appear here..." : description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                HStack {
                    if let priceValue = Double(price), priceValue > 0 {
                        Text("$\(String(format: "%.2f", priceValue))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    } else {
                        Text("$0.00")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let user = selectedUser {
                        Text("by \(user.displayName ?? "Unknown")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func saveListing() {
        guard let user = selectedUser,
              let priceValue = Double(price) else { return }
        
        let listing = CDListing(context: viewContext)
        listing.id = UUID().uuidString
        listing.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        listing.desc = description.trimmingCharacters(in: .whitespacesAndNewlines)
        listing.price = priceValue
        // Convert image data to base64 string for storage
        if let imageData = selectedImages.first?.jpegData(compressionQuality: 0.8) {
            let base64String = imageData.base64EncodedString()
            listing.images = [base64String]
        }
        listing.createdAt = Date()
        listing.owner = user
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving listing: \(error)")
        }
    }
    
    private func fetchUsers() -> [CDUser] {
        let request: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDUser.displayName, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching users: \(error)")
            return []
        }
    }
}

#Preview {
    AddListingView()
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
