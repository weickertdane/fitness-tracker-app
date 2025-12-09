import SwiftUI

/**
 * Main workout view showing current exercises and sets with controls.
 */
struct ActiveWorkoutView: View {
    @Environment(WatchWorkoutViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddExercise = false
    @State private var showingEndWorkout = false
    @State private var showingAddSetFor: Exercise?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Exercise List
                if viewModel.exerciseGroups.isEmpty {
                    emptyStateView
                } else {
                    exerciseListView
                }
                
                // Action Buttons
                actionButtons
                    .padding(.top, Theme.spacingM)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseToWorkoutView()
        }
        .sheet(isPresented: $showingEndWorkout) {
            EndWorkoutView()
        }
        .sheet(item: $showingAddSetFor) { exercise in
            AddSetFormView(exercise: exercise, prefillFromLastSet: true)
        }
        .onChange(of: viewModel.isWorkoutActive) { _, isActive in
            if !isActive {
                // Workout ended, dismiss this view to return to StartWorkoutView
                dismiss()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SetSavedSuccessfully"))) { _ in
            // Dismiss the add exercise sheet when a set is saved
            showingAddExercise = false
        }
    }
    
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: Theme.spacingM) {
            Image(systemName: "dumbbell")
                .font(.system(size: 40))
                .foregroundStyle(Theme.secondaryText)
            
            Text("No exercises yet")
                .font(Theme.headlineFont)
            
        }
        .padding(Theme.spacingM)
    }
    
    // MARK: - Exercise List
    
    private var exerciseListView: some View {
        LazyVStack(spacing: 20) {
                ForEach(Array(viewModel.exerciseGroups.enumerated()), id: \.element.exercise.id) { index, group in
                    ExerciseGroupRow(
                        exercise: group.exercise,
                        sets: group.sets,
                        exerciseIndex: index,
                        onAddSet: {
                            showingAddSetFor = group.exercise
                        },
                        onDuplicateLastSet: {
                            viewModel.duplicateLastSet(for: group.exercise)
                        },
                        onDeleteSet: { set in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.deleteSet(set)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: Theme.watchSpacingM) {
            // Add Exercise Button
            Button(action: {
                showingAddExercise = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Exercise")
                }
                .font(Theme.buttonFont)
            }
            
            // End Workout Button - Only show if there's an active workout
            if viewModel.isWorkoutActive {
                Button(action: {
                    showingEndWorkout = true
                }) {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("End Workout")
                    }
                    .font(Theme.buttonFont)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: Theme.watchTapTarget)
                    .background(Theme.errorColor)
                    .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, Theme.spacingM)
        .padding(.bottom, Theme.spacingM)
    }
    
}

// MARK: - Exercise Group Row
struct ExerciseGroupRow: View {
    let exercise: Exercise
    let sets: [ExerciseSet]
    let exerciseIndex: Int
    let onAddSet: () -> Void
    let onDuplicateLastSet: () -> Void
    let onDeleteSet: (ExerciseSet) -> Void
    @State private var showingEditSet: ExerciseSet?
    
    // Different accent colors for visual distinction
    private var accentColor: Color {
        let colors: [Color] = [.orange, .blue, .green, .purple, .pink, .teal]
        return colors[exerciseIndex % colors.count]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Exercise Header with Add Button
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .foregroundStyle(accentColor)
                }
                
                Spacer(minLength: 4)
                
                // Add Set Button
                Button(action: onAddSet) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(accentColor)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .accessibleButton(label: "Add set")
            }
            
            // Sets List
            if !sets.isEmpty {
                VStack(spacing: 6) {
                    ForEach(sets, id: \.id) { set in
                        SetRow(
                            exerciseSet: set,
                            onEdit: {
                                showingEditSet = set
                            },
                            onDelete: {
                                print("🔵 SetRow delete triggered for set \(set.id)")
                                onDeleteSet(set)
                            }
                        )
                        .id(set.id)
                    }
                    
                    // Duplicate Last Set Button
                    Button(action: onDuplicateLastSet) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 12))
                            .foregroundStyle(accentColor)
                            .frame(width: 24, height: 24)
                            .background(accentColor.opacity(0.15))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            } else {
                // Add Set Pill when no sets
                Button(action: onAddSet) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.caption2)
                        Text("Add Set")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(accentColor.opacity(0.15))
                    .foregroundStyle(accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(12)
        .background(accentColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(accentColor.opacity(0.3), lineWidth: 1.5)
        )
        .sheet(item: $showingEditSet) { set in
            AddSetFormView(exercise: exercise, prefillFromLastSet: false, editingSet: set)
        }
    }
}

// MARK: - Set Row
struct SetRow: View {
    let exerciseSet: ExerciseSet
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Set Details - Compact notation
            Text(setDescription)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .allowsTightening(true)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 4)
            
            // Action Buttons - Smaller, tighter
            HStack(spacing: 4) {
                // Edit Button
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
                .accessibleButton(label: "Edit set")
                
                // Delete Button
                Button(action: {
                    print("🗑️ Delete button tapped for set \(exerciseSet.id)")
                    onDelete()
                }) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Theme.errorColor)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
                .accessibleButton(label: "Delete set")
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var setDescription: String {
        var components: [String] = []
        
        // Reps: just the number
        if let reps = exerciseSet.reps {
            components.append("\(reps)")
        }
        
        // Weight: just the number or BW
        if exerciseSet.isBodyweight {
            components.append("BW")
        } else if let weight = exerciseSet.weightLbs {
            components.append("@ \(Int(weight))")
        }
        
        // Duration
        if let duration = exerciseSet.durationSeconds {
            let minutes = duration / 60
            let seconds = duration % 60
            if minutes > 0 {
                components.append("\(minutes):\(String(format: "%02d", seconds))")
            } else {
                components.append("\(seconds)s")
            }
        }
        
        // Distance - show in km if >= 1km, otherwise in meters
        if let distance = exerciseSet.distanceMeters {
            if distance >= 1000 {
                let km = distance / 1000
                if km.truncatingRemainder(dividingBy: 1) == 0 {
                    components.append("\(Int(km)) km")
                } else {
                    components.append(String(format: "%.1f km", km))
                }
            } else {
                components.append("\(Int(distance)) m")
            }
        }
        
        // Avg Pace
        if let pace = exerciseSet.avgPaceSeconds {
            let minutes = pace / 60
            let seconds = pace % 60
            let unit = exerciseSet.paceUnit ?? "km"
            components.append("\(minutes):\(String(format: "%02d", seconds))/\(unit)")
        }
        
        // Steps
        if let steps = exerciseSet.steps {
            components.append("\(steps) steps")
        }
        
        return components.joined(separator: " ")
    }
}

#Preview {
    ActiveWorkoutView()
        .environment(WatchWorkoutViewModel(modelContext: PreviewHelper.previewContext))
}
