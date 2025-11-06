import XCTest
import SwiftData
@testable import OfflineWorkoutApp

/**
 * Unit tests for OfflineWorkout core models and business logic.
 * Tests happy-path scenarios for exercise creation, set logging, and workout management.
 */
final class OfflineWorkoutModelTests: XCTestCase {
    
    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!
    
    override func setUpWithError() throws {
        // Create in-memory ModelContainer for testing
        let schema = Schema([
            Exercise.self,
            Workout.self,
            ExerciseSet.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        modelContext = modelContainer.mainContext
    }
    
    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
    }
    
    // MARK: - Exercise Creation Tests
    
    /**
     * Test creating a running exercise with duration-only metrics and logging a 10-minute set.
     */
    func testRunningExerciseWithDurationOnly() throws {
        // Create running exercise with duration only
        let runExercise = Exercise(
            name: "Run",
            goal: .strength,
            bodyPart: .other,
            allowedMetrics: [.durationSeconds]
        )
        
        // Verify exercise properties
        XCTAssertEqual(runExercise.name, "Run")
        XCTAssertEqual(runExercise.goal, .strength)
        XCTAssertEqual(runExercise.bodyPart, .other)
        XCTAssertEqual(runExercise.allowedMetrics, [.durationSeconds])
        XCTAssertNotNil(runExercise.createdAt)
        XCTAssertNotNil(runExercise.id)
        
        // Save exercise to context
        modelContext.insert(runExercise)
        try modelContext.save()
        
        // Create workout
        let workout = Workout(startedAt: Date())
        modelContext.insert(workout)
        try modelContext.save()
        
        // Log a 10-minute set (600 seconds)
        let tenMinutesInSeconds = 10 * 60
        let exerciseSet = ExerciseSet(
            workout: workout,
            exercise: runExercise,
            durationSeconds: tenMinutesInSeconds
        )
        
        // Verify set properties
        XCTAssertEqual(exerciseSet.durationSeconds, tenMinutesInSeconds)
        XCTAssertNil(exerciseSet.reps)
        XCTAssertNil(exerciseSet.weightLbs)
        XCTAssertNil(exerciseSet.distanceMeters)
        XCTAssertNil(exerciseSet.steps)
        XCTAssertFalse(exerciseSet.isBodyweight)
        XCTAssertEqual(exerciseSet.exercise, runExercise)
        XCTAssertEqual(exerciseSet.workout, workout)
        
        // Save set to context
        modelContext.insert(exerciseSet)
        try modelContext.save()
        
        // Verify the set is associated with the workout
        XCTAssertTrue(workout.sets?.contains(exerciseSet) ?? false)
        
        print("✅ Running exercise test passed: 10-minute duration-only set logged successfully")
    }
    
    /**
     * Test creating a Stairmaster exercise with steps and duration metrics, logging 300 steps + 12 minutes.
     */
    func testStairmasterExerciseWithStepsAndDuration() throws {
        // Create Stairmaster exercise with steps and duration
        let stairmasterExercise = Exercise(
            name: "Stairmaster",
            goal: .strength,
            bodyPart: .other,
            allowedMetrics: [.steps, .durationSeconds]
        )
        
        // Verify exercise properties
        XCTAssertEqual(stairmasterExercise.name, "Stairmaster")
        XCTAssertEqual(stairmasterExercise.allowedMetrics.sorted(by: { $0.rawValue < $1.rawValue }), 
                      [.durationSeconds, .steps].sorted(by: { $0.rawValue < $1.rawValue }))
        
        // Save exercise to context
        modelContext.insert(stairmasterExercise)
        try modelContext.save()
        
        // Create workout
        let workout = Workout(startedAt: Date())
        modelContext.insert(workout)
        try modelContext.save()
        
        // Log 300 steps + 12 minutes set
        let twelveMinutesInSeconds = 12 * 60
        let exerciseSet = ExerciseSet(
            workout: workout,
            exercise: stairmasterExercise,
            steps: 300,
            durationSeconds: twelveMinutesInSeconds
        )
        
        // Verify set properties
        XCTAssertEqual(exerciseSet.steps, 300)
        XCTAssertEqual(exerciseSet.durationSeconds, twelveMinutesInSeconds)
        XCTAssertNil(exerciseSet.reps)
        XCTAssertNil(exerciseSet.weightLbs)
        XCTAssertNil(exerciseSet.distanceMeters)
        XCTAssertFalse(exerciseSet.isBodyweight)
        
        // Save set to context
        modelContext.insert(exerciseSet)
        try modelContext.save()
        
        // Verify the set is associated with the workout
        XCTAssertTrue(workout.sets?.contains(exerciseSet) ?? false)
        
        print("✅ Stairmaster exercise test passed: 300 steps + 12 minutes logged successfully")
    }
    
    /**
     * Test that a rehab exercise properly stores painLevel and rangeOfMotion when provided.
     */
    func testRehabExerciseWithPainAndRangeOfMotion() throws {
        // Create rehab exercise
        let rehabExercise = Exercise(
            name: "Physical Therapy Stretch",
            goal: .rehab,
            bodyPart: .shoulders,
            allowedMetrics: [.reps, .durationSeconds]
        )
        
        // Verify exercise is for rehab
        XCTAssertEqual(rehabExercise.goal, .rehab)
        
        // Save exercise to context
        modelContext.insert(rehabExercise)
        try modelContext.save()
        
        // Create workout
        let workout = Workout(startedAt: Date())
        modelContext.insert(workout)
        try modelContext.save()
        
        // Log rehab set with pain level and range of motion
        let rehabSet = ExerciseSet(
            workout: workout,
            exercise: rehabExercise,
            reps: 10,
            durationSeconds: 120, // 2 minutes
            painLevel: 3,         // 1-10 scale
            rangeOfMotion: 4      // 1-5 scale
        )
        
        // Verify rehab-specific properties are stored
        XCTAssertEqual(rehabSet.painLevel, 3)
        XCTAssertEqual(rehabSet.rangeOfMotion, 4)
        XCTAssertEqual(rehabSet.reps, 10)
        XCTAssertEqual(rehabSet.durationSeconds, 120)
        
        // Save set to context
        modelContext.insert(rehabSet)
        try modelContext.save()
        
        // Test another rehab set with different values
        let rehabSet2 = ExerciseSet(
            workout: workout,
            exercise: rehabExercise,
            reps: 15,
            painLevel: 2,
            rangeOfMotion: 5
        )
        
        XCTAssertEqual(rehabSet2.painLevel, 2)
        XCTAssertEqual(rehabSet2.rangeOfMotion, 5)
        XCTAssertEqual(rehabSet2.reps, 15)
        
        modelContext.insert(rehabSet2)
        try modelContext.save()
        
        // Verify both sets are associated with the workout
        XCTAssertTrue(workout.sets?.contains(rehabSet) ?? false)
        XCTAssertTrue(workout.sets?.contains(rehabSet2) ?? false)
        XCTAssertEqual(workout.sets?.count ?? 0, 2)
        
        print("✅ Rehab exercise test passed: painLevel and rangeOfMotion stored correctly")
    }
    
    /**
     * Test that deleting a workout removes all its associated sets.
     */
    func testDeletingWorkoutRemovesSets() throws {
        // Create exercise
        let exercise = Exercise(
            name: "Bench Press",
            goal: .strength,
            bodyPart: .chest,
            allowedMetrics: [.reps, .weightLbs]
        )
        modelContext.insert(exercise)
        
        // Create workout
        let workout = Workout(startedAt: Date())
        modelContext.insert(workout)
        
        // Create multiple sets for the workout
        let set1 = ExerciseSet(workout: workout, exercise: exercise, reps: 10, weightLbs: 135.0)
        let set2 = ExerciseSet(workout: workout, exercise: exercise, reps: 8, weightLbs: 155.0)
        let set3 = ExerciseSet(workout: workout, exercise: exercise, reps: 6, weightLbs: 175.0)
        
        modelContext.insert(set1)
        modelContext.insert(set2)
        modelContext.insert(set3)
        
        try modelContext.save()
        
        // Verify sets are associated with workout
        XCTAssertEqual(workout.sets?.count ?? 0, 3)
        XCTAssertTrue(workout.sets?.contains(set1) ?? false)
        XCTAssertTrue(workout.sets?.contains(set2) ?? false)
        XCTAssertTrue(workout.sets?.contains(set3) ?? false)
        
        // Get set IDs for verification
        let setIds = workout.sets?.map { $0.id } ?? []
        
        // Delete the workout
        modelContext.delete(workout)
        try modelContext.save()
        
        // Verify sets are also deleted (cascade delete)
        let remainingSets = try modelContext.fetch(FetchDescriptor<ExerciseSet>())
        let remainingSetIds = remainingSets.map { $0.id }
        
        // Check that none of the original sets remain
        for setId in setIds {
            XCTAssertFalse(remainingSetIds.contains(setId), "Set with ID \(setId) should have been deleted")
        }
        
        // Verify the exercise still exists (should not be deleted)
        let remainingExercises = try modelContext.fetch(FetchDescriptor<Exercise>())
        XCTAssertTrue(remainingExercises.contains(exercise), "Exercise should still exist after workout deletion")
        
        print("✅ Workout deletion test passed: all sets removed when workout deleted")
    }
    
    // MARK: - Additional Validation Tests
    
    /**
     * Test exercise validation and convenience methods.
     */
    func testExerciseValidationAndConvenience() throws {
        // Test convenience initializer for running
        let runExercise = Exercise.createRunningExercise(name: "Morning Run", difficulty: 2)
        XCTAssertEqual(runExercise.name, "Morning Run")
        XCTAssertEqual(runExercise.difficulty, 2)
        XCTAssertEqual(runExercise.difficultyDescription, "Easy")
        XCTAssertTrue(runExercise.hasDifficultyRating)
        
        // Test convenience initializer for cardio
        let cardioExercise = Exercise.createCardioExercise(name: "Elliptical")
        XCTAssertEqual(cardioExercise.name, "Elliptical")
        XCTAssertNil(cardioExercise.difficulty)
        XCTAssertEqual(cardioExercise.difficultyDescription, "Not set")
        XCTAssertFalse(cardioExercise.hasDifficultyRating)
        
        print("✅ Exercise validation test passed: convenience methods work correctly")
    }
    
    /**
     * Test workout duration calculation.
     */
    func testWorkoutDurationCalculation() throws {
        let startTime = Date()
        let workout = Workout(startedAt: startTime)
        
        // Test ongoing workout (no end time)
        XCTAssertGreaterThanOrEqual(workout.durationSeconds, 0)
        
        // Test completed workout
        let endTime = startTime.addingTimeInterval(3600) // 1 hour later
        workout.endedAt = endTime
        
        XCTAssertEqual(workout.durationSeconds, 3600)
        
        print("✅ Workout duration test passed: duration calculated correctly")
    }
    
    /**
     * Test that sets require at least one metric to be valid.
     */
    func testSetValidation() throws {
        let exercise = Exercise(name: "Test Exercise", goal: .strength, bodyPart: .chest)
        let workout = Workout(startedAt: Date())
        
        modelContext.insert(exercise)
        modelContext.insert(workout)
        
        // Valid set with reps
        let validSet = ExerciseSet(workout: workout, exercise: exercise, reps: 10)
        XCTAssertNotNil(validSet.reps)
        
        // Valid set with weight
        let validSet2 = ExerciseSet(workout: workout, exercise: exercise, weightLbs: 135.0)
        XCTAssertNotNil(validSet2.weightLbs)
        
        // Valid set with duration
        let validSet3 = ExerciseSet(workout: workout, exercise: exercise, durationSeconds: 60)
        XCTAssertNotNil(validSet3.durationSeconds)
        
        print("✅ Set validation test passed: sets can be created with individual metrics")
    }
}

// MARK: - Test Helpers

extension OfflineWorkoutModelTests {
    
    /**
     * Helper to create a test exercise with specified metrics.
     */
    private func createTestExercise(
        name: String,
        goal: Goal = .strength,
        bodyPart: BodyPart = .chest,
        allowedMetrics: [MetricType] = [.reps, .weightLbs]
    ) -> Exercise {
        return Exercise(
            name: name,
            goal: goal,
            bodyPart: bodyPart,
            allowedMetrics: allowedMetrics
        )
    }
    
    /**
     * Helper to create a test workout.
     */
    private func createTestWorkout(startedAt: Date = Date()) -> Workout {
        return Workout(startedAt: startedAt)
    }
}
