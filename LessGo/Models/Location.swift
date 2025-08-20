import Foundation
import CoreLocation

enum LocationType: String, Codable, CaseIterable {
    case specificAddress = "specific_address"
    case generalCity = "general_city"
    
    var displayName: String {
        switch self {
        case .specificAddress:
            return "Specific Address"
        case .generalCity:
            return "General City"
        }
    }
    
    var description: String {
        switch self {
        case .specificAddress:
            return "Exact location for meeting"
        case .generalCity:
            return "General area for pickup"
        }
    }
}

struct Location: Codable, Equatable {
    let latitude: Double?
    let longitude: Double?
    let address: String?
    let city: String?
    let state: String?
    let zipCode: String?
    let locationType: LocationType
    let meetingInstructions: String?
    
    var coordinate: CLLocationCoordinate2D? {
        guard let latitude = latitude, let longitude = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var clLocation: CLLocation? {
        guard let latitude = latitude, let longitude = longitude else { return nil }
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // For specific addresses with coordinates
    init(latitude: Double, longitude: Double, address: String? = nil, city: String? = nil, state: String? = nil, zipCode: String? = nil, meetingInstructions: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.locationType = .specificAddress
        self.meetingInstructions = meetingInstructions
    }
    
    // For general city locations (no specific coordinates)
    init(city: String, state: String, zipCode: String? = nil, meetingInstructions: String? = nil) {
        self.latitude = nil
        self.longitude = nil
        self.address = nil
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.locationType = .generalCity
        self.meetingInstructions = meetingInstructions
    }
    
    // For coordinate-based locations
    init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.address = nil
        self.city = nil
        self.state = nil
        self.zipCode = nil
        self.locationType = .specificAddress
        self.meetingInstructions = nil
    }
    
    func distance(to other: Location) -> CLLocationDistance? {
        guard let selfLocation = clLocation, let otherLocation = other.clLocation else { return nil }
        return selfLocation.distance(from: otherLocation)
    }
    
    func formattedAddress() -> String {
        var components: [String] = []
        
        if let address = address {
            components.append(address)
        }
        if let city = city {
            components.append(city)
        }
        if let state = state {
            components.append(state)
        }
        if let zipCode = zipCode {
            components.append(zipCode)
        }
        
        return components.isEmpty ? "Unknown Location" : components.joined(separator: ", ")
    }
    
    func displayLocation() -> String {
        switch locationType {
        case .specificAddress:
            return formattedAddress()
        case .generalCity:
            var components: [String] = []
            if let city = city {
                components.append(city)
            }
            if let state = state {
                components.append(state)
            }
            if let zipCode = zipCode {
                components.append(zipCode)
            }
            return components.isEmpty ? "Unknown City" : components.joined(separator: ", ")
        }
    }
    
    var hasCoordinates: Bool {
        return latitude != nil && longitude != nil
    }
}

