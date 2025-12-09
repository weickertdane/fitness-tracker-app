import Foundation
import SwiftData

/**
 * Represents a single set of an exercise with various trackable metrics.
 */
@Model
final class ExerciseSet {
    // CloudKit requires all attributes to be optional or have default values
    var id: UUID = UUID()
    var timestamp: Date = Date()
    
    // CloudKit requires relationships to be optional
    @Relationship(inverse: \Workout.sets) var workout: Workout?
    @Relationship(inverse: \Exercise.sets) var exercise: Exercise?
    
    // Metrics (all optional)
    var reps: Int?
    var weightLbs: Double?
    var durationSeconds: Int?
    var distanceMeters: Double?
    var avgPaceSeconds: Int? // Pace in seconds per unit (km or mile)
    var paceUnit: String? // "km" or "mi" - which unit the pace is per
    var steps: Int?
    
    // Flags - CloudKit requires default values for non-optional attributes
    var isBodyweight: Bool = false
    
    // Rehab extras
    var painLevel: Int? // 1-10
    var rangeOfMotion: Int? // 1-5
    
    init(
        exercise: Exercise? = nil,
        workout: Workout? = nil,
        reps: Int? = nil,
        weightLbs: Double? = nil,
        durationSeconds: Int? = nil,
        distanceMeters: Double? = nil,
        avgPaceSeconds: Int? = nil,
        paceUnit: String? = nil,
        steps: Int? = nil,
        isBodyweight: Bool = false,
        painLevel: Int? = nil,
        rangeOfMotion: Int? = nil
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.exercise = exercise
        self.workout = workout
        self.reps = reps
        self.weightLbs = weightLbs
        self.durationSeconds = durationSeconds
        self.distanceMeters = distanceMeters
        self.avgPaceSeconds = avgPaceSeconds
        self.paceUnit = paceUnit
        self.steps = steps
        self.isBodyweight = isBodyweight
        self.painLevel = painLevel
        self.rangeOfMotion = rangeOfMotion
    }
    
    /**
     * Validates that at least one metric is provided for the set.
     */
    var hasValidMetrics: Bool {
        return reps != nil || 
               weightLbs != nil || 
               durationSeconds != nil || 
               distanceMeters != nil || 
               avgPaceSeconds != nil ||
               steps != nil || 
               isBodyweight
    }
}

// MARK: - Unit Conversion Helpers
extension ExerciseSet {
    /**
     * Converts distance from meters to miles.
     */
    var distanceMiles: Double? {
        guard let meters = distanceMeters else { return nil }
        return meters * 0.000621371
    }
    
    /**
     * Converts duration from seconds to formatted string (mm:ss).
     */
    var durationFormatted: String? {
        guard let seconds = durationSeconds else { return nil }
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    /**
     * Sets distance using miles (converts to meters internally).
     */
    func setDistanceMiles(_ miles: Double) {
        self.distanceMeters = miles / 0.000621371
    }
    
    /**
     * Converts pace from seconds to formatted string (mm:ss).
     */
    var paceFormatted: String? {
        guard let seconds = avgPaceSeconds else { return nil }
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        let unit = paceUnit ?? "km"
        return String(format: "%d:%02d/%@", minutes, remainingSeconds, unit)
    }
}
