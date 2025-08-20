import SwiftUI

struct AddressInputView: View {
    @Binding var draftListing: DraftListing
    let onUpdateLocation: (Location) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var address: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zipCode: String = ""
    @State private var meetingInstructions: String = ""
    @State private var locationType: LocationType = .specificAddress
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Location Type Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Location Type")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    VStack(spacing: 8) {
                        ForEach(LocationType.allCases, id: \.self) { type in
                            Button(action: {
                                locationType = type
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(type.displayName)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(Constants.Colors.label)
                                            
                                            Spacer()
                                            
                                            if locationType == type {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(Constants.Colors.label)
                                            }
                                        }
                                        
                                        Text(type.description)
                                            .font(.caption)
                                            .foregroundColor(Constants.Colors.secondaryLabel)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(locationType == type ? Constants.Colors.sampleCardBackground : Constants.Colors.background)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(locationType == type ? Constants.Colors.label : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                // Address Input Fields
                VStack(alignment: .leading, spacing: 16) {
                    Text(locationType == .specificAddress ? "Meeting Address" : "City Information")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.label)
                    
                    if locationType == .specificAddress {
                        // Specific address fields
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Street Address")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Constants.Colors.label)
                                
                                TextField("Enter street address", text: $address)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("City")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(Constants.Colors.label)
                                    
                                    TextField("City", text: $city)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("State")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(Constants.Colors.label)
                                    
                                    TextField("State", text: $state)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ZIP Code")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Constants.Colors.label)
                                
                                TextField("ZIP Code", text: $zipCode)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                            }
                        }
                    } else {
                        // General city fields
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("City")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(Constants.Colors.label)
                                    
                                    TextField("City", text: $city)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("State")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(Constants.Colors.label)
                                    
                                    TextField("State", text: $state)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ZIP Code (Optional)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Constants.Colors.label)
                                
                                TextField("ZIP Code", text: $zipCode)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                            }
                        }
                    }
                    
                    // Meeting Instructions
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Meeting Instructions")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Constants.Colors.label)
                        
                        TextEditor(text: $meetingInstructions)
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Constants.Colors.sampleCardBackground)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Constants.Colors.separator, lineWidth: 1)
                            )
                        
                        Text("Optional: Add details about where to meet (e.g., 'Meet at the coffee shop on Main St')")
                            .font(.caption)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                }
                
                Spacer()
                
                // Save Button
                Button(action: saveLocation) {
                    Text("Save Location")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canSave ? Constants.Colors.label : Constants.Colors.secondaryLabel)
                        .cornerRadius(8)
                }
                .disabled(!canSave)
            }
            .padding(.horizontal, Constants.Design.largePadding)
            .padding(.vertical, Constants.Design.spacing)
            .navigationTitle("Location Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadExistingLocation()
            }
        }
    }
    
    private var canSave: Bool {
        if locationType == .specificAddress {
            return !address.isEmpty && !city.isEmpty && !state.isEmpty
        } else {
            return !city.isEmpty && !state.isEmpty
        }
    }
    
    private func loadExistingLocation() {
        if let location = draftListing.location {
            address = location.address ?? ""
            city = location.city ?? ""
            state = location.state ?? ""
            zipCode = location.zipCode ?? ""
            meetingInstructions = location.meetingInstructions ?? ""
            locationType = location.locationType
        }
    }
    
    private func saveLocation() {
        let newLocation: Location
        
        if locationType == .specificAddress {
            // For specific addresses, we'll create a location without coordinates
            // In a real app, you might want to geocode the address to get coordinates
            newLocation = Location(
                city: city,
                state: state,
                zipCode: zipCode.isEmpty ? nil : zipCode,
                meetingInstructions: meetingInstructions.isEmpty ? nil : meetingInstructions
            )
        } else {
            // For general city locations
            newLocation = Location(
                city: city,
                state: state,
                zipCode: zipCode.isEmpty ? nil : zipCode,
                meetingInstructions: meetingInstructions.isEmpty ? nil : meetingInstructions
            )
        }
        
        onUpdateLocation(newLocation)
        dismiss()
    }
}

#Preview {
    AddressInputView(
        draftListing: .constant(DraftListing(id: "test", sellerId: "test")),
        onUpdateLocation: { _ in }
    )
}
