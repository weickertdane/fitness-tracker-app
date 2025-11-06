import Foundation
import SwiftData
import Observation

/**
 * Manages exercise library data for the iPhone app.
 */
@Observable
final class ExerciseLibraryViewModel {
    
    // MARK: - State
    
    /// All exercises loaded from the database
    var exercises: [Exercise] = []
    
    /// Filtered exercises based on search query
    var filteredExercises: [Exercise] = []
    
    /// Current search query
    var searchQuery: String = "" {
        didSet {
            filterExercises()
        }
    }
    
    /// Whether data is currently being loaded
    var isLoading: Bool = false
    
    /// Error message if operations fail
    var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadExercises()
        setupNotificationObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ExerciseDataDidChange"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("🔔 iOS Exercise Library received ExerciseDataDidChange notification")
            self?.loadExercises()
        }
    }
    
    // MARK: - Data Loading
    
    /**
     * Loads all exercises from the database.
     */
    func loadExercises() {
        isLoading = true
        errorMessage = nil
        
        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            exercises = try modelContext.fetch(descriptor)
            filterExercises()
            print("✅ Loaded \(exercises.count) exercises")
        } catch {
            errorMessage = "Failed to load exercises: \(error.localizedDescription)"
            print("❌ Failed to load exercises: \(error)")
            exercises = []
            filteredExercises = []
        }
        
        isLoading = false
    }
    
    /**
     * Refreshes exercise data from the database.
     */
    func refreshExercises() {
        loadExercises()
    }
    
    // MARK: - Search and Filtering
    
    private func filterExercises() {
        if searchQuery.isEmpty {
            filteredExercises = exercises
        } else {
            filteredExercises = exercises.filter { exercise in
                exercise.name.localizedCaseInsensitiveContains(searchQuery) ||
                exercise.bodyPart?.rawValue.localizedCaseInsensitiveContains(searchQuery) == true ||
                exercise.goal?.rawValue.localizedCaseInsensitiveContains(searchQuery) == true ||
                exercise.muscles.contains { muscle in
                    muscle.localizedCaseInsensitiveContains(searchQuery)
                }
            }
        }
    }
    
    // MARK: - Exercise Management
    
    /**
     * Creates a new exercise from the form (already has all properties set).
     */
    func createExerciseFromForm(_ exercise: Exercise) {
        modelContext.insert(exercise)
        
        do {
            try modelContext.save()
            print("✅ Created exercise: \(exercise.name)")
            WatchSyncCenter.shared.upsertExercise(exercise)
        } catch {
            errorMessage = "Failed to create exercise: \(error.localizedDescription)"
            print("❌ Failed to create exercise: \(error)")
        }
    }
    
    /**
     * Creates a new exercise.
     */
    func createExercise(
        name: String,
        goal: Goal,
        bodyPart: BodyPart,
        muscles: [String] = [],
        allowedMetrics: [MetricType] = [.reps, .weightLbs]
    ) -> Exercise? {
        let exercise = Exercise(
            name: name,
            goal: goal,
            bodyPart: bodyPart,
            muscles: muscles,
            allowedMetrics: allowedMetrics
        )
        
        modelContext.insert(exercise)
        
        do {
            try modelContext.save()
            loadExercises() // Refresh the list
            print("✅ Created exercise: \(exercise.name)")
            WatchSyncCenter.shared.upsertExercise(exercise)
            return exercise
        } catch {
            errorMessage = "Failed to create exercise: \(error.localizedDescription)"
            print("❌ Failed to create exercise: \(error)")
            return nil
        }
    }
    
    /**
     * Updates an existing exercise from the form (properties already updated).
     */
    func updateExerciseFromForm(_ exercise: Exercise) {
        do {
            try modelContext.save()
            print("✅ Updated exercise: \(exercise.name)")
            WatchSyncCenter.shared.upsertExercise(exercise)
        } catch {
            errorMessage = "Failed to update exercise: \(error.localizedDescription)"
            print("❌ Failed to update exercise: \(error)")
        }
    }
    
    /**
     * Updates an existing exercise.
     */
    func updateExercise(
        _ exercise: Exercise,
        name: String,
        goal: Goal,
        bodyPart: BodyPart,
        muscles: [String],
        allowedMetrics: [MetricType]
    ) -> Bool {
        exercise.name = name
        exercise.goal = goal
        exercise.bodyPart = bodyPart
        exercise.muscles = muscles
        exercise.allowedMetrics = allowedMetrics
        
        do {
            try modelContext.save()
            loadExercises() // Refresh the list
            print("✅ Updated exercise: \(exercise.name)")
            WatchSyncCenter.shared.upsertExercise(exercise)
            return true
        } catch {
            errorMessage = "Failed to update exercise: \(error.localizedDescription)"
            print("❌ Failed to update exercise: \(error)")
            return false
        }
    }
    
    /**
     * Deletes an exercise from the database.
     */
    func deleteExercise(_ exercise: Exercise) {
        modelContext.delete(exercise)
        
        do {
            try modelContext.save()
            loadExercises() // Refresh the list
            print("✅ Deleted exercise: \(exercise.name)")
            WatchSyncCenter.shared.deleteExercise(id: exercise.id)
        } catch {
            errorMessage = "Failed to delete exercise: \(error.localizedDescription)"
            print("❌ Failed to delete exercise: \(error)")
        }
    }
    
    // MARK: - Utility Methods
    
    /**
     * Groups exercises by body part.
     */
    var exercisesByBodyPart: [BodyPart: [Exercise]] {
        Dictionary(grouping: filteredExercises) { $0.bodyPart ?? .other }
    }
    
    /**
     * Groups exercises by goal.
     */
    var exercisesByGoal: [Goal: [Exercise]] {
        Dictionary(grouping: filteredExercises) { $0.goal ?? .strength }
    }
    
    /**
     * Gets exercise count for display.
     */
    var exerciseCount: Int {
        exercises.count
    }
    
    /**
     * Gets filtered exercise count for display.
     */
    var filteredExerciseCount: Int {
        filteredExercises.count
    }
    
    /**
     * Formats allowed metrics for display.
     */
    func formatAllowedMetrics(_ metrics: [MetricType]) -> String {
        return metrics.map { metric in
            switch metric {
            case .reps: return "Reps"
            case .weightLbs: return "Weight"
            case .durationSeconds: return "Duration"
            case .distanceMeters: return "Distance"
            case .steps: return "Steps"
            case .pain: return "Pain Level"
            }
        }.joined(separator: ", ")
    }
}
