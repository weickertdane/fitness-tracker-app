import SwiftUI

/**
 * Wrapper view for the create exercise workflow that handles the completion flow.
 */
struct CreateExerciseWorkflowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(WatchWorkoutViewModel.self) private var viewModel
    @State private var showingAddSetFor: Exercise?
    @State private var exerciseCreated = false
    
    var body: some View {
        ExerciseFormView { exercise in
            // Check if workout is still active before proceeding
            guard viewModel.isWorkoutActive else {
                print("❌ Workout is no longer active, dismissing exercise creation flow")
                dismiss()
                return
            }
            
            // Add the newly created exercise to the workout
            let success = viewModel.addExerciseToWorkout(exercise)
            
            // Only show add set form if exercise was successfully added
            if success {
                exerciseCreated = true
                showingAddSetFor = exercise
            } else {
                print("❌ Failed to add exercise to workout, dismissing flow")
                dismiss()
            }
        }
        .navigationDestination(item: $showingAddSetFor) { exercise in
            AddSetFormView(exercise: exercise)
                .onDisappear {
                    // When user navigates back from AddSetForm, dismiss the entire create flow
                    if exerciseCreated {
                        // Small delay to let navigation complete before dismissing sheet
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    NavigationStack {
        CreateExerciseWorkflowView()
            .environment(WatchWorkoutViewModel(modelContext: PreviewHelper.previewContext))
    }
}
