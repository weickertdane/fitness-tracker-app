//
//  ExerciseDetailView.swift
//  OfflineWorkoutWatch Watch App
//
//  Created by Dane Weickert on 9/22/25.
//

import SwiftUI

/**
 * Detailed view for managing sets within an exercise during a workout.
 */
struct ExerciseDetailView: View {
    @Binding var exercise: WorkoutExercise
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddSet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    // Exercise name
                    Text(exercise.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 4)
                    
                    // Sets section
                    if exercise.sets.isEmpty {
                        VStack(spacing: 4) {
                            Image(systemName: "dumbbell")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                            
                            Text("No sets yet")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            Text("Tap + to add your first set")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 12)
                    } else {
                        VStack(spacing: 4) {
                            HStack {
                                Text("Sets")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(exercise.sets.count)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            
                            ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                                SetRowView(setNumber: index + 1, set: set)
                            }
                        }
                    }
                    
                    // Add set button
                    Button(action: { showingAddSet = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.caption2)
                            Text("Add Set")
                                .font(.caption)
                        }
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .navigationTitle("Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.caption)
                }
            }
            .sheet(isPresented: $showingAddSet) {
                AddSetView { newSet in
                    exercise.sets.append(newSet)
                }
            }
        }
    }
}

/**
 * View for displaying individual set information.
 */
struct SetRowView: View {
    let setNumber: Int
    let set: ExerciseSetData
    
    var body: some View {
        HStack {
            // Set number
            Text("\(setNumber)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.orange)
                .frame(width: 20)
            
            // Set details
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 8) {
                    if let reps = set.reps {
                        Text("\(reps) reps")
                            .font(.caption2)
                    }
                    
                    if let weight = set.weight {
                        Text("\(Int(weight)) lbs")
                            .font(.caption2)
                    }
                    
                    if let duration = set.duration {
                        Text(formatDuration(duration))
                            .font(.caption2)
                    }
                }
                .foregroundStyle(.primary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Color.orange.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        
        if minutes > 0 {
            return "\(minutes):\(String(format: "%02d", seconds))"
        } else {
            return "\(seconds)s"
        }
    }
}

/**
 * Sheet view for adding a new set to an exercise.
 */
struct AddSetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var reps: String = ""
    @State private var weight: String = ""
    @State private var duration: String = ""
    @State private var selectedMetric: SetMetric = .repsWeight
    
    let onAdd: (ExerciseSetData) -> Void
    
    enum SetMetric: CaseIterable {
        case repsWeight
        case repsOnly
        case duration
        
        var title: String {
            switch self {
            case .repsWeight: return "Reps + Weight"
            case .repsOnly: return "Reps Only"
            case .duration: return "Duration"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    // Metric selector
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Set Type")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        Picker("Metric", selection: $selectedMetric) {
                            ForEach(SetMetric.allCases, id: \.self) { metric in
                                Text(metric.title)
                                    .font(.caption2)
                                    .tag(metric)
                            }
                        }
                        .frame(height: 80)
                    }
                    .padding(.bottom, 4)
                    
                    // Input fields based on selected metric
                    VStack(spacing: 6) {
                        switch selectedMetric {
                        case .repsWeight:
                            HStack(spacing: 6) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Reps")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    TextField("12", text: $reps)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Weight (lbs)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    TextField("135", text: $weight)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                            }
                            
                        case .repsOnly:
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Reps")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                TextField("20", text: $reps)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            
                        case .duration:
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Duration (seconds)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                TextField("60", text: $duration)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                    }
                    
                    // Add button
                    Button("Add Set") {
                        addSet()
                    }
                    .font(.caption)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(canAddSet ? Color.orange : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!canAddSet)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .navigationTitle("Add Set")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.caption)
                }
            }
        }
    }
    
    private var canAddSet: Bool {
        switch selectedMetric {
        case .repsWeight:
            return !reps.isEmpty && !weight.isEmpty
        case .repsOnly:
            return !reps.isEmpty
        case .duration:
            return !duration.isEmpty
        }
    }
    
    private func addSet() {
        var newSet = ExerciseSetData()
        
        switch selectedMetric {
        case .repsWeight:
            newSet.reps = Int(reps)
            newSet.weight = Double(weight)
        case .repsOnly:
            newSet.reps = Int(reps)
        case .duration:
            newSet.duration = TimeInterval(Int(duration) ?? 0)
        }
        
        onAdd(newSet)
        dismiss()
    }
}

#Preview {
    @State var sampleExercise = WorkoutExercise(name: "Push-ups")
    return ExerciseDetailView(exercise: $sampleExercise)
}
