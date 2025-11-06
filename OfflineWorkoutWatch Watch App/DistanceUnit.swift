import Foundation

/**
 * Represents different units for measuring distance.
 */
enum DistanceUnit: String, Codable, CaseIterable, Sendable {
    case meters = "meters"
    case kilometers = "kilometers"
    case miles = "miles"
    
    var abbreviation: String {
        switch self {
        case .meters: return "m"
        case .kilometers: return "km"
        case .miles: return "mi"
        }
    }
    
    var displayName: String {
        return rawValue.capitalized
    }
}
