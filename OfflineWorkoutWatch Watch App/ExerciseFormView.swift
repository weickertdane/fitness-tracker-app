import SwiftUI

/**
 * Form for creating new exercises with guided tags and metric selection.
 */
struct ExerciseFormView: View {
    let onExerciseCreated: (Exercise) -> Void
    
    @Environment(WatchWorkoutViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var selectedGoal: Goal = .strength
    @State private var selectedBodyPart: BodyPart = .chest
    @State private var selectedMetrics: Set<MetricType> = [.reps, .weightLbs]
    @State private var showGoalPicker = false
    @State private var showBodyPartPicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Name Field - Full Screen Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Exercise Name")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextField("e.g., Push-ups", text: $name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled(false)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 12)
                .padding(.top, 16)
                .frame(minHeight: 120)
                
                Spacer()
                    .frame(height: 40)
                
                // Goal Selection - Button to navigate
                VStack(alignment: .leading, spacing: 8) {
                    Text("Goal")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Button(action: {
                        showGoalPicker = true
                    }) {
                        HStack {
                            Text(selectedGoal.rawValue.capitalized)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 12)
                
                Spacer()
                    .frame(height: 40)
                
                // Body Part Selection - Button to navigate
                VStack(alignment: .leading, spacing: 8) {
                    Text("Body Part")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Button(action: {
                        showBodyPartPicker = true
                    }) {
                        HStack {
                            Text(selectedBodyPart.rawValue.capitalized)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 12)
                
                Spacer()
                    .frame(height: 40)
                
                // Metrics Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Metrics")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 6) {
                        ForEach(MetricType.allCases, id: \.self) { metric in
                            MetricToggleRow(
                                metric: metric,
                                isSelected: selectedMetrics.contains(metric)
                            ) {
                                withAnimation(.none) {
                                    if selectedMetrics.contains(metric) {
                                        selectedMetrics.remove(metric)
                                    } else {
                                        selectedMetrics.insert(metric)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                
                // Create Button
                Button(action: createExercise) {
                    Text("Create")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(name.isEmpty ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .disabled(name.isEmpty)
                .padding(.horizontal, 12)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("New Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showGoalPicker) {
            GoalPickerView(selectedGoal: $selectedGoal)
        }
        .sheet(isPresented: $showBodyPartPicker) {
            BodyPartPickerView(selectedBodyPart: $selectedBodyPart)
        }
    }
    
    private func createExercise() {
        let exercise = viewModel.createExercise(
            name: name,
            goal: selectedGoal,
            bodyPart: selectedBodyPart,
            allowedMetrics: Array(selectedMetrics)
        )
        
        onExerciseCreated(exercise)
    }
}

struct MetricToggleRow: View {
    let metric: MetricType
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 8) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.body)
                    .foregroundColor(isSelected ? .green : .gray)
                    .imageScale(.medium)
                
                Text(metricDisplayName)
                    .font(.caption)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .contentShape(Rectangle())
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(isSelected ? Color.green.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    private var metricDisplayName: String {
        switch metric {
        case .reps: return "Reps"
        case .weightLbs: return "Weight"
        case .durationSeconds: return "Duration"
        case .distanceMeters: return "Distance"
        case .steps: return "Steps"
        case .pain: return "Pain"
        }
    }
}

// MARK: - Goal Picker View

struct GoalPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedGoal: Goal
    
    private var goalOrder: [Goal] {
        [.rehab, .strength, .hypertrophy, .cardio]
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(goalOrder, id: \.self) { goal in
                        Button(action: {
                            selectedGoal = goal
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: selectedGoal == goal ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedGoal == goal ? .green : .secondary)
                                
                                Text(goal.rawValue.capitalized)
                                    .font(.body)
                                
                                Spacer()
                            }
                            .padding()
                            .background(selectedGoal == goal ? Color.green.opacity(0.1) : Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Select Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.caption2)
                }
            }
        }
    }
}

// MARK: - Body Part Picker View

struct BodyPartPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedBodyPart: BodyPart
    
    private var bodyPartOrder: [BodyPart] {
        [.chest, .back, .shoulders, .biceps, .triceps, .abs, .quads, .hamstrings, .glutes, .calves, .other]
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(bodyPartOrder, id: \.self) { bodyPart in
                        Button(action: {
                            selectedBodyPart = bodyPart
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: selectedBodyPart == bodyPart ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedBodyPart == bodyPart ? .green : .secondary)
                                
                                Text(bodyPart.rawValue.capitalized)
                                    .font(.body)
                                
                                Spacer()
                            }
                            .padding()
                            .background(selectedBodyPart == bodyPart ? Color.green.opacity(0.1) : Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Select Body Part")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.caption2)
                }
            }
        }
    }
}

#Preview {
    ExerciseFormView { _ in }
        .environment(WatchWorkoutViewModel(modelContext: PreviewHelper.previewContext))
}
