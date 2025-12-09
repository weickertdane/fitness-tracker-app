import Foundation

/**
 * Represents different types of metrics that can be tracked for exercise sets.
 */
enum MetricType: String, Codable, CaseIterable, Sendable {
    case reps = "reps"
    case weightLbs = "weightLbs"
    case durationSeconds = "durationSeconds"
    case distanceMeters = "distanceMeters"
    case avgPace = "avgPace"
    case steps = "steps"
    case pain = "pain"
}
