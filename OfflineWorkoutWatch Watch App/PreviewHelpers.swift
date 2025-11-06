//
//  PreviewHelpers.swift
//  OfflineWorkoutWatch Watch App
//
//  Created by Dane Weickert on 9/22/25.
//

import SwiftUI

/**
 * Helper views and data for SwiftUI previews.
 */
struct PreviewHelpers {
    
    /**
     * Sample workout exercise data for previews.
     */
    static func sampleWorkoutExercise() -> WorkoutExercise {
        var exercise = WorkoutExercise(name: "Push-ups")
        exercise.sets = [
            ExerciseSetData(reps: 12, weight: nil, duration: nil),
            ExerciseSetData(reps: 10, weight: nil, duration: nil),
            ExerciseSetData(reps: 8, weight: nil, duration: nil)
        ]
        return exercise
    }
    
    /**
     * Sample workout with multiple exercises.
     */
    static func sampleWorkoutWithExercises() -> [WorkoutExercise] {
        var pushups = WorkoutExercise(name: "Push-ups")
        pushups.sets = [
            ExerciseSetData(reps: 12, weight: nil, duration: nil),
            ExerciseSetData(reps: 10, weight: nil, duration: nil)
        ]
        
        var squats = WorkoutExercise(name: "Squats")
        squats.sets = [
            ExerciseSetData(reps: 15, weight: 135, duration: nil),
            ExerciseSetData(reps: 12, weight: 135, duration: nil)
        ]
        
        var plank = WorkoutExercise(name: "Plank")
        plank.sets = [
            ExerciseSetData(reps: nil, weight: nil, duration: 60)
        ]
        
        return [pushups, squats, plank]
    }
    
    /**
     * Sample completed workouts for history.
     */
    static func sampleCompletedWorkouts() -> [CompletedWorkout] {
        return [
            CompletedWorkout(
                date: Date().addingTimeInterval(-86400), // Yesterday
                duration: 1800, // 30 minutes
                exerciseCount: 3,
                totalSets: 8,
                exercises: sampleWorkoutWithExercises()
            ),
            CompletedWorkout(
                date: Date().addingTimeInterval(-172800), // 2 days ago
                duration: 2400, // 40 minutes
                exerciseCount: 4,
                totalSets: 12,
                exercises: sampleWorkoutWithExercises()
            )
        ]
    }
}

// MARK: - Preview Extensions

// WorkoutSessionView extension removed - using new WatchAppRootView system

extension ExerciseDetailView {
    /**
     * Preview with sample exercise data.
     */
    static var previewWithSampleExercise: some View {
        @State var sampleExercise = PreviewHelpers.sampleWorkoutExercise()
        return ExerciseDetailView(exercise: $sampleExercise)
    }
}

extension WorkoutHistoryView {
    /**
     * Preview with sample workout history.
     */
    static var previewWithHistory: some View {
        var view = WorkoutHistoryView()
        // In a real implementation, we'd inject sample data
        return view
    }
}

#Preview("Main App") {
    WatchAppRootView()
        .environment(WatchWorkoutViewModel(modelContext: PreviewHelper.previewContext))
}

#Preview("Exercise Detail") {
    ExerciseDetailView.previewWithSampleExercise
}

#Preview("Workout History") {
    WorkoutHistoryView.previewWithHistory
}
