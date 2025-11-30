import SwiftUI

/**
 * View for filtering exercises by goal type and muscle group.
 */
struct ExerciseFilterView: View {
    @State private var showingGoalResults: Goal?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Goal Filter Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("By Goal")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        ForEach(Goal.allCases, id: \.self) { goal in
                            Button(action: {
                                showingGoalResults = goal
                            }) {
                                HStack {
                                    Image(systemName: goalIcon(for: goal))
                                        .font(.title2)
                                        .foregroundColor(goalColor(for: goal))
                                        .frame(width: 24)
                                    
                                    Text(goal.rawValue.capitalized)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(goalColor(for: goal).opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
            }
            .padding()
        }
        .navigationTitle("Filter")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $showingGoalResults) { goal in
            MuscleGroupFilterView(goal: goal)
        }
    }
    
    // MARK: - Helper Methods
    
    private func goalIcon(for goal: Goal) -> String {
        switch goal {
        case .strength:
            return "bolt.fill"
        case .rehab:
            return "heart.fill"
        case .cardio:
            return "figure.run"
        }
    }
    
    private func goalColor(for goal: Goal) -> Color {
        switch goal {
        case .strength:
            return .red
        case .rehab:
            return .purple
        case .cardio:
            return .blue
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseFilterView()
    }
}
