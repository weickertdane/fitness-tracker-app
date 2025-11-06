import SwiftUI

/**
 * View for choosing between search and filter options when selecting existing exercises.
 */
struct ExistingExerciseOptionsView: View {
    @Environment(WatchWorkoutViewModel.self) private var viewModel
    @State private var showingSearch = false
    @State private var showingFilter = false
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
                .frame(height: 20)
            
            // Option Buttons
            VStack(spacing: 16) {
                // Search Button
                Button(action: {
                    showingSearch = true
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                        
                        Text("Search")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PlainButtonStyle())
                
                // Filter Button
                Button(action: {
                    showingFilter = true
                }) {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title2)
                        
                        Text("Filter")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Exercise count info
            if !viewModel.availableExercises.isEmpty {
                Text("\(viewModel.availableExercises.count) exercises")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showingSearch) {
            ExerciseSearchView()
        }
        .navigationDestination(isPresented: $showingFilter) {
            ExerciseFilterView()
        }
    }
}

#Preview {
    NavigationStack {
        ExistingExerciseOptionsView()
            .environment(WatchWorkoutViewModel(modelContext: PreviewHelper.previewContext))
    }
}
