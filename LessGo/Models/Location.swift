import Foundation
import CoreLocation

struct Location: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    let address: String?
    let city: String?
    let state: String?
    let zipCode: String?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double, address: String? = nil, city: String? = nil, state: String? = nil, zipCode: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.address = nil
        self.city = nil
        self.state = nil
        self.zipCode = nil
    }
    
    func distance(to other: Location) -> CLLocationDistance {
        return clLocation.distance(from: other.clLocation)
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
}

