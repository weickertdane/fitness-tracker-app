import SwiftUI

/**
 * View for displaying exercises filtered by goal or body part.
 */
struct FilteredExerciseListView: View {
    let filterType: FilterType
    
    @Environment(WatchWorkoutViewModel.self) private var viewModel
    @State private var showingAddSetFor: Exercise?
    
    private var filteredExercises: [Exercise] {
        switch filterType {
        case .goal(let goal):
            return viewModel.availableExercises.filter { $0.goal == goal }
        case .bodyPart(let bodyPart):
            return viewModel.availableExercises.filter { $0.bodyPart == bodyPart }
        case .combined(let goal, let bodyPart):
            return viewModel.availableExercises.filter { $0.goal == goal && $0.bodyPart == bodyPart }
        }
    }
    
    private var navigationTitle: String {
        switch filterType {
        case .goal(let goal):
            return goal.rawValue.capitalized
        case .bodyPart(let bodyPart):
            return bodyPart.rawValue.capitalized
        case .combined(_, let bodyPart):
            return bodyPart.rawValue.capitalized
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with count
            if !filteredExercises.isEmpty {
                HStack {
                    Text("\(filteredExercises.count) exercises")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
            }
            
            // Exercise List
            if filteredExercises.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredExercises, id: \.id) { exercise in
                            ExerciseSelectionRow(
                                exercise: exercise,
                                setCount: viewModel.setCount(for: exercise),
                                onSelect: {
                                    selectExercise(exercise)
                                },
                                filterType: filterType
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $showingAddSetFor) { exercise in
            AddSetFormView(exercise: exercise, prefillFromLastSet: true)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: filterIcon)
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("No Exercises")
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var filterIcon: String {
        switch filterType {
        case .goal(let goal):
            switch goal {
            case .strength:
                return "bolt.fill"
            case .rehab:
                return "heart.fill"
            case .cardio:
                return "figure.run"
            }
        case .bodyPart, .combined:
            return "figure.arms.open"
        }
    }
    
    // MARK: - Actions
    
    private func selectExercise(_ exercise: Exercise) {
        // Add exercise to workout first
        let success = viewModel.addExerciseToWorkout(exercise)
        
        // Only show add set form if exercise was successfully added
        if success {
            showingAddSetFor = exercise
        }
    }
}

// MARK: - Filter Type

enum FilterType: Hashable {
    case goal(Goal)
    case bodyPart(BodyPart)
    case combined(Goal, BodyPart)
}

#Preview {
    NavigationStack {
        FilteredExerciseListView(filterType: .goal(.strength))
            .environment(WatchWorkoutViewModel(modelContext: PreviewHelper.previewContext))
    }
}
