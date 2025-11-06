import Foundation

/**
 * Represents different types of metrics that can be tracked for exercise sets.
 */
enum MetricType: String, Codable, CaseIterable, Sendable {
    case reps = "reps"
    case weightLbs = "weightLbs"
    case durationSeconds = "durationSeconds"
    case distanceMeters = "distanceMeters"
    case steps = "steps"
    case pain = "pain"
    
    // Custom decoder to handle deprecated values
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        // Handle deprecated bodyweightFlag by mapping it to reps
        if rawValue == "bodyweightFlag" {
            self = .reps
        } else if let metricType = MetricType(rawValue: rawValue) {
            self = metricType
        } else {
            // If we encounter any other unknown value, default to reps
            self = .reps
        }
    }
}
