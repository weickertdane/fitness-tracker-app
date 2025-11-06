import SwiftUI

/**
 * Initial view for selecting whether to create a new exercise or choose from existing ones.
 */
struct ExerciseSelectionMethodView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingNewExercise = false
    @State private var showingExistingOptions = false
    
    var body: some View {
        VStack(spacing: 16) {
                Spacer()
                
                // Selection Buttons
                VStack(spacing: 16) {
                    // Existing Exercise Button
                    Button(action: {
                        showingExistingOptions = true
                    }) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Existing")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // New Exercise Button
                    Button(action: {
                        showingNewExercise = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("New")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
        }
        .padding(.horizontal)
        .navigationTitle("Add Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .font(.caption2)
            }
        }
        .navigationDestination(isPresented: $showingExistingOptions) {
            ExistingExerciseOptionsView()
        }
        .navigationDestination(isPresented: $showingNewExercise) {
            CreateExerciseWorkflowView()
        }
    }
}

#Preview {
    ExerciseSelectionMethodView()
}
