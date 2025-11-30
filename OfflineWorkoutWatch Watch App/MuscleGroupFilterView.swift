import SwiftUI

/**
 * View for selecting a muscle group after a goal has been selected.
 */
struct MuscleGroupFilterView: View {
    let goal: Goal
    @State private var selectedBodyPart: BodyPart?
    @State private var showAllExercises = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // "All [Goal] Exercises" Option
                Button(action: {
                    showAllExercises = true
                }) {
                    HStack {
                        Image(systemName: "list.bullet")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("All \(goal.rawValue.capitalized)")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .padding(.vertical, 8)
                
                Text("By Muscle Group")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Muscle Group List
                VStack(spacing: 8) {
                    ForEach(BodyPart.allCases.sorted { $0.rawValue < $1.rawValue }, id: \.self) { bodyPart in
                        Button(action: {
                            selectedBodyPart = bodyPart
                        }) {
                            HStack {
                                Text(bodyPart.rawValue.capitalized)
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Muscle Group")
        .navigationDestination(isPresented: $showAllExercises) {
            FilteredExerciseListView(filterType: .goal(goal))
        }
        .navigationDestination(item: $selectedBodyPart) { bodyPart in
            FilteredExerciseListView(filterType: .combined(goal, bodyPart))
        }
    }
}

#Preview {
    NavigationStack {
        MuscleGroupFilterView(goal: .strength)
    }
}
