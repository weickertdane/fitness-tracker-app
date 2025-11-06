import SwiftUI

/**
 * Main exercise library view with action buttons for Apple Watch.
 */
struct ExerciseLibraryView: View {
    @Environment(WatchWorkoutViewModel.self) private var viewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.watchSpacingL) {
                Spacer()
                
                // New Exercise Button
                NavigationLink(destination: ExerciseTemplateFormView()) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("New Exercise")
                            .font(Theme.headlineFont)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.watchSpacingM)
                    .background(Theme.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusM))
                }
                .buttonStyle(PlainButtonStyle())
                
                // View Exercises Button
                NavigationLink(destination: ExerciseListView()) {
                    HStack {
                        Image(systemName: "list.bullet")
                            .font(.title3)
                        Text("View Exercises")
                            .font(Theme.headlineFont)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.watchSpacingM)
                    .background(Theme.secondaryBackground)
                    .foregroundStyle(Theme.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusM))
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.horizontal, Theme.watchSpacingM)
            .navigationTitle("Exercises")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/**
 * Simple searchable list of exercises for Apple Watch.
 */
struct ExerciseListView: View {
    @Environment(WatchWorkoutViewModel.self) private var viewModel
    @State private var searchText = ""
    
    private var filteredExercises: [Exercise] {
        let exercises = viewModel.availableExercises.sorted { $0.name < $1.name }
        
        if searchText.isEmpty {
            return exercises
        } else {
            return exercises.filter { exercise in
                exercise.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar - simple design matching add exercise flow
            TextField("Search", text: $searchText)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)
            
            // Exercise list
            if filteredExercises.isEmpty {
                VStack(spacing: Theme.watchSpacingM) {
                    Image(systemName: "dumbbell")
                        .font(.title2)
                        .foregroundStyle(Theme.secondaryText)
                    
                    Text(searchText.isEmpty ? "No exercises" : "No results")
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredExercises, id: \.id) { exercise in
                            VStack(spacing: 0) {
                                HStack {
                                    Text(exercise.name)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundStyle(Theme.primaryText)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, Theme.watchSpacingM)
                                .contentShape(Rectangle())
                                
                                // Divider
                                Rectangle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(height: 1)
                                    .padding(.leading, Theme.watchSpacingM)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .navigationTitle("All Exercises")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ExerciseLibraryView()
        .environment(WatchWorkoutViewModel(modelContext: PreviewHelper.previewContext))
}
