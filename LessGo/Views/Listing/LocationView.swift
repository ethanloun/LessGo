import SwiftUI
import MapKit

struct LocationView: View {
    @Binding var draftListing: DraftListing
    let onUpdateLocation: (Location) -> Void
    let onUpdateDeliveryRadius: (Double?) -> Void
    @Binding var showLocationPicker: Bool
    
    @State private var selectedDeliveryRadius: Double = 0
    @State private var showCurrentLocation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Location & Delivery")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Set where buyers can pick up your item or how far you're willing to deliver.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Current Location
            VStack(alignment: .leading, spacing: 12) {
                Text("Pickup Location")
                    .font(.headline)
                    .fontWeight(.medium)
                
                if let location = draftListing.location {
                    LocationDisplayView(location: location) {
                        showLocationPicker = true
                    }
                } else {
                    EmptyLocationView(
                        onSelectLocation: { showLocationPicker = true },
                        onUseCurrentLocation: { useCurrentLocation() }
                    )
                }
            }
            
            // Delivery Options
            VStack(alignment: .leading, spacing: 12) {
                Text("Delivery Options")
                    .font(.headline)
                    .fontWeight(.medium)
                
                VStack(spacing: 16) {
                    // Pickup only option
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "location.circle.fill")
                                .foregroundColor(.blue)
                            Text("Pickup Only")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        
                        Text("Buyers must come to your location to get the item")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(draftListing.pickupOnly ? Color.blue.opacity(0.1) : Color.white.opacity(0.9))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(draftListing.pickupOnly ? Color.blue : Color.clear, lineWidth: 2)
                    )
                    
                    // Delivery option
                    if !draftListing.pickupOnly {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "car.fill")
                                    .foregroundColor(.green)
                                Text("Delivery Available")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            
                            Text("You can deliver the item to buyers within your radius")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if draftListing.shippingAvailable {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Delivery Radius")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        Slider(
                                            value: $selectedDeliveryRadius,
                                            in: 0...50,
                                            step: 1
                                        ) { editing in
                                            if !editing {
                                                onUpdateDeliveryRadius(selectedDeliveryRadius)
                                            }
                                        }
                                        
                                        Text("\(Int(selectedDeliveryRadius)) mi")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .frame(minWidth: 50)
                                    }
                                    
                                    Text("Maximum distance you're willing to travel for delivery")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.green, lineWidth: 2)
                        )
                    }
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
                    Text(location.address ?? "Unknown Address")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(location.city), \(location.state) \(location.zipCode)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Edit") {
                    onEdit()
                }
                .buttonStyle(.bordered)
            }
            
            // Simple map preview (in real app, this would show an actual map)
            MapPreviewView(location: location)
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(8)
    }
}

// MARK: - Empty Location View
struct EmptyLocationView: View {
    let onSelectLocation: () -> Void
    let onUseCurrentLocation: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.circle")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No location set")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Button(action: onUseCurrentLocation) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Use Current Location")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Button(action: onSelectLocation) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text("Select Location")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                }
            }
        }
        .padding(40)
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
    }
}

// MARK: - Map Preview View
struct MapPreviewView: View {
    let location: Location
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(0.8))
                .frame(height: 120)
                .cornerRadius(8)
            
            VStack(spacing: 8) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
                
                Text("Map Preview")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
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
            
            VStack(alignment: .leading, spacing: 8) {
                TipRow(icon: "location.fill", text: "Choose a safe, public meeting spot")
                TipRow(icon: "clock.fill", text: "Consider your availability for meetups")
                TipRow(icon: "car.fill", text: "Set realistic delivery radius")
                TipRow(icon: "exclamationmark.triangle.fill", text: "Never share your exact home address")
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
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
