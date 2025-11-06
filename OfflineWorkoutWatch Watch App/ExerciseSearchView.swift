import SwiftUI

/**
 * View for searching exercises by name with a search bar.
 */
struct ExerciseSearchView: View {
    @Environment(WatchWorkoutViewModel.self) private var viewModel
    @State private var searchText = ""
    @State private var showingAddSetFor: Exercise?
    
    private var filteredExercises: [Exercise] {
        viewModel.searchExercises(query: searchText)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Search Bar
            TextField("Search", text: $searchText)
                .padding(.horizontal)
            
            // Results
            if searchText.isEmpty {
                emptySearchView
            } else if filteredExercises.isEmpty {
                noResultsView
            } else {
                exerciseListView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $showingAddSetFor) { exercise in
            AddSetFormView(exercise: exercise, prefillFromLastSet: true)
        }
    }
    
    // MARK: - Empty Search State
    
    private var emptySearchView: some View {
        VStack(spacing: 16) {
            Text("Search Exercises")
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - No Results State
    
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("No Results")
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Exercise List
    
    private var exerciseListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(filteredExercises, id: \.id) { exercise in
                    ExerciseSelectionRow(
                        exercise: exercise,
                        setCount: viewModel.setCount(for: exercise),
                        onSelect: {
                            selectExercise(exercise)
                        }
                    )
                }
            }
            .padding(.horizontal)
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

#Preview {
    NavigationStack {
        ExerciseSearchView()
            .environment(WatchWorkoutViewModel(modelContext: PreviewHelper.previewContext))
    }
}
