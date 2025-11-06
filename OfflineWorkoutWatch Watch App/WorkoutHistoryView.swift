//
//  WorkoutHistoryView.swift
//  OfflineWorkoutWatch Watch App
//
//  Created by Dane Weickert on 9/22/25.
//

import SwiftUI

/**
 * View for displaying workout history and completed sessions.
 */
struct WorkoutHistoryView: View {
    @State private var completedWorkouts: [CompletedWorkout] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if completedWorkouts.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        
                        Text("No workouts yet")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Text("Complete your first workout to see it here")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 20)
                } else {
                    LazyVStack(spacing: 6) {
                        ForEach(completedWorkouts) { workout in
                            WorkoutHistoryRowView(workout: workout)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/**
 * Individual row for displaying completed workout information.
 */
struct WorkoutHistoryRowView: View {
    let workout: CompletedWorkout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(workout.date, style: .date)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(formatDuration(workout.duration))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text("\(workout.exerciseCount) exercises")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(workout.totalSets) sets")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.orange.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

/**
 * Model for completed workout data.
 */
struct CompletedWorkout: Identifiable {
    let id = UUID()
    let date: Date
    let duration: TimeInterval
    let exerciseCount: Int
    let totalSets: Int
    let exercises: [WorkoutExercise]
}

#Preview {
    WorkoutHistoryView()
}
