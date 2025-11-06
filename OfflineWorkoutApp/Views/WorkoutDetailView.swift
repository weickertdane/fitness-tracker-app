import SwiftUI
import SwiftData

/**
 * Detailed view of a workout with editable notes and sets.
 */
struct WorkoutDetailView: View {
    let workout: Workout
    
    @Environment(HistoryViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var workoutNote: String
    @State private var showingDeleteConfirmation = false
    
    init(workout: Workout) {
        self.workout = workout
        self._workoutNote = State(initialValue: workout.note ?? "")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Workout Summary
                    workoutSummaryCard
                    
                    // HealthKit Integration Indicator - REQUIRED for App Store compliance
                    healthKitIndicator
                    
                    // Workout Note
                    workoutNoteSection
                    
                    // Exercise Sets
                    exerciseSetsSection
                }
                .padding()
            }
            .navigationTitle("Workout Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Delete Workout", role: .destructive) {
                            showingDeleteConfirmation = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Delete Workout", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteWorkout(workout)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this workout? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - HealthKit Indicator
    
    /// Displays Apple Health integration status - required for App Store Guideline 2.5.1
    private var healthKitIndicator: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.text.square.fill")
                .font(.title3)
                .foregroundStyle(.red)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Apple Health Integration")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if HealthKitManager.shared.isEnabled && HealthKitManager.shared.authorizationStatus == .authorized {
                    Text("Workout data synced to Apple Health")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Enable in Settings to sync with Apple Health")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Workout Summary
    
    private var workoutSummaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(workout.startedAt, style: .date)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(workout.startedAt, style: .time)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(viewModel.formatDuration(workout.durationSeconds))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                StatCard(title: "Sets", value: "\(workout.sets?.count ?? 0)")
                StatCard(title: "Exercises", value: "\(exerciseGroups.count)")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Workout Note
    
    private var workoutNoteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextField("Add workout notes...", text: $workoutNote, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
                .onChange(of: workoutNote) { _, newValue in
                    viewModel.updateWorkoutNote(workout, note: newValue)
                }
        }
    }
    
    // MARK: - Exercise Sets
    
    private var exerciseSetsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Exercises")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(exerciseGroups, id: \.exercise.id) { group in
                ExerciseGroupCard(exercise: group.exercise, sets: group.sets, viewModel: viewModel)
            }
        }
    }
    
    private var exerciseGroups: [(exercise: Exercise, sets: [ExerciseSet])] {
        let groupedSets = Dictionary(grouping: workout.sets ?? []) { set in
            set.exercise
        }
        
        return groupedSets.compactMap { (exercise, sets) in
            guard let exercise = exercise else { return nil as (exercise: Exercise, sets: [ExerciseSet])? }
            return (exercise: exercise, sets: sets.sorted { $0.timestamp < $1.timestamp })
        }.sorted { $0.exercise.name < $1.exercise.name }
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ExerciseGroupCard: View {
    let exercise: Exercise
    let sets: [ExerciseSet]
    let viewModel: HistoryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 8) {
                        Text(exercise.bodyPart?.rawValue.capitalized ?? "Other")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                        
                        Text(exercise.goal?.rawValue.capitalized ?? "Strength")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                Text("\(sets.count) sets")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Sets List
            VStack(spacing: 8) {
                ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                    SetDetailRow(setNumber: index + 1, exerciseSet: set, viewModel: viewModel)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct SetDetailRow: View {
    let setNumber: Int
    let exerciseSet: ExerciseSet
    let viewModel: HistoryViewModel
    
    var body: some View {
        HStack {
            Text("\(setNumber)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .leading)
            
            Text(setDescription)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var setDescription: String {
        var components: [String] = []
        
        if let reps = exerciseSet.reps {
            components.append("\(reps) reps")
        }
        
        if exerciseSet.isBodyweight {
            components.append("bodyweight")
        } else if let weight = exerciseSet.weightLbs {
            components.append(viewModel.formatWeight(weight))
        }
        
        if let duration = exerciseSet.durationSeconds {
            components.append(viewModel.formatDurationMinutesSeconds(duration))
        }
        
        if let distance = exerciseSet.distanceMeters {
            components.append("\(Int(distance))m")
        }
        
        if let steps = exerciseSet.steps {
            components.append("\(steps) steps")
        }
        
        return components.joined(separator: " • ")
    }
}

#Preview {
    WorkoutDetailView(workout: Workout(startedAt: Date()))
        .environment(HistoryViewModel(modelContext: PreviewHelper.previewContext))
}