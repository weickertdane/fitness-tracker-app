import SwiftUI

/**
 * Dynamic form for adding exercise sets with fields based on allowed metrics.
 */
struct AddSetFormView: View {
    let exercise: Exercise
    let prefillFromLastSet: Bool
    let editingSet: ExerciseSet?
    
    @Environment(WatchWorkoutViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    
    init(exercise: Exercise, prefillFromLastSet: Bool = false, editingSet: ExerciseSet? = nil) {
        self.exercise = exercise
        self.prefillFromLastSet = prefillFromLastSet
        self.editingSet = editingSet
    }
    
    private var isEditing: Bool {
        editingSet != nil
    }
    
    // Form State
    @State private var reps: String = ""
    @State private var weightLbs: String = ""
    @State private var isBodyweight: Bool = false
    @State private var durationMinutes: String = ""
    @State private var durationSeconds: String = ""
    @State private var distanceValue: String = ""
    @State private var distanceUnit: DistanceUnit = .meters
    @State private var steps: String = ""
    @State private var painLevel: Int = 1
    @State private var rangeOfMotion: Int = 5
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // Number pad states
    @State private var showingRepsNumberPad = false
    @State private var showingWeightNumberPad = false
    @State private var showingDurationMinutesNumberPad = false
    @State private var showingDurationSecondsNumberPad = false
    @State private var showingDistanceNumberPad = false
    @State private var showingStepsNumberPad = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Exercise Header
                exerciseHeader
                
                // Dynamic Form Fields
                VStack(spacing: 10) {
                    if exercise.allowedMetrics.contains(.reps) {
                        repsField
                    }
                    
                    if exercise.allowedMetrics.contains(.weightLbs) {
                        weightFields
                    }
                    
                    if exercise.allowedMetrics.contains(.durationSeconds) {
                        durationFields
                    }
                    
                    if exercise.allowedMetrics.contains(.distanceMeters) {
                        distanceField
                    }
                    
                    if exercise.allowedMetrics.contains(.steps) {
                        stepsField
                    }
                    
                    if exercise.allowedMetrics.contains(.pain) {
                        painField
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle(isEditing ? "Edit Set" : "Add Set")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .fontWeight(.medium)
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(isEditing ? "Update" : "Save") {
                    saveSet()
                }
                .font(.caption2)
                .fontWeight(.semibold)
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            if let editingSet = editingSet {
                prefillFromEditingSet(editingSet)
            } else if prefillFromLastSet {
                prefillFromPreviousSet()
            }
        }
    }
    
    // MARK: - Exercise Header
    
    private var exerciseHeader: some View {
        VStack(spacing: 2) {
            Text(exercise.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            HStack(spacing: 6) {
                HStack(spacing: 2) {
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(exercise.bodyPart?.rawValue.capitalized ?? "Unknown")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 2) {
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(exercise.goal?.rawValue.capitalized ?? "Unknown")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    // MARK: - Form Fields
    
    private var repsField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Reps")
                .font(.caption)
                .fontWeight(.medium)
            
            Button(action: {
                showingRepsNumberPad = true
            }) {
                HStack {
                    Text(reps.isEmpty ? "0" : reps)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "keyboard")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $showingRepsNumberPad) {
            NumberPadView(value: $reps) {
                showingRepsNumberPad = false
            }
        }
    }
    
    private var weightFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weight")
                .font(.caption)
                .fontWeight(.medium)
            
            Button(action: {
                showingWeightNumberPad = true
            }) {
                HStack {
                    if isBodyweight {
                        Text("BW")
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    } else {
                        Text(weightLbs.isEmpty ? "0" : weightLbs)
                            .foregroundColor(.primary)
                        
                        Text("lbs")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "keyboard")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $showingWeightNumberPad) {
            WeightNumberPadView(value: $weightLbs, isBodyweight: $isBodyweight) {
                showingWeightNumberPad = false
            }
        }
    }
    
    private var durationFields: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Duration")
                .font(.caption)
                .fontWeight(.medium)
            
            HStack(spacing: 6) {
                VStack(spacing: 2) {
                    Button(action: {
                        showingDurationMinutesNumberPad = true
                    }) {
                        HStack {
                            Text(durationMinutes.isEmpty ? "0" : durationMinutes)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "keyboard")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("min")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Text(":")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 2) {
                    Button(action: {
                        showingDurationSecondsNumberPad = true
                    }) {
                        HStack {
                            Text(durationSeconds.isEmpty ? "00" : durationSeconds)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "keyboard")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("sec")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: $showingDurationMinutesNumberPad) {
            NumberPadView(value: $durationMinutes) {
                showingDurationMinutesNumberPad = false
            }
        }
        .sheet(isPresented: $showingDurationSecondsNumberPad) {
            NumberPadView(value: $durationSeconds) {
                showingDurationSecondsNumberPad = false
            }
        }
    }
    
    private var distanceField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Distance")
                .font(.caption)
                .fontWeight(.medium)
            
            Button(action: {
                showingDistanceNumberPad = true
            }) {
                HStack {
                    Text(distanceValue.isEmpty ? "0" : distanceValue)
                        .foregroundColor(.primary)
                    
                    Text(distanceUnit.abbreviation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "keyboard")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(PlainButtonStyle())
            
            Picker("Unit", selection: $distanceUnit) {
                ForEach(DistanceUnit.allCases, id: \.self) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 100)
        }
        .sheet(isPresented: $showingDistanceNumberPad) {
            NumberPadView(value: $distanceValue, allowDecimal: true) {
                showingDistanceNumberPad = false
            }
        }
    }
    
    private var stepsField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Steps")
                .font(.caption)
                .fontWeight(.medium)
            
            Button(action: {
                showingStepsNumberPad = true
            }) {
                HStack {
                    Text(steps.isEmpty ? "0" : steps)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "keyboard")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $showingStepsNumberPad) {
            NumberPadView(value: $steps) {
                showingStepsNumberPad = false
            }
        }
    }
    
    private var painField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Pain Level")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(painLevel)/5")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Slider(value: Binding(
                get: { Double(painLevel) },
                set: { painLevel = Int($0) }
            ), in: 1...5, step: 1)
            .accentColor(painLevel <= 2 ? .green : painLevel <= 3 ? .orange : .red)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Actions
    
    private func saveSet() {
        // Check if there's an active workout first
        guard viewModel.isWorkoutActive else {
            errorMessage = "No active workout. Please start a workout first."
            showingError = true
            return
        }
        
        // Convert string inputs to proper types
        let repsValue = reps.isEmpty ? nil : Int(reps)
        let weightValue = (weightLbs.isEmpty || isBodyweight) ? nil : Double(weightLbs)
        let durationValue = calculateDurationSeconds()
        let distanceInMeters = calculateDistanceInMeters()
        let stepsValue = steps.isEmpty ? nil : Int(steps)
        let painValue = exercise.allowedMetrics.contains(.pain) ? painLevel : nil
        let romValue = exercise.goal == .rehab ? rangeOfMotion : nil
        
        // Validate that at least one metric is provided
        let hasMetrics = repsValue != nil || 
                        weightValue != nil || 
                        durationValue != nil || 
                        distanceInMeters != nil || 
                        stepsValue != nil || 
                        isBodyweight ||
                        painValue != nil
        
        guard hasMetrics else {
            errorMessage = "Please enter at least one metric for this set"
            showingError = true
            return
        }
        
        // Debug logging
        print("🔍 Attempting to save set:")
        print("  - Exercise: \(exercise.name)")
        print("  - Reps: \(repsValue?.description ?? "nil")")
        print("  - Weight: \(weightValue?.description ?? "nil")")
        print("  - Duration: \(durationValue?.description ?? "nil")")
        print("  - Distance: \(distanceInMeters?.description ?? "nil")")
        print("  - Steps: \(stepsValue?.description ?? "nil")")
        print("  - Bodyweight: \(isBodyweight)")
        print("  - Pain: \(painValue?.description ?? "nil")")
        
        // Add or update the set
        let success: Bool
        if let editingSet = editingSet {
            // Update existing set
            success = viewModel.updateSet(
                editingSet,
                reps: repsValue,
                weightLbs: weightValue,
                durationSeconds: durationValue,
                distanceMeters: distanceInMeters,
                steps: stepsValue,
                isBodyweight: isBodyweight,
                painLevel: painValue,
                rangeOfMotion: romValue
            )
        } else {
            // Add new set
            success = viewModel.addSet(
                exercise: exercise,
                reps: repsValue,
                weightLbs: weightValue,
                durationSeconds: durationValue,
                distanceMeters: distanceInMeters,
                steps: stepsValue,
                isBodyweight: isBodyweight,
                painLevel: painValue,
                rangeOfMotion: romValue
            )
        }
        
        if success {
            // Post notification to dismiss the add exercise flow
            NotificationCenter.default.post(name: NSNotification.Name("SetSavedSuccessfully"), object: nil)
            dismiss()
        } else {
            errorMessage = "Failed to \(isEditing ? "update" : "save") set. Check console for details."
            showingError = true
        }
    }
    
    private func calculateDurationSeconds() -> Int? {
        let minutes = Int(durationMinutes) ?? 0
        let seconds = Int(durationSeconds) ?? 0
        
        let totalSeconds = (minutes * 60) + seconds
        return totalSeconds > 0 ? totalSeconds : nil
    }
    
    private func calculateDistanceInMeters() -> Double? {
        guard let distance = Double(distanceValue), distance > 0 else { return nil }
        
        switch distanceUnit {
        case .meters:
            return distance
        case .kilometers:
            return distance * 1000
        case .miles:
            return distance * 1609.34
        }
    }
    
    private func prefillFromEditingSet(_ set: ExerciseSet) {
        // Pre-fill form fields with values from the editing set
        if let repsValue = set.reps {
            reps = String(repsValue)
        }
        
        if let weightValue = set.weightLbs {
            weightLbs = String(Int(weightValue))
        }
        
        isBodyweight = set.isBodyweight
        
        if let duration = set.durationSeconds {
            let minutes = duration / 60
            let seconds = duration % 60
            durationMinutes = minutes > 0 ? String(minutes) : ""
            durationSeconds = seconds > 0 ? String(seconds) : ""
        }
        
        if let distance = set.distanceMeters {
            distanceValue = String(Int(distance))
            // Keep default distance unit
        }
        
        if let stepsValue = set.steps {
            steps = String(stepsValue)
        }
        
        if let painValue = set.painLevel {
            painLevel = painValue
        }
        
        if let romValue = set.rangeOfMotion {
            rangeOfMotion = romValue
        }
    }
    
    private func prefillFromPreviousSet() {
        guard let lastSet = viewModel.getLastSet(for: exercise) else { return }
        
        // Pre-fill form fields with values from the last set
        if let repsValue = lastSet.reps {
            reps = String(repsValue)
        }
        
        if let weightValue = lastSet.weightLbs {
            weightLbs = String(Int(weightValue))
        }
        
        isBodyweight = lastSet.isBodyweight
        
        if let duration = lastSet.durationSeconds {
            let minutes = duration / 60
            let seconds = duration % 60
            durationMinutes = minutes > 0 ? String(minutes) : ""
            durationSeconds = seconds > 0 ? String(seconds) : ""
        }
        
        if let distance = lastSet.distanceMeters {
            distanceValue = String(Int(distance))
            // Keep default distance unit
        }
        
        if let stepsValue = lastSet.steps {
            steps = String(stepsValue)
        }
        
        if let painValue = lastSet.painLevel {
            painLevel = painValue
        }
        
        if let romValue = lastSet.rangeOfMotion {
            rangeOfMotion = romValue
        }
    }
}

#Preview {
    AddSetFormView(exercise: Exercise(
        name: "Push-ups",
        goal: .strength,
        bodyPart: .chest,
        allowedMetrics: [.reps, .weightLbs]
    ))
    .environment(WatchWorkoutViewModel(modelContext: PreviewHelper.previewContext))
}
