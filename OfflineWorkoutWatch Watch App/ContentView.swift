//
//  ContentView.swift
//  OfflineWorkoutWatch Watch App
//
//  Created by Dane Weickert on 9/22/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Main workout tab
            NavigationStack {
                ScrollView {
                    VStack(spacing: 10) {
                        // App Icon
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.orange)
                        
                        // App Title
                        Text("Offline Workout")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        // Start Workout Button
                        NavigationLink(destination: WorkoutSessionView()) {
                            HStack(spacing: 4) {
                                Image(systemName: "play.fill")
                                    .font(.caption2)
                                Text("Start Workout")
                                    .font(.caption)
                            }
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 34)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                }
                .navigationTitle("Workout")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "dumbbell")
                Text("Workout")
            }
            
            // Exercise library tab
            NavigationStack {
                VStack {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.orange)
                    
                    Text("Exercise Library")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text("Coming Soon")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Exercises")
            }
            
            // History tab
            WorkoutHistoryView()
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }
        }
    }
}

// Enhanced workout session view with exercise management
struct WorkoutSessionView: View {
    @State private var isWorkoutActive = false
    @State private var startTime = Date()
    @State private var timer: Timer?
    @State private var elapsedTime: TimeInterval = 0
    @State private var exercises: [WorkoutExercise] = []
    @State private var showingAddExercise = false
    @State private var showingEndWorkoutConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    // Timer Section
                    VStack(spacing: 2) {
                        Text(formattedTime)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.orange)
                        
                        Text("Workout Time")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    // Status
                    Text(isWorkoutActive ? "Workout in Progress" : "Ready to Start")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.bottom, 4)
                    
                    // Exercises Section
                    if !exercises.isEmpty {
                        VStack(spacing: 4) {
                            HStack {
                                Text("Exercises")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(exercises.count)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            
                            ForEach($exercises) { $exercise in
                                ExerciseRowView(exercise: $exercise)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 6) {
                        // Add Exercise Button (always available)
                        Button(action: { showingAddExercise = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.caption2)
                                Text("Add Exercise")
                                    .font(.caption)
                            }
                            .foregroundStyle(Color.orange)
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Start/End Workout Button
                        Button(action: {
                            if isWorkoutActive {
                                showingEndWorkoutConfirmation = true
                            } else {
                                toggleWorkout()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: isWorkoutActive ? "stop.fill" : "play.fill")
                                    .font(.caption2)
                                Text(isWorkoutActive ? "End Workout" : "Start Workout")
                                    .font(.caption)
                            }
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(isWorkoutActive ? Color.red : Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .navigationTitle("Workout")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView { exercise in
                    exercises.append(exercise)
                }
            }
            .confirmationDialog("End Workout", isPresented: $showingEndWorkoutConfirmation) {
                Button("End Workout", role: .destructive) {
                    endWorkout()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to end this workout?")
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    private var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func toggleWorkout() {
        // Start workout
        startTime = Date()
        elapsedTime = 0
        isWorkoutActive = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime = Date().timeIntervalSince(startTime)
        }
    }
    
    private func endWorkout() {
        // End workout
        timer?.invalidate()
        timer = nil
        isWorkoutActive = false
        
        // Save workout data (in a real app, this would save to SwiftData)
        let totalSets = exercises.reduce(0) { $0 + $1.sets.count }
        
        // Show completion feedback
        if !exercises.isEmpty {
            // In a real implementation, save to persistent storage here
            print("Workout completed: \(exercises.count) exercises, \(totalSets) sets, \(formattedTime)")
        }
        
        // Navigate back to main screen
        dismiss()
    }
}

// Simple workout exercise model for the session
struct WorkoutExercise: Identifiable {
    let id = UUID()
    let name: String
    var sets: [ExerciseSetData] = []
}

struct ExerciseSetData: Identifiable {
    let id = UUID()
    var reps: Int?
    var weight: Double?
    var duration: TimeInterval?
}

// Exercise row view for compact display
struct ExerciseRowView: View {
    @Binding var exercise: WorkoutExercise
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(exercise.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                    
                    Text("\(exercise.sets.count) sets")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(Color.orange.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            ExerciseDetailView(exercise: $exercise)
        }
    }
}

// Add exercise sheet view
struct AddExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var exerciseName = ""
    let onAdd: (WorkoutExercise) -> Void
    
    // Predefined exercise options
    private let commonExercises = [
        "Push-ups", "Pull-ups", "Squats", "Lunges", "Plank",
        "Burpees", "Jumping Jacks", "Mountain Climbers", "Sit-ups", "Deadlifts"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    // Custom exercise name input
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Custom Exercise")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        TextField("Exercise name", text: $exerciseName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        if !exerciseName.isEmpty {
                            Button("Add \"\(exerciseName)\"") {
                                addExercise(name: exerciseName)
                            }
                            .font(.caption)
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.bottom, 8)
                    
                    // Common exercises
                    Text("Common Exercises")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                        ForEach(commonExercises, id: \.self) { exercise in
                            Button(exercise) {
                                addExercise(name: exercise)
                            }
                            .font(.caption2)
                            .foregroundStyle(Color.orange)
                            .frame(maxWidth: .infinity)
                            .frame(height: 28)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .navigationTitle("Add Exercise")
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
    
    private func addExercise(name: String) {
        let exercise = WorkoutExercise(name: name)
        onAdd(exercise)
        dismiss()
    }
}

#Preview {
    ContentView()
}
