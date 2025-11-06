import Foundation
import SwiftData

/**
 * Represents a workout session containing multiple exercise sets.
 */
@Model
final class Workout {
    // CloudKit requires all attributes to be optional or have default values
    var id: UUID = UUID()
    var startedAt: Date = Date()
    var endedAt: Date?
    var note: String?
    
    // CloudKit requires relationships to be optional
    @Relationship(deleteRule: .cascade) var sets: [ExerciseSet]? = []
    
    var durationSeconds: Int {
        max(0, Int((endedAt ?? Date()).timeIntervalSince(startedAt)))
    }
    
    init(startedAt: Date = Date()) {
        self.id = UUID()
        self.startedAt = startedAt
        self.endedAt = nil
        self.note = nil
        self.sets = []
    }
}
