import Foundation
import SwiftData
import Observation

/**
 * Manages workout state and operations for the Apple Watch app.
 */
@Observable
final class WatchWorkoutViewModel {
    
    // MARK: - State
    
    /// Current active workout, if any
    var currentWorkout: Workout?
    
    /// All available exercises for selection
    var availableExercises: [Exercise] = []
    
    /// Exercises that have been selected for the current workout (but may not have sets yet)
    var selectedExercises: Set<UUID> = []
    
    /// Timer tick counter to force UI updates for workout duration
    var timerTick: Int = 0
    
    /// Whether a workout is currently active
    var isWorkoutActive: Bool {
        return currentWorkout != nil && currentWorkout?.endedAt == nil
    }
    
    /// Grouped sets by exercise for the current workout
    var exerciseGroups: [(exercise: Exercise, sets: [ExerciseSet])] {
        guard let workout = currentWorkout else { 
            print("🔍 No current workout")
            return [] 
        }
        
        let allSets = workout.sets ?? []
        print("🔍 Total sets in workout: \(allSets.count)")
        
        // Group existing sets by exercise
        let groupedSets = Dictionary(grouping: allSets) { set in
            set.exercise
        }
        
        // Create groups from exercises with sets
        var groups = groupedSets.compactMap { (exercise, sets) -> (exercise: Exercise, sets: [ExerciseSet])? in
            guard let exercise = exercise else { return nil }
            return (exercise: exercise, sets: sets.sorted { $0.timestamp < $1.timestamp })
        }
        
        // Add selected exercises that don't have sets yet
        for exerciseId in selectedExercises {
            // Check if this exercise already has sets (and thus is already in groups)
            let exerciseAlreadyInGroups = groups.contains { $0.exercise.id == exerciseId }
            
            if !exerciseAlreadyInGroups {
                // Find the exercise in availableExercises
                if let exercise = availableExercises.first(where: { $0.id == exerciseId }) {
                    groups.append((exercise: exercise, sets: []))
                    print("🔍 Added selected exercise without sets: \(exercise.name)")
                }
            }
        }
        
        // Sort groups by the timestamp of their first set (most recent at bottom)
        // Exercises without sets go to the top
        groups.sort { group1, group2 in
            let firstSet1 = group1.sets.first?.timestamp ?? Date.distantPast
            let firstSet2 = group2.sets.first?.timestamp ?? Date.distantPast
            return firstSet1 < firstSet2
        }
        
        print("🔍 Exercise groups created: \(groups.count)")
        for group in groups {
            print("🔍 Group - Exercise: \(group.exercise.name), Sets: \(group.sets.count)")
        }
        
        return groups
    }
    
    // MARK: - Dependencies
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadAvailableExercises()
        
        // Listen for sync notifications
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ExerciseDataDidChange"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("🔔 Watch app received ExerciseDataDidChange notification")
            self?.loadAvailableExercises()
        }
    }
    
    // MARK: - Workout Management
    
    /**
     * Starts a new workout session.
     */
    func startWorkout() {
        guard currentWorkout == nil else { return }
        
        let workout = Workout(startedAt: Date())
        modelContext.insert(workout)
        
        do {
            try modelContext.save()
            currentWorkout = workout
            selectedExercises.removeAll() // Clear any previously selected exercises
            timerTick = 0 // Reset timer tick counter
            print("✅ Started new workout: \(workout.id)")
            WatchSyncCenter.shared.upsertWorkout(workout)
        } catch {
            print("❌ Failed to start workout: \(error)")
        }
    }
    
    /**
     * Ends the current workout session.
     */
    func endWorkout() {
        guard let workout = currentWorkout else { return }
        
        workout.endedAt = Date()
        
        do {
            try modelContext.save()
            print("✅ Ended workout: \(workout.id), Duration: \(workout.durationSeconds)s")
            WatchSyncCenter.shared.upsertWorkout(workout)
            currentWorkout = nil
            selectedExercises.removeAll() // Clear selected exercises when workout ends
        } catch {
            print("❌ Failed to end workout: \(error)")
        }
    }
    
    /**
     * Cancels the current workout (deletes it entirely).
     */
    func cancelWorkout() {
        guard let workout = currentWorkout else { return }
        
        modelContext.delete(workout)
        
        do {
            try modelContext.save()
            print("✅ Cancelled workout: \(workout.id)")
            WatchSyncCenter.shared.deleteWorkout(id: workout.id)
            currentWorkout = nil
            selectedExercises.removeAll() // Clear selected exercises when workout is cancelled
        } catch {
            print("❌ Failed to cancel workout: \(error)")
        }
    }
    
    // MARK: - Exercise Management
    
    /**
     * Creates a new exercise and adds it to the available exercises.
     */
    func createExercise(
        name: String,
        goal: Goal,
        bodyPart: BodyPart,
        muscles: [String] = [],
        allowedMetrics: [MetricType] = [.reps, .weightLbs]
    ) -> Exercise {
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
            loadAvailableExercises() // Refresh the list
            print("✅ Created exercise: \(exercise.name)")
            WatchSyncCenter.shared.upsertExercise(exercise)
            return exercise
        } catch {
            print("❌ Failed to create exercise: \(error)")
            return exercise
        }
    }
    
    /**
     * Adds an exercise to the current workout (marks it as selected).
     */
    func addExerciseToWorkout(_ exercise: Exercise) -> Bool {
        guard isWorkoutActive else {
            print("❌ Cannot add exercise: No active workout (currentWorkout: \(currentWorkout?.id.uuidString ?? "nil"), endedAt: \(currentWorkout?.endedAt?.description ?? "nil"))")
            return false
        }
        
        selectedExercises.insert(exercise.id)
        print("✅ Added exercise to workout: \(exercise.name)")
        return true
    }
    
    /**
     * Removes an exercise from the current workout (removes it from selected list).
     */
    func removeExerciseFromWorkout(_ exercise: Exercise) {
        selectedExercises.remove(exercise.id)
        print("✅ Removed exercise from workout: \(exercise.name)")
    }
    
    /**
     * Loads all available exercises from the database.
     */
    func loadAvailableExercises() {
        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            availableExercises = try modelContext.fetch(descriptor)
            print("✅ Loaded \(availableExercises.count) exercises")
        } catch {
            print("❌ Failed to load exercises: \(error)")
            availableExercises = []
        }
    }
    
    // MARK: - Set Management
    
    /**
     * Adds a new exercise set to the current workout.
     */
    func addSet(
        exercise: Exercise,
        reps: Int? = nil,
        weightLbs: Double? = nil,
        durationSeconds: Int? = nil,
        distanceMeters: Double? = nil,
        steps: Int? = nil,
        isBodyweight: Bool = false,
        painLevel: Int? = nil,
        rangeOfMotion: Int? = nil
    ) -> Bool {
        guard let workout = currentWorkout else {
            print("❌ Cannot add set: No active workout")
            return false
        }
        
        let exerciseSet = ExerciseSet(
            exercise: exercise,
            workout: workout,
            reps: reps,
            weightLbs: weightLbs,
            durationSeconds: durationSeconds,
            distanceMeters: distanceMeters,
            steps: steps,
            isBodyweight: isBodyweight,
            painLevel: painLevel,
            rangeOfMotion: rangeOfMotion
        )
        
        // Validate that at least one metric is provided
        guard exerciseSet.hasValidMetrics else {
            print("❌ Cannot add set: No valid metrics provided")
            return false
        }
        
        modelContext.insert(exerciseSet)
        
        do {
            try modelContext.save()
            
            // Automatically add exercise to selected list if it's not already there
            selectedExercises.insert(exercise.id)
            
            refreshWorkoutData()
            print("✅ Added set for \(exercise.name)")
            WatchSyncCenter.shared.upsertExerciseSet(exerciseSet)
            return true
        } catch {
            print("❌ Failed to add set: \(error)")
            return false
        }
    }
    
    /**
     * Updates an existing exercise set.
     */
    func updateSet(
        _ exerciseSet: ExerciseSet,
        reps: Int? = nil,
        weightLbs: Double? = nil,
        durationSeconds: Int? = nil,
        distanceMeters: Double? = nil,
        steps: Int? = nil,
        isBodyweight: Bool = false,
        painLevel: Int? = nil,
        rangeOfMotion: Int? = nil
    ) -> Bool {
        // Update the set properties
        exerciseSet.reps = reps
        exerciseSet.weightLbs = weightLbs
        exerciseSet.durationSeconds = durationSeconds
        exerciseSet.distanceMeters = distanceMeters
        exerciseSet.steps = steps
        exerciseSet.isBodyweight = isBodyweight
        exerciseSet.painLevel = painLevel
        exerciseSet.rangeOfMotion = rangeOfMotion
        
        // Validate that at least one metric is provided
        guard exerciseSet.hasValidMetrics else {
            print("❌ Cannot update set: No valid metrics provided")
            return false
        }
        
        do {
            try modelContext.save()
            refreshWorkoutData()
            print("✅ Updated set for \(exerciseSet.exercise?.name ?? "unknown exercise")")
            WatchSyncCenter.shared.upsertExerciseSet(exerciseSet)
            return true
        } catch {
            print("❌ Failed to update set: \(error)")
            return false
        }
    }
    
    /**
     * Deletes a specific exercise set.
     */
    func deleteSet(_ exerciseSet: ExerciseSet) {
        let exerciseName = exerciseSet.exercise?.name ?? "unknown exercise"
        let setId = exerciseSet.id
        
        print("🗑️ Deleting set \(setId) from \(exerciseName)")
        
        // Remove from workout's sets array first
        if let workout = currentWorkout,
           var sets = workout.sets {
            sets.removeAll { $0.id == setId }
            workout.sets = sets
            print("   Removed from workout's sets array. Remaining sets: \(sets.count)")
        }
        
        // Delete from model context
        modelContext.delete(exerciseSet)
        
        do {
            try modelContext.save()
            print("   Model context saved")
            
            // Force a refresh by temporarily setting to nil then back
            let workoutId = currentWorkout?.id
            currentWorkout = nil
            
            if let workoutId = workoutId {
                let descriptor = FetchDescriptor<Workout>(
                    predicate: #Predicate<Workout> { workout in
                        workout.id == workoutId
                    }
                )
                
                if let refreshedWorkout = try modelContext.fetch(descriptor).first {
                    currentWorkout = refreshedWorkout
                    print("   Workout refreshed. Sets count: \(refreshedWorkout.sets?.count ?? 0)")
                }
            }
            
            print("✅ Deleted set from \(exerciseName)")
            WatchSyncCenter.shared.deleteExerciseSet(id: setId)
        } catch {
            print("❌ Failed to delete set: \(error)")
        }
    }
    
    // MARK: - Utility Methods
    
    /**
     * Gets the count of sets for a specific exercise in the current workout.
     */
    func setCount(for exercise: Exercise) -> Int {
        guard let workout = currentWorkout else { return 0 }
        return workout.sets?.filter { $0.exercise?.id == exercise.id }.count ?? 0
    }
    
    /**
     * Searches exercises by name.
     */
    func searchExercises(query: String) -> [Exercise] {
        if query.isEmpty {
            return availableExercises
        }
        
        return availableExercises.filter { exercise in
            exercise.name.localizedCaseInsensitiveContains(query)
        }
    }
    
    /**
     * Updates workout duration for real-time timer display.
     */
    func updateWorkoutDuration() {
        // Force a UI update by modifying a property that triggers @Observable
        timerTick += 1
    }
    
    /**
     * Gets the last set for a specific exercise to pre-fill new sets.
     */
    func getLastSet(for exercise: Exercise) -> ExerciseSet? {
        guard let workout = currentWorkout else { return nil }
        
        return workout.sets?
            .filter { $0.exercise?.id == exercise.id }
            .sorted { $0.timestamp > $1.timestamp }
            .first
    }
    
    /**
     * Duplicates the last set for a specific exercise.
     */
    func duplicateLastSet(for exercise: Exercise) {
        guard let lastSet = getLastSet(for: exercise) else {
            print("❌ No last set found to duplicate for \(exercise.name)")
            return
        }
        
        let success = addSet(
            exercise: exercise,
            reps: lastSet.reps,
            weightLbs: lastSet.weightLbs,
            durationSeconds: lastSet.durationSeconds,
            distanceMeters: lastSet.distanceMeters,
            steps: lastSet.steps,
            isBodyweight: lastSet.isBodyweight,
            painLevel: lastSet.painLevel,
            rangeOfMotion: lastSet.rangeOfMotion
        )
        
        if success {
            print("✅ Duplicated last set for \(exercise.name)")
        }
    }
    
    /**
     * Refreshes workout data from the model context to ensure UI updates.
     */
    private func refreshWorkoutData() {
        guard let workoutId = currentWorkout?.id else { return }
        
        // Refresh the current workout from the model context
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate<Workout> { workout in
                workout.id == workoutId
            }
        )
        
        do {
            let workouts = try modelContext.fetch(descriptor)
            if let refreshedWorkout = workouts.first {
                currentWorkout = refreshedWorkout
            }
        } catch {
            print("❌ Failed to refresh workout data: \(error)")
        }
    }
}
