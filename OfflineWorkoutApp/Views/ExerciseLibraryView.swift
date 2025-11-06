import SwiftUI
import SwiftData

/**
 * Library view for managing user exercises with search and creation.
 */
struct ExerciseLibraryView: View {
    @Environment(ExerciseLibraryViewModel.self) private var viewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @State private var showingExerciseForm = false
    @State private var exerciseToEdit: Exercise?
    @State private var showingDeleteConfirmation = false
    @State private var exerciseToDelete: Exercise?
    
    private var filteredExercises: [Exercise] {
        if viewModel.searchQuery.isEmpty {
            return exercises
        } else {
            return exercises.filter { exercise in
                exercise.name.localizedCaseInsensitiveContains(viewModel.searchQuery) ||
                exercise.bodyPart?.rawValue.localizedCaseInsensitiveContains(viewModel.searchQuery) == true ||
                exercise.goal?.rawValue.localizedCaseInsensitiveContains(viewModel.searchQuery) == true ||
                exercise.muscles.contains { muscle in
                    muscle.localizedCaseInsensitiveContains(viewModel.searchQuery)
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Exercise List
                if filteredExercises.isEmpty {
                    emptyStateView
                } else {
                    exerciseListView
                }
            }
            .navigationTitle("Exercises")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingExerciseForm = true
                    }) {
                        Image(systemName: "plus")
                            .font(Theme.buttonFont)
                    }
                    .frame(minWidth: Theme.minTapTarget, minHeight: Theme.minTapTarget)
                }
            }
            .sheet(isPresented: $showingExerciseForm) {
                ExerciseFormView(exerciseToEdit: nil) { exercise in
                    viewModel.createExerciseFromForm(exercise)
                    showingExerciseForm = false
                }
            }
            .sheet(item: $exerciseToEdit) { exercise in
                ExerciseFormView(exerciseToEdit: exercise) { updatedExercise in
                    viewModel.updateExerciseFromForm(updatedExercise)
                    exerciseToEdit = nil
                }
            }
            .alert("Delete Exercise", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let exercise = exerciseToDelete {
                        viewModel.deleteExercise(exercise)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this exercise? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.secondaryText)
            
            TextField("Search exercises", text: Binding(
                get: { viewModel.searchQuery },
                set: { viewModel.searchQuery = $0 }
            ))
            .textFieldStyle(PlainTextFieldStyle())
            
            if !viewModel.searchQuery.isEmpty {
                Button(action: {
                    viewModel.searchQuery = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.secondaryText)
                }
                .frame(minWidth: Theme.minTapTarget, minHeight: Theme.minTapTarget)
            }
        }
        .formFieldStyle()
        .padding(.horizontal, Theme.spacingM)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "dumbbell")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text(exercises.isEmpty ? "No exercises yet" : "No matching exercises")
                .font(.headline)
            
            Text(exercises.isEmpty ? 
                 "Create your first exercise to get started" : 
                 "Try adjusting your search terms")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if exercises.isEmpty {
                Button("Create Exercise") {
                    showingExerciseForm = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Exercise List
    
    private var exerciseListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredExercises, id: \.id) { exercise in
                    ExerciseRowView(exercise: exercise)
                        .contextMenu {
                            Button("Edit") {
                                exerciseToEdit = exercise
                            }
                            
                            Button("Delete", role: .destructive) {
                                exerciseToDelete = exercise
                                showingDeleteConfirmation = true
                            }
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Exercise Row View
struct ExerciseRowView: View {
    let exercise: Exercise
    @Environment(ExerciseLibraryViewModel.self) private var viewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Created \(exercise.createdAt, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
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
            }
            
            // Allowed Metrics
            VStack(alignment: .leading, spacing: 4) {
                Text("Metrics:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(viewModel.formatAllowedMetrics(exercise.allowedMetrics))
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            
            // Muscles (if any)
            if !exercise.muscles.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Muscles:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(exercise.muscles.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    ExerciseLibraryView()
        .environment(ExerciseLibraryViewModel(modelContext: PreviewHelper.previewContext))
}