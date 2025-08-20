import SwiftUI
import MapKit

struct LocationView: View {
    @Binding var draftListing: DraftListing
    let onUpdateLocation: (Location) -> Void
    let onUpdateDeliveryRadius: (Double?) -> Void
    @Binding var showLocationPicker: Bool
    
    @State private var selectedDeliveryRadius: Double = 0
    @State private var showCurrentLocation = false
    @State private var showAddressInput = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Location")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Text("Set where buyers can pick up your item or how far you're willing to deliver.")
                    .font(.subheadline)
                    .foregroundColor(Constants.Colors.secondaryLabel)
            }
            
            // Current Location
            VStack(alignment: .leading, spacing: 12) {
                Text("Pickup Location")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.label)
                
                if let location = draftListing.location {
                    LocationDisplayView(location: location) {
                        showAddressInput = true
                    }
                } else {
                    EmptyLocationView(
                        onSelectLocation: { showLocationPicker = true },
                        onUseCurrentLocation: { useCurrentLocation() },
                        onInputAddress: { showAddressInput = true }
                    )
                }
            }
            
            // Location Tips
            LocationTipsView()
        }
        .padding(.horizontal, Constants.Design.largePadding)
        .onAppear {
            if let radius = draftListing.deliveryRadius {
                selectedDeliveryRadius = radius
            }
        }
        .sheet(isPresented: $showAddressInput) {
            AddressInputView(
                draftListing: $draftListing,
                onUpdateLocation: onUpdateLocation
            )
        }
    }
    
    private func useCurrentLocation() {
        // In a real app, this would request location permissions and get current location
        // For now, we'll simulate it by creating a default location
        let currentLocation = Location(
            latitude: 37.7749,
            longitude: -122.4194,
            address: "Current Location",
            city: "San Francisco",
            state: "CA",
            zipCode: "94102"
        )
        onUpdateLocation(currentLocation)
        showCurrentLocation = true
        
        // Hide success message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showCurrentLocation = false
        }
    }
}

// MARK: - Location Display View
struct LocationDisplayView: View {
    let location: Location
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.displayLocation())
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.label)
                    
                    if let meetingInstructions = location.meetingInstructions, !meetingInstructions.isEmpty {
                        Text(meetingInstructions)
                            .font(.caption)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                            .italic()
                    }
                    
                    Text(location.locationType.displayName)
                        .font(.caption)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Constants.Colors.sampleCardBackground)
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Button("Edit") {
                    onEdit()
                }
                .buttonStyle(.bordered)
            }
            
            // Map preview only for locations with coordinates
            if location.hasCoordinates {
                MapPreviewView(location: location)
            }
        }
        .padding()
        .background(Constants.Colors.sampleCardBackground)
        .cornerRadius(8)
    }
}

// MARK: - Empty Location View
struct EmptyLocationView: View {
    let onSelectLocation: () -> Void
    let onUseCurrentLocation: () -> Void
    let onInputAddress: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.circle")
                .font(.system(size: 50))
                .foregroundColor(Constants.Colors.secondaryLabel)
            
            Text("No location set")
                .font(.headline)
                .foregroundColor(Constants.Colors.secondaryLabel)
            
            VStack(spacing: 12) {
                Button(action: onUseCurrentLocation) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Use Current Location")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Constants.Colors.label)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Button(action: onInputAddress) {
                    HStack {
                        Image(systemName: "pencil.circle")
                        Text("Input Address")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Button(action: onSelectLocation) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text("Select on Map")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Constants.Colors.sampleCardBackground)
                    .foregroundColor(Constants.Colors.label)
                    .cornerRadius(8)
                }
            }
        }
        .padding(40)
        .background(Constants.Colors.sampleCardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Map Preview View
struct MapPreviewView: View {
    let location: Location
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Constants.Colors.sampleCardBackground)
                .frame(height: 120)
                .cornerRadius(8)
            
            VStack(spacing: 8) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
                
                Text("Map Preview")
                    .font(.caption)
                    .foregroundColor(Constants.Colors.secondaryLabel)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Constants.Colors.separator, lineWidth: 1)
        )
    }
}

// MARK: - Location Tips
struct LocationTipsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location Tips")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(Constants.Colors.label)
            
            VStack(alignment: .leading, spacing: 8) {
                TipRow(icon: "location.fill", text: "Choose a safe, public meeting spot")
                TipRow(icon: "clock.fill", text: "Consider your availability for meetups")
                TipRow(icon: "car.fill", text: "Set realistic delivery radius")
                TipRow(icon: "exclamationmark.triangle.fill", text: "Never share your exact home address")
                TipRow(icon: "text.bubble", text: "Add clear meeting instructions for buyers")
            }
        }
        .padding()
        .background(Constants.Colors.sampleCardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    LocationView(
        draftListing: .constant(DraftListing(id: "test", sellerId: "test")),
        onUpdateLocation: { _ in },
        onUpdateDeliveryRadius: { _ in },
        showLocationPicker: .constant(false)
    )
    .padding()
}
