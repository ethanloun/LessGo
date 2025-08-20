import SwiftUI
import PhotosUI

struct CreateListingView: View {
    @EnvironmentObject var viewModel: CreateListingViewModel
    let dismissAction: () -> Void
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showLocationPicker = false
    
    var body: some View {
        ZStack {
            Constants.Colors.background.ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header with X button
                HStack {
                    Button(action: { dismissAction() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(Constants.Colors.label)
                    }
                    
                    Spacer()
                    
                    // Save Draft button
                    Button("Save Draft") { 
                        Task { await viewModel.saveDraft() }
                    }
                    .foregroundColor(Constants.Colors.label)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Constants.Colors.sampleCardBackground)
                    .cornerRadius(8)
                }
                .padding(.horizontal, Constants.Design.largePadding)
                .padding(.top, Constants.Design.spacing)
                
                // Progress indicator at the top with no spacing
                ProgressIndicator(
                    currentStep: viewModel.currentStep,
                    completedSteps: viewModel.completedSteps,
                    onStepTap: { step in
                        viewModel.currentStep = step
                    }
                )
                    .background(Constants.Colors.background)
                
                // Scrollable content
                ScrollView {
                    VStack(spacing: 5) {
                        switch viewModel.currentStep {
                        case .photos:
                            PhotoUploadView(
                                selectedImages: $viewModel.selectedImages,
                                onAddImage: viewModel.addImage,
                                onRemoveImage: viewModel.removeImage,
                                onMoveImage: viewModel.moveImage,
                                showImagePicker: $showImagePicker,
                                showCamera: $showCamera
                            )
                        case .basicInfo:
                            BasicInfoView(
                                draftListing: $viewModel.draftListing,
                                onUpdateTitle: viewModel.updateTitle,
                                onUpdateDescription: viewModel.updateDescription,
                                onUpdatePrice: viewModel.updatePrice,
                                onUpdateCategory: viewModel.updateCategory,
                                onUpdateCondition: viewModel.updateCondition
                            )
                        case .details:
                            DetailsView(
                                draftListing: $viewModel.draftListing,
                                onUpdateQuantity: viewModel.updateQuantity,
                                onUpdateBrand: viewModel.updateBrand,
                                onUpdateModel: viewModel.updateModel,
                                onUpdateTags: viewModel.updateTags,
                                onToggleNegotiable: viewModel.toggleNegotiable,
                                onTogglePickupOnly: viewModel.togglePickupOnly,
                                onToggleShipping: viewModel.toggleShippingAvailable,
                                onUpdateShippingCost: viewModel.updateShippingCost
                            )
                        case .location:
                            LocationView(
                                draftListing: $viewModel.draftListing,
                                onUpdateLocation: viewModel.updateLocation,
                                onUpdateDeliveryRadius: viewModel.updateDeliveryRadius,
                                showLocationPicker: $showLocationPicker
                            )
                        case .review:
                            ReviewView(
                                draftListing: viewModel.draftListing,
                                selectedImages: viewModel.selectedImages
                            )
                        }
                    }
                    .padding(.bottom, 100) // Add enough padding to clear the bottom action bar
                }
                .ignoresSafeArea(edges: .bottom)
            }
            
            // Fixed bottom action bar
            VStack {
                Spacer()
                BottomActionBar(
                    currentStep: viewModel.currentStep,
                    canProceed: viewModel.canProceed,
                    isLoading: viewModel.isLoading,
                    onNext: viewModel.nextStep,
                    onPrevious: viewModel.previousStep,
                    onPost: { Task { await viewModel.postListing() } },
                    onCancel: viewModel.resetForm
                )
                .background(Constants.Colors.background)
                .shadow(radius: 2, y: -1)
            }
        }
        .navigationTitle("Create Listing")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismissAction() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .fontWeight(.medium)
                }
                .foregroundColor(Constants.Colors.label)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.currentStep == .review {
                    Button("Preview") { viewModel.showPreview = true }
                        .foregroundColor(Constants.Colors.label)
                        .disabled(!viewModel.draftListing.canBePosted)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImages: $viewModel.selectedImages) { image in
                viewModel.addImage(image)
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                viewModel.addImage(image)
            }
        }
        .sheet(isPresented: $showLocationPicker) {
            LocationPickerView { location in
                viewModel.updateLocation(location)
            }
        }
        .sheet(isPresented: $viewModel.showPreview) {
            ListingPreviewView(
                draftListing: viewModel.draftListing,
                selectedImages: viewModel.selectedImages
            )
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { viewModel.dismissError() }
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Success", isPresented: $viewModel.showSuccess) {
            Button("OK") { dismissAction() }
        } message: {
            Text("Your listing has been posted successfully!")
        }
    }
}

// MARK: - Progress Indicator
struct ProgressIndicator: View {
    let currentStep: CreateListingStep
    let completedSteps: Set<CreateListingStep>
    let onStepTap: (CreateListingStep) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Main progress bar with icons and connecting lines
            ZStack {
                // Connecting line in segments
                HStack(spacing: 0) {
                    ForEach(Array(CreateListingStep.allCases.enumerated()), id: \.1) { index, step in
                        if index > 0 {
                            Rectangle()
                                .fill(lineColor(between: CreateListingStep.allCases[index - 1], and: step))
                                .frame(height: 2)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, 12)
                
                // Icons
                HStack(spacing: 0) {
                    ForEach(CreateListingStep.allCases, id: \.self) { step in
                        VStack(spacing: 0) {
                            Circle()
                                .fill(stepColor(for: step))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: step.icon)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.black)
                                )
                                .background(Color.white, in: Circle())
                                .overlay(
                                    Circle()
                                        .stroke(stepColor(for: step), lineWidth: 2)
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            onStepTap(step)
                        }
                        .contentShape(Rectangle())
                    }
                }
            }
            
            // Text labels
            HStack(spacing: 0) {
                ForEach(CreateListingStep.allCases, id: \.self) { step in
                    Text(step.title)
                        .font(.caption)
                        .foregroundColor(textColor(for: step))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .onTapGesture {
                            onStepTap(step)
                        }
                        .contentShape(Rectangle())
                }
            }
        }
        .padding(.horizontal, Constants.Design.largePadding)
        .padding(.vertical, Constants.Design.spacing)
    }
    
    private func stepColor(for step: CreateListingStep) -> Color {
        if step.rawValue < currentStep.rawValue {
            return .green
        } else if step.rawValue == currentStep.rawValue {
            return Constants.Colors.label
        } else {
            return Constants.Colors.separator
        }
    }
    
    private func textColor(for step: CreateListingStep) -> Color {
        if step.rawValue < currentStep.rawValue {
            return .green
        } else if step.rawValue == currentStep.rawValue {
            return Constants.Colors.label
        } else {
            return Constants.Colors.secondaryLabel
        }
    }
    
    private func lineColor(between first: CreateListingStep, and second: CreateListingStep) -> Color {
        if completedSteps.contains(first) && completedSteps.contains(second) {
            return .green
        } else {
            return Constants.Colors.separator
        }
    }
}

// MARK: - Bottom Action Bar
struct BottomActionBar: View {
    let currentStep: CreateListingStep
    let canProceed: Bool
    let isLoading: Bool
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onPost: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: 0) {
                // Back button (left side)
                if currentStep != .photos {
                    Button("Back") { onPrevious() }
                        .buttonStyle(.bordered)
                        .foregroundColor(.black)
                        .frame(minWidth: 80)
                } else {
                    // Invisible spacer for first step
                    Spacer().frame(minWidth: 80)
                }
                
                Spacer()
                
                // Next/Post button (right side)
                if currentStep == .review {
                    Button("Post Listing") { onPost() }
                        .buttonStyle(.borderedProminent)
                        .disabled(!canProceed || isLoading)
                        .frame(minWidth: 120)
                } else {
                    Button("Next") { onNext() }
                        .buttonStyle(.borderedProminent)
                        .disabled(!canProceed)
                        .frame(minWidth: 80)
                }
            }
            .padding(.horizontal, Constants.Design.largePadding)
            
            if isLoading {
                ProgressView("Posting...")
                    .foregroundColor(Constants.Colors.label)
                    .padding(.bottom)
            }
        }
        .padding(.top, 8)
        .background(Color.white)
        .shadow(radius: 2)
    }
}



#Preview {
    CreateListingView(dismissAction: {})
        .environmentObject(CreateListingViewModel(sellerId: "preview_user"))
}
