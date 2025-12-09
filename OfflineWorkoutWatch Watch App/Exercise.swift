import Foundation
import SwiftData

/**
 * Represents a user-created exercise with configurable metrics and targeting information.
 */
@Model
final class Exercise {
    // CloudKit requires all attributes to be optional or have default values
    var id: UUID = UUID()
    var name: String = ""
    var goal: Goal?
    var bodyPart: BodyPart?
    var muscles: [String] = []
    var allowedMetrics: [MetricType] = []
    var createdAt: Date = Date()
    var difficulty: Int? = nil  // 1-5 scale for exercise difficulty
    
    // CloudKit requires relationships to be optional
    @Relationship var sets: [ExerciseSet]? = []
    
    init(
        name: String,
        goal: Goal = Goal.strength,
        bodyPart: BodyPart = BodyPart.other,
        muscles: [String] = [],
        allowedMetrics: [MetricType] = [MetricType.reps, MetricType.weightLbs],
        difficulty: Int? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.goal = goal
        self.bodyPart = bodyPart
        self.muscles = muscles
        self.allowedMetrics = allowedMetrics
        self.createdAt = Date()
        self.difficulty = difficulty
        self.sets = []
    }
}

// MARK: - Computed Properties
extension Exercise {
    /**
     * User-friendly difficulty description.
     */
    var difficultyDescription: String {
        guard let difficulty = difficulty else { return "Not set" }
        
        switch difficulty {
        case 1: return "Beginner"
        case 2: return "Easy"
        case 3: return "Moderate"
        case 4: return "Hard"
        case 5: return "Expert"
        default: return "Unknown"
        }
    }
    
    /**
     * Whether this exercise has a difficulty rating.
     */
    var hasDifficultyRating: Bool {
        return difficulty != nil
    }
}

// MARK: - Convenience Initializers
extension Exercise {
    /**
     * Creates a running exercise with duration, distance, and avg pace metrics.
     */
    static func createRunningExercise(name: String = "Run", difficulty: Int? = 2) -> Exercise {
        return Exercise(
            name: name,
            goal: Goal.cardio,
            bodyPart: BodyPart.other,
            allowedMetrics: [MetricType.durationSeconds, MetricType.distanceMeters, MetricType.avgPace],
            difficulty: difficulty  // Default to "Easy" for running
        )
    }
    
    /**
     * Creates a cardio exercise with steps, duration, and avg pace metrics.
     */
    static func createCardioExercise(name: String) -> Exercise {
        return Exercise(
            name: name,
            goal: Goal.cardio,
            bodyPart: BodyPart.other,
            allowedMetrics: [MetricType.steps, MetricType.durationSeconds, MetricType.avgPace]
        )
    }
}
