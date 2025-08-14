import Foundation
import SwiftUI
import Combine

@MainActor
class CreateListingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var draftListing: DraftListing
    @Published var selectedImages: [UIImage] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showSuccess: Bool = false
    @Published var showPreview: Bool = false
    @Published var showDraftSaved: Bool = false
    @Published var currentStep: CreateListingStep = .photos
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let autoSaveInterval: TimeInterval = 30.0 // 30 seconds
    private var autoSaveTimer: Timer?
    
    // MARK: - Initialization
    init(sellerId: String) {
        self.draftListing = DraftListing(id: UUID().uuidString, sellerId: sellerId)
        setupAutoSave()
    }
    
    deinit {
        autoSaveTimer?.invalidate()
    }
    
    // MARK: - Setup
    private func setupAutoSave() {
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: autoSaveInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.saveDraft()
            }
        }
    }
    
    // MARK: - Photo Management
    func addImage(_ image: UIImage) {
        guard selectedImages.count < 10 else {
            showError(message: "Maximum 10 photos allowed")
            return
        }
        
        selectedImages.append(image)
        
        // Convert to base64 for storage (in real app, upload to cloud storage)
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let base64String = imageData.base64EncodedString()
            draftListing.images.append(base64String)
        }
        
        // Update the draft to trigger UI refresh
        draftListing.updatedAt = Date()
        
        // Force UI update by triggering objectWillChange
        objectWillChange.send()
    }
    
    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        
        // Don't allow removing the last photo (minimum 1 required)
        guard selectedImages.count > 1 else {
            showError(message: "Cannot remove the last photo. At least 1 photo is required.")
            return
        }
        
        selectedImages.remove(at: index)
        
        // Remove from draft listing images as well
        if index < draftListing.images.count {
            draftListing.images.remove(at: index)
        }
        
        // Update the draft to trigger UI refresh
        draftListing.updatedAt = Date()
        
        // Force UI update by triggering objectWillChange
        objectWillChange.send()
    }
    
    func moveImage(from source: IndexSet, to destination: Int) {
        selectedImages.move(fromOffsets: source, toOffset: destination)
        draftListing.images.move(fromOffsets: source, toOffset: destination)
        
        // Force UI update by triggering objectWillChange
        objectWillChange.send()
    }
    
    // MARK: - Form Updates
    func updateTitle(_ title: String) {
        draftListing.title = title
        draftListing.updatedAt = Date()
    }
    
    func updateDescription(_ description: String) {
        draftListing.description = description
        draftListing.updatedAt = Date()
    }
    
    func updatePrice(_ price: Double) {
        draftListing.price = price
        draftListing.updatedAt = Date()
    }
    
    func updateCategory(_ category: Category) {
        draftListing.category = category
        draftListing.updatedAt = Date()
    }
    
    func updateCondition(_ condition: ItemCondition) {
        draftListing.condition = condition
        draftListing.updatedAt = Date()
    }
    
    func updateQuantity(_ quantity: Int) {
        draftListing.quantity = max(1, quantity)
        draftListing.updatedAt = Date()
    }
    
    func updateBrand(_ brand: String) {
        draftListing.brand = brand.isEmpty ? nil : brand
        draftListing.updatedAt = Date()
    }
    
    func updateModel(_ model: String) {
        draftListing.model = model.isEmpty ? nil : model
        draftListing.updatedAt = Date()
    }
    
    func updateLocation(_ location: Location) {
        draftListing.location = location
        draftListing.updatedAt = Date()
    }
    
    func updateDeliveryRadius(_ radius: Double?) {
        draftListing.deliveryRadius = radius
        draftListing.updatedAt = Date()
    }
    
    func updateTags(_ tags: [String]) {
        draftListing.tags = Array(Set(tags)).prefix(10).map { $0 } // Remove duplicates, max 10
        draftListing.updatedAt = Date()
    }
    
    func toggleNegotiable() {
        draftListing.isNegotiable.toggle()
        draftListing.updatedAt = Date()
    }
    
    func togglePickupOnly() {
        draftListing.pickupOnly.toggle()
        if draftListing.pickupOnly {
            draftListing.shippingAvailable = false
            draftListing.shippingCost = nil
        }
        draftListing.updatedAt = Date()
    }
    
    func toggleShippingAvailable() {
        draftListing.shippingAvailable.toggle()
        if !draftListing.shippingAvailable {
            draftListing.shippingCost = nil
        }
        draftListing.updatedAt = Date()
    }
    
    func updateShippingCost(_ cost: Double?) {
        draftListing.shippingCost = cost
        draftListing.updatedAt = Date()
    }
    
    // MARK: - Navigation
    func nextStep() {
        switch currentStep {
        case .photos:
            if !selectedImages.isEmpty {
                currentStep = .basicInfo
            } else {
                showError(message: "Please add at least one photo")
            }
        case .basicInfo:
            if validateBasicInfoWithError() {
                currentStep = .details
            }
        case .details:
            if validateDetailsWithError() {
                currentStep = .location
            }
        case .location:
            if validateLocationWithError() {
                currentStep = .review
            }
        case .review:
            break
        }
    }
    
    func previousStep() {
        switch currentStep {
        case .photos:
            break
        case .basicInfo:
            currentStep = .photos
        case .details:
            currentStep = .basicInfo
        case .location:
            currentStep = .details
        case .review:
            currentStep = .location
        }
    }
    
    // MARK: - Validation
    private func validateBasicInfo() -> Bool {
        if draftListing.title.isEmpty {
            return false
        }
        if draftListing.title.count > 60 {
            return false
        }
        if draftListing.description.isEmpty {
            return false
        }
        if draftListing.description.count < 50 {
            return false
        }
        if draftListing.price <= 0 {
            return false
        }
        if draftListing.category == nil {
            return false
        }
        if draftListing.condition == nil {
            return false
        }
        return true
    }
    
    private func validateBasicInfoWithError() -> Bool {
        if draftListing.title.isEmpty {
            showError(message: "Please enter a title")
            return false
        }
        if draftListing.title.count > 60 {
            showError(message: "Title must be 60 characters or less")
            return false
        }
        if draftListing.description.isEmpty {
            showError(message: "Please enter a description")
            return false
        }
        if draftListing.description.count < 50 {
            showError(message: "Description must be at least 50 characters")
            return false
        }
        if draftListing.price <= 0 {
            showError(message: "Please enter a valid price")
            return false
        }
        if draftListing.category == nil {
            showError(message: "Please select a category")
            return false
        }
        if draftListing.condition == nil {
            showError(message: "Please select item condition")
            return false
        }
        return true
    }
    
    private func validateDetails() -> Bool {
        if draftListing.quantity < 1 {
            return false
        }
        return true
    }
    
    private func validateDetailsWithError() -> Bool {
        if draftListing.quantity < 1 {
            showError(message: "Quantity must be at least 1")
            return false
        }
        return true
    }
    
    private func validateLocation() -> Bool {
        if draftListing.location == nil {
            return false
        }
        return true
    }
    
    private func validateLocationWithError() -> Bool {
        if draftListing.location == nil {
            showError(message: "Please set a location")
            return false
        }
        return true
    }
    
    // MARK: - Computed Properties
    var canProceed: Bool {
        switch currentStep {
        case .photos:
            return !selectedImages.isEmpty
        case .basicInfo:
            // Allow proceeding if at least title and category are filled
            return !draftListing.title.isEmpty && draftListing.category != nil
        case .details:
            return validateDetails()
        case .location:
            return validateLocation()
        case .review:
            return draftListing.canBePosted
        }
    }
    
    var completedSteps: Set<CreateListingStep> {
        var completed: Set<CreateListingStep> = []
        
        // Photos step is complete if we have at least one image
        if !selectedImages.isEmpty {
            completed.insert(.photos)
        }
        
        // BasicInfo step is complete if title, category, and condition are filled
        if !draftListing.title.isEmpty && 
           draftListing.category != nil && 
           draftListing.condition != nil {
            completed.insert(.basicInfo)
        }
        
        // Details step is complete if quantity is set (always has default value)
        if draftListing.quantity >= 1 {
            completed.insert(.details)
        }
        
        // Location step is complete if location is set
        if draftListing.location != nil {
            completed.insert(.location)
        }
        
        // Review step is never complete until final submission
        // So we don't add it to completedSteps
        
        return completed
    }
    
    var canGoBack: Bool {
        return currentStep != .photos
    }
    
    // MARK: - Actions
    func saveDraft() async {
        guard !draftListing.title.isEmpty else { return }
        
        do {
            // In real app, save to local storage or backend
            try await Task.sleep(nanoseconds: 500_000_000) // Simulate API call
            showDraftSaved = true
            
            // Hide success message after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showDraftSaved = false
            }
        } catch {
            showError(message: "Failed to save draft: \(error.localizedDescription)")
        }
    }
    
    func postListing() async {
        guard draftListing.canBePosted else {
            showError(message: "Please complete all required fields")
            return
        }
        
        isLoading = true
        
        do {
            // In real app, convert draft to listing and post to backend
            try await Task.sleep(nanoseconds: 2_000_000_000) // Simulate API call
            
            showSuccess = true
            resetForm()
            
            // Hide success message after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showSuccess = false
            }
        } catch {
            showError(message: "Failed to post listing: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func resetForm() {
        draftListing = DraftListing(id: UUID().uuidString, sellerId: draftListing.sellerId)
        selectedImages.removeAll()
        currentStep = .photos
    }
    
    func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    func dismissError() {
        showError = false
        errorMessage = ""
    }
}

// MARK: - Create Listing Steps
enum CreateListingStep: Int, CaseIterable {
    case photos = 0
    case basicInfo = 1
    case details = 2
    case location = 3
    case review = 4
    
    var title: String {
        switch self {
        case .photos: return "Photos"
        case .basicInfo: return "Basic Info"
        case .details: return "Details"
        case .location: return "Location"
        case .review: return "Review"
        }
    }
    
    var icon: String {
        switch self {
        case .photos: return "photo.on.rectangle"
        case .basicInfo: return "info.circle"
        case .details: return "list.bullet"
        case .location: return "location"
        case .review: return "eye"
        }
    }
}
