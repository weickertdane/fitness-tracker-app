import SwiftUI
import SwiftData

/**
 * Form for creating and editing exercises on iPhone.
 */
struct ExerciseFormView: View {
    let exerciseToEdit: Exercise?
    let onSave: (Exercise) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var selectedGoal: Goal
    @State private var selectedBodyPart: BodyPart
    @State private var muscles: String
    @State private var selectedMetrics: Set<MetricType>
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(exerciseToEdit: Exercise?, onSave: @escaping (Exercise) -> Void) {
        self.exerciseToEdit = exerciseToEdit
        self.onSave = onSave
        
        if let exercise = exerciseToEdit {
            self._name = State(initialValue: exercise.name)
            self._selectedGoal = State(initialValue: exercise.goal ?? .strength)
            self._selectedBodyPart = State(initialValue: exercise.bodyPart ?? .other)
            self._muscles = State(initialValue: exercise.muscles.joined(separator: ", "))
            self._selectedMetrics = State(initialValue: Set(exercise.allowedMetrics))
        } else {
            self._name = State(initialValue: "")
            self._selectedGoal = State(initialValue: .strength)
            self._selectedBodyPart = State(initialValue: .chest)
            self._muscles = State(initialValue: "")
            self._selectedMetrics = State(initialValue: [.reps, .weightLbs])
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Exercise Name
                Section("Exercise Name") {
                    TextField("e.g., Push-ups", text: $name)
                }
                
                // Goal Selection
                Section("Goal") {
                    Picker("Goal", selection: $selectedGoal) {
                        ForEach(Goal.allCases, id: \.self) { goal in
                            Text(goal.rawValue.capitalized).tag(goal)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Body Part Selection
                Section("Body Part") {
                    Picker("Body Part", selection: $selectedBodyPart) {
                        ForEach(BodyPart.allCases, id: \.self) { bodyPart in
                            Text(bodyPart.rawValue.capitalized).tag(bodyPart)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                
                // Muscles (Optional)
                Section {
                    TextField("e.g., Pectorals, Triceps", text: $muscles)
                } header: {
                    Text("Muscles (Optional)")
                } footer: {
                    Text("Separate multiple muscles with commas")
                }
                
                // Allowed Metrics
                Section {
                    ForEach(availableMetrics, id: \.self) { metric in
                        HStack {
                            Button(action: {
                                if selectedMetrics.contains(metric) {
                                    selectedMetrics.remove(metric)
                                } else {
                                    selectedMetrics.insert(metric)
                                }
                            }) {
                                HStack {
                                    Image(systemName: selectedMetrics.contains(metric) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedMetrics.contains(metric) ? .green : .gray)
                                    
                                    Text(metricDisplayName(metric))
                                        .foregroundColor(.primary)
                                    
                                    // Advanced metrics are always shown in this simplified version
                                    
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                } header: {
                    Text("Allowed Metrics")
                } footer: {
                    Text("Select which metrics can be tracked for this exercise")
                }
            }
            .navigationTitle(exerciseToEdit == nil ? "New Exercise" : "Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExercise()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty || selectedMetrics.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var availableMetrics: [MetricType] {
        return MetricType.allCases
    }
    
    private func isAdvancedMetric(_ metric: MetricType) -> Bool {
        switch metric {
        case .distanceMeters, .steps, .avgPace:
            return true
        case .reps, .weightLbs, .durationSeconds, .pain:
            return false
        }
    }
    
    private func metricDisplayName(_ metric: MetricType) -> String {
        switch metric {
        case .reps: return "Reps"
        case .weightLbs: return "Weight (lbs)"
        case .durationSeconds: return "Duration"
        case .distanceMeters: return "Distance"
        case .avgPace: return "Avg. Pace"
        case .steps: return "Steps"
        case .pain: return "Pain Level"
        }
    }
    
    private func saveExercise() {
        guard !name.isEmpty else {
            errorMessage = "Exercise name is required"
            showingError = true
            return
        }
        
        guard !selectedMetrics.isEmpty else {
            errorMessage = "At least one metric must be selected"
            showingError = true
            return
        }
        
        let muscleList = muscles.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        
        if let exerciseToEdit = exerciseToEdit {
            // Update existing exercise (simplified)
            exerciseToEdit.name = name
            exerciseToEdit.goal = selectedGoal
            exerciseToEdit.bodyPart = selectedBodyPart
            exerciseToEdit.muscles = muscleList
            exerciseToEdit.allowedMetrics = Array(selectedMetrics)
            onSave(exerciseToEdit)
        } else {
            // Create new exercise (simplified)
            let newExercise = Exercise(
                name: name,
                goal: selectedGoal,
                bodyPart: selectedBodyPart,
                muscles: muscleList,
                allowedMetrics: Array(selectedMetrics)
            )
            onSave(newExercise)
        }
        
        dismiss()
    }
}


#Preview {
    ExerciseFormView(exerciseToEdit: nil) { _ in }
}