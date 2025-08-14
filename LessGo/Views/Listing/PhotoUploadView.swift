import SwiftUI
import PhotosUI

struct PhotoUploadView: View {
    @Binding var selectedImages: [UIImage]
    let onAddImage: (UIImage) -> Void
    let onRemoveImage: (Int) -> Void
    let onMoveImage: (IndexSet, Int) -> Void
    @Binding var showImagePicker: Bool
    @Binding var showCamera: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Photos")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add up to 10 clear photos of your item. The first photo will be the main image.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Photo grid
            if selectedImages.isEmpty {
                EmptyPhotoState(
                    onAddPhoto: { showImagePicker = true },
                    onTakePhoto: { showCamera = true }
                )
            } else {
                PhotoGridView(
                    selectedImages: $selectedImages,
                    onRemoveImage: onRemoveImage,
                    onMoveImage: onMoveImage,
                    onAddMore: { showImagePicker = true }
                )
            }
            
            // Photo tips
            PhotoTipsView()
            
            // Minimum requirement notice
            if selectedImages.count == 1 {
                Text("Minimum: 1 photo required (cannot remove last photo)")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("Minimum: 1 photo required")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, Constants.Design.largePadding)
    }
}

// MARK: - Empty Photo State
struct EmptyPhotoState: View {
    let onAddPhoto: () -> Void
    let onTakePhoto: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No photos yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Button(action: onTakePhoto) {
                    HStack {
                        Image(systemName: "camera")
                        Text("Take Photo")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Button(action: onAddPhoto) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Choose from Library")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white.opacity(0.8))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
    }
}

// MARK: - Photo Grid View
struct PhotoGridView: View {
    @Binding var selectedImages: [UIImage]
    let onRemoveImage: (Int) -> Void
    let onMoveImage: (IndexSet, Int) -> Void
    let onAddMore: () -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(selectedImages.count)/10 photos")
                .font(.caption)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                    PhotoCell(
                        image: image,
                        isMain: index == 0,
                        onRemove: { onRemoveImage(index) },
                        canRemove: selectedImages.count > 1
                    )
                }
                
                if selectedImages.count < 10 {
                    AddMorePhotoCell(onAdd: onAddMore)
                }
            }
            
            if selectedImages.count > 1 {
                Text("Drag to reorder photos. First photo will be the main image.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Photo Cell
struct PhotoCell: View {
    let image: UIImage
    let isMain: Bool
    let onRemove: () -> Void
    let canRemove: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 110, height: 110)
                .clipped()
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isMain ? Color.blue : Color.clear, lineWidth: 2)
                )
            
            if isMain {
                VStack {
                    HStack {
                        Spacer()
                        Text("MAIN")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .cornerRadius(4)
                    }
                    Spacer()
                }
                .padding(4)
            }
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(canRemove ? .white : .gray)
                    .background(canRemove ? Color.black.opacity(0.6) : Color.gray.opacity(0.3))
                    .clipShape(Circle())
            }
            .disabled(!canRemove)
            .padding(4)
        }
    }
}

// MARK: - Add More Photo Cell
struct AddMorePhotoCell: View {
    let onAdd: () -> Void
    
    var body: some View {
        Button(action: onAdd) {
            VStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Add Photo")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .frame(width: 110, height: 110)
            .background(Color.white.opacity(0.9))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4]))
            )
        }
    }
}

// MARK: - Photo Tips
struct PhotoTipsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Photo Tips")
                .font(.headline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 6) {
                TipRow(icon: "lightbulb", text: "Use good lighting and clear backgrounds")
                TipRow(icon: "camera", text: "Take photos from multiple angles")
                TipRow(icon: "exclamationmark.triangle", text: "Show any flaws or damage clearly")
                TipRow(icon: "ruler", text: "Include a size reference if helpful")
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
    }
}



#Preview {
    PhotoUploadView(
        selectedImages: .constant([]),
        onAddImage: { _ in },
        onRemoveImage: { _ in },
        onMoveImage: { _, _ in },
        showImagePicker: .constant(false),
        showCamera: .constant(false)
    )
    .padding()
}
