import Foundation
import SwiftUI

struct Constants {
    // MARK: - App Configuration
    static let appName = "LessGo"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"
    
    // MARK: - Design Constants
    struct Design {
        static let cornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
        static let largeCornerRadius: CGFloat = 16
        
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
        
        static let spacing: CGFloat = 12
        static let smallSpacing: CGFloat = 6
        static let largeSpacing: CGFloat = 20
        
        static let iconSize: CGFloat = 24
        static let smallIconSize: CGFloat = 16
        static let largeIconSize: CGFloat = 32
        
        static let buttonHeight: CGFloat = 50
        static let smallButtonHeight: CGFloat = 40
        static let largeButtonHeight: CGFloat = 60
        
        static let cardShadowRadius: CGFloat = 8
        static let cardShadowOpacity: Float = 0.1
        static let cardShadowOffset = CGSize(width: 0, height: 2)
    }
    
    // MARK: - Colors
    struct Colors {
        static let primary = Color.black
        static let secondary = Color(.systemGray2)
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let background = Color.white
        static let secondaryBackground = Color.white
        static let tertiaryBackground = Color.white
        static let label = Color.black
        static let secondaryLabel = Color(.systemGray)
        static let tertiaryLabel = Color(.systemGray2)
        static let separator = Color(.systemGray4)
        static let cardBackground = Color.white
        static let sampleCardBackground = Color.white
    }
    
    // MARK: - API Configuration
    struct API {
        static let baseURL = "https://api.lessgo.com" // Replace with actual API
        static let timeout: TimeInterval = 30
        static let maxRetries = 3
    }
    
    // MARK: - Location Configuration
    struct Location {
        static let defaultRadius: Double = 25 // miles
        static let maxRadius: Double = 100 // miles
        static let minRadius: Double = 1 // miles
        static let locationUpdateInterval: TimeInterval = 300 // 5 minutes
    }
    
    // MARK: - Listing Configuration
    struct Listing {
        static let maxImages = 10
        static let maxTitleLength = 100
        static let maxDescriptionLength = 1000
        static let maxTags = 10
        static let defaultExpirationDays = 30
        static let maxPrice: Double = 999999.99
        static let minPrice: Double = 0.01
    }
    
    // MARK: - User Configuration
    struct User {
        static let minDisplayNameLength = 2
        static let maxDisplayNameLength = 50
        static let maxBioLength = 500
        static let maxPhoneLength = 20
    }
    
    // MARK: - Messaging Configuration
    struct Messaging {
        static let maxMessageLength = 1000
        static let typingIndicatorTimeout: TimeInterval = 3
        static let messageRetentionDays = 365
    }
    
    // MARK: - Validation
    struct Validation {
        static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        static let phoneRegex = "^[+]?[0-9]{10,15}$"
        static let passwordMinLength = 8
        static let passwordMaxLength = 128
    }
    
    // MARK: - Cache Configuration
    struct Cache {
        static let imageCacheSize = 100 * 1024 * 1024 // 100 MB
        static let listingCacheExpiration: TimeInterval = 300 // 5 minutes
        static let userCacheExpiration: TimeInterval = 3600 // 1 hour
    }
    
    // MARK: - Animation
    struct Animation {
        static let defaultDuration: Double = 0.3
        static let fastDuration: Double = 0.15
        static let slowDuration: Double = 0.5
        static let springDamping: Double = 0.8
        static let springVelocity: Double = 0.5
    }
}

