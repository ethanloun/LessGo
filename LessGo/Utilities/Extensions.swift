import Foundation
import SwiftUI
import CoreLocation

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    func customShadow(color: Color = .black, radius: CGFloat = 3, x: CGFloat = 0, y: CGFloat = 2) -> some View {
        self.shadow(color: color, radius: radius, x: x, y: y)
    }

    func cardStyle() -> some View {
        self
            .background(Constants.Colors.secondaryBackground)
            .cornerRadius(Constants.Design.cornerRadius)
            .customShadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2) // Use renamed method here
    }

    func buttonStyle(style: ButtonStyleType = .primary) -> some View {
        self
            .frame(height: Constants.Design.buttonHeight)
            .background(style.backgroundColor)
            .foregroundColor(style.foregroundColor)
            .cornerRadius(Constants.Design.cornerRadius)
            .font(.headline)
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Button Style Types
enum ButtonStyleType {
    case primary
    case secondary
    case destructive
    case outline
    
    var backgroundColor: Color {
        switch self {
        case .primary: return Constants.Colors.primary
        case .secondary: return Constants.Colors.secondary
        case .destructive: return Constants.Colors.error
        case .outline: return Color.clear
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary, .secondary, .destructive: return .white
        case .outline: return Constants.Colors.primary
        }
    }
}

// MARK: - Rounded Corner Shape
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - String Extensions
extension String {
    var isValidEmail: Bool {
        let emailRegex = Constants.Validation.emailRegex
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    var isValidPhone: Bool {
        let phoneRegex = Constants.Validation.phoneRegex
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: self)
    }
    
    var isValidPassword: Bool {
        return count >= Constants.Validation.passwordMinLength && count <= Constants.Validation.passwordMaxLength
    }
    
    func truncate(to length: Int, trailing: String = "...") -> String {
        if self.count <= length {
            return self
        }
        return String(self.prefix(length)) + trailing
    }
    
    var capitalizedFirst: String {
        return prefix(1).capitalized + dropFirst()
    }
}

// MARK: - Date Extensions
extension Date {
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
}

// MARK: - Double Extensions
extension Double {
    var formattedCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
    
    var formattedDistance: String {
        if self < 1 {
            return "\(Int(self * 5280)) ft"
        } else {
            return String(format: "%.1f mi", self)
        }
    }
}

// MARK: - Bundle Extensions
extension Bundle {
    var appName: String {
        return infoDictionary?["CFBundleName"] as? String ?? "LessGo"
    }
    
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

// MARK: - CLLocationCoordinate2D Extensions
extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return abs(lhs.latitude - rhs.latitude) < 0.000001 && abs(lhs.longitude - rhs.longitude) < 0.000001
    }
}





















