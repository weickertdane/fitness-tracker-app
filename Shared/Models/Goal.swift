import Foundation

/**
 * Represents the primary goal or focus of an exercise or workout routine.
 */
enum Goal: String, Codable, CaseIterable, Sendable {
    case rehab = "rehab"
    case strength = "strength"
    case hypertrophy = "hypertrophy"
    case cardio = "cardio"
}