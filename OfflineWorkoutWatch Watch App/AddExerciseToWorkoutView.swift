import SwiftUI

/**
 * View for adding exercises to the current workout using the new step-by-step flow.
 */
struct AddExerciseToWorkoutView: View {
    var body: some View {
        NavigationStack {
            ExerciseSelectionMethodView()
        }
    }
}

// MARK: - Exercise Selection Row
struct ExerciseSelectionRow: View {
    let exercise: Exercise
    let setCount: Int
    let onSelect: () -> Void
    var filterType: FilterType? = nil
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                    
                    if !infoText.isEmpty {
                        HStack(spacing: 4) {
                            Text("•")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(infoText)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer(minLength: 4)
                
                Image(systemName: "plus.circle")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var infoText: String {
        switch filterType {
        case .goal:
            // When filtering by goal, only show body part
            return exercise.bodyPart?.rawValue.capitalized ?? "Unknown"
        case .bodyPart:
            // When filtering by body part, only show goal
            return exercise.goal?.rawValue.capitalized ?? "Unknown"
        case .combined:
            return ""
        case .none:
            // When not filtering, show both
            let bodyPart = exercise.bodyPart?.rawValue.capitalized ?? "Unknown"
            let goal = exercise.goal?.rawValue.capitalized ?? "Unknown"
            return "\(bodyPart) • \(goal)"
        }
    }
}

#Preview {
    AddExerciseToWorkoutView()
        .environment(WatchWorkoutViewModel(modelContext: PreviewHelper.previewContext))
}
