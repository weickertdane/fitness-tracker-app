import Foundation
import SwiftData
import Observation

/**
 * Manages workout history data and filtering for the iPhone app.
 */
@Observable
final class HistoryViewModel {
    
    // MARK: - State
    
    /// Currently selected date for filtering workouts
    var selectedDate: Date = Date()
    
    /// All workouts loaded from the database
    var allWorkouts: [Workout] = []
    
    /// Workouts filtered by the selected date
    var workoutsForSelectedDate: [Workout] {
        let calendar = Calendar.current
        return allWorkouts.filter { workout in
            calendar.isDate(workout.startedAt, inSameDayAs: selectedDate)
        }
    }
    
    /// Whether data is currently being loaded
    var isLoading: Bool = false
    
    /// Error message if data loading fails
    var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadWorkouts()
        setupNotificationObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("WorkoutDataDidChange"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("🔔 iOS History received WorkoutDataDidChange notification")
            self?.loadWorkouts()
        }
    }
    
    // MARK: - Data Loading
    
    /**
     * Loads all workouts from the database.
     */
    func loadWorkouts() {
        isLoading = true
        errorMessage = nil
        
        let descriptor = FetchDescriptor<Workout>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        
        do {
            allWorkouts = try modelContext.fetch(descriptor)
            print("✅ Loaded \(allWorkouts.count) workouts")
        } catch {
            errorMessage = "Failed to load workouts: \(error.localizedDescription)"
            print("❌ Failed to load workouts: \(error)")
            allWorkouts = []
        }
        
        isLoading = false
    }
    
    /**
     * Refreshes workout data from the database.
     */
    func refreshWorkouts() {
        loadWorkouts()
    }
    
    // MARK: - Date Selection
    
    /**
     * Updates the selected date and filters workouts accordingly.
     */
    func selectDate(_ date: Date) {
        selectedDate = date
    }
    
    // MARK: - Workout Management
    
    /**
     * Deletes a workout from the database.
     */
    func deleteWorkout(_ workout: Workout) {
        modelContext.delete(workout)
        
        do {
            try modelContext.save()
            loadWorkouts() // Refresh the list
            print("✅ Deleted workout: \(workout.id)")
            WatchSyncCenter.shared.deleteWorkout(id: workout.id)
        } catch {
            errorMessage = "Failed to delete workout: \(error.localizedDescription)"
            print("❌ Failed to delete workout: \(error)")
        }
    }
    
    /**
     * Updates a workout's note.
     */
    func updateWorkoutNote(_ workout: Workout, note: String) {
        workout.note = note.isEmpty ? nil : note
        
        do {
            try modelContext.save()
            print("✅ Updated workout note")
            WatchSyncCenter.shared.upsertWorkout(workout)
        } catch {
            errorMessage = "Failed to update workout note: \(error.localizedDescription)"
            print("❌ Failed to update workout note: \(error)")
        }
    }
    
    // MARK: - Utility Methods
    
    /**
     * Gets workouts for a specific date range.
     */
    func workouts(for dateRange: ClosedRange<Date>) -> [Workout] {
        return allWorkouts.filter { workout in
            dateRange.contains(workout.startedAt)
        }
    }
    
    /**
     * Gets dates that have workouts for calendar highlighting.
     */
    var datesWithWorkouts: Set<Date> {
        let calendar = Calendar.current
        return Set(allWorkouts.map { workout in
            calendar.startOfDay(for: workout.startedAt)
        })
    }
    
    /**
     * Gets workout count for the selected date.
     */
    var workoutCountForSelectedDate: Int {
        workoutsForSelectedDate.count
    }
    
    /**
     * Formats duration for display.
     */
    func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    /**
     * Formats weight for display (shows as lbs).
     */
    func formatWeight(_ weightLbs: Double) -> String {
        if weightLbs == floor(weightLbs) {
            return "\(Int(weightLbs)) lbs"
        } else {
            return "\(String(format: "%.1f", weightLbs)) lbs"
        }
    }
    
    /**
     * Formats duration in mm:ss format.
     */
    func formatDurationMinutesSeconds(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
