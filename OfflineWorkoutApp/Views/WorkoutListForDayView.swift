import SwiftUI
import SwiftData

/**
 * List of workouts for a specific selected date.
 */
struct WorkoutListForDayView: View {
    let selectedDate: Date
    
    @Environment(HistoryViewModel.self) private var viewModel
    @State private var showingDeleteConfirmation = false
    @State private var workoutToDelete: Workout?
    
    private var workoutsForDate: [Workout] {
        let calendar = Calendar.current
        return viewModel.allWorkouts.filter { workout in
            calendar.isDate(workout.startedAt, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Show total duration if workouts exist
            if !workoutsForDate.isEmpty {
                HStack {
                    Text("Total Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(totalDuration)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
            }
            
            // Workout List
            if workoutsForDate.isEmpty {
                emptyStateView
            } else {
                workoutListView
            }
        }
        .alert("Delete Workout", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let workout = workoutToDelete {
                    viewModel.deleteWorkout(workout)
                }
            }
        } message: {
            Text("Are you sure you want to delete this workout? This action cannot be undone.")
        }
    }
    
    private var totalDuration: String {
        let totalSeconds = workoutsForDate.reduce(0) { $0 + $1.durationSeconds }
        return viewModel.formatDuration(totalSeconds)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.minus")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No workouts")
                .font(.headline)
            
            Text("No workouts recorded for this date")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Workout List
    
    private var workoutListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(workoutsForDate.sorted { $0.startedAt > $1.startedAt }, id: \.id) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        WorkoutRowView(workout: workout, viewModel: viewModel)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            workoutToDelete = workout
                            showingDeleteConfirmation = true
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
}

// MARK: - Workout Row View
struct WorkoutRowView: View {
    let workout: Workout
    let viewModel: HistoryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Workout Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.startedAt, style: .time)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Duration: \(viewModel.formatDuration(workout.durationSeconds))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(workout.sets?.count ?? 0)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Text("sets")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Exercise Summary
            if !exerciseGroups.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Exercises:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 6) {
                        ForEach(exerciseGroups, id: \.exercise.id) { group in
                            Text("\(group.exercise.name) (\(group.sets.count))")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            // Workout Note
            if let note = workout.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var exerciseGroups: [(exercise: Exercise, sets: [ExerciseSet])] {
        let groupedSets = Dictionary(grouping: workout.sets ?? []) { set in
            set.exercise
        }
        
        return groupedSets.compactMap { (exercise, sets) in
            guard let exercise = exercise else { return nil }
            return (exercise: exercise, sets: sets)
        }.sorted { $0.exercise.name < $1.exercise.name }
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    let spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes, proposal: proposal).size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets = layout(sizes: sizes, proposal: proposal).offsets
        
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + offsets[index].x, y: bounds.minY + offsets[index].y), proposal: .unspecified)
        }
    }
    
    private func layout(sizes: [CGSize], proposal: ProposedViewSize) -> (offsets: [CGPoint], size: CGSize) {
        let containerWidth = proposal.width ?? 300
        var offsets: [CGPoint] = []
        var currentRow: [CGSize] = []
        var currentRowWidth: CGFloat = 0
        var currentY: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        for size in sizes {
            if currentRowWidth + size.width > containerWidth && !currentRow.isEmpty {
                // Start new row
                let rowHeight = currentRow.map(\.height).max() ?? 0
                currentY += rowHeight + spacing
                currentRowWidth = 0
                currentRow = []
            }
            
            offsets.append(CGPoint(x: currentRowWidth, y: currentY))
            currentRow.append(size)
            currentRowWidth += size.width + spacing
            maxWidth = max(maxWidth, currentRowWidth - spacing)
        }
        
        let finalHeight = currentY + (currentRow.map(\.height).max() ?? 0)
        return (offsets, CGSize(width: maxWidth, height: finalHeight))
    }
}

#Preview {
    WorkoutListForDayView(selectedDate: Date())
        .environment(HistoryViewModel(modelContext: PreviewHelper.previewContext))
}