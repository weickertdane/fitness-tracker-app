import Foundation

/**
 * Represents different body parts that can be targeted during exercise.
 */
enum BodyPart: String, Codable, CaseIterable, Sendable {
    case biceps = "biceps"
    case triceps = "triceps"
    case forearms = "forearms"
    case shoulders = "shoulders"
    case chest = "chest"
    case back = "back"
    case abs = "abs"
    case obliques = "obliques"
    case erectors = "erectors"
    case glutes = "glutes"
    case hamstrings = "hamstrings"
    case quads = "quads"
    case calves = "calves"
    case hips = "hips"
    case adductors = "adductors"
    case abductors = "abductors"
    case ankle = "ankle"
    case tibialis = "tibialis"
    case peroneals = "peroneals"
    case other = "other"
}
