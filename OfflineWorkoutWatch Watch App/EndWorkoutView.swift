import SwiftUI

/**
 * Confirmation view for ending the current workout.
 */
struct EndWorkoutView: View {
    @Environment(WatchWorkoutViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Workout Summary Icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                
                // Title
                Text("End Workout?")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                // Workout Summary
                if let workout = viewModel.currentWorkout {
                    VStack(spacing: 8) {
                        Text("Duration: \(formatDuration(workout.durationSeconds))")
                            .font(.headline)
                        
                        Text("\(workout.sets?.count ?? 0) sets completed")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(viewModel.exerciseGroups.count) exercises")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // HealthKit Integration Indicator - REQUIRED for App Store compliance
                healthKitIndicator
                
                // Action Buttons
                VStack(spacing: 12) {
                    // End Workout Button
                    Button(action: {
                        viewModel.endWorkout()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("End Workout")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                    }
                    
                    // Continue Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Continue Workout")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                    }
                }
            }
            .padding()
            .navigationTitle("Finish")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - HealthKit Indicator
    
    /// Displays Apple Health integration status - required for App Store Guideline 2.5.1
    private var healthKitIndicator: some View {
        HStack(spacing: 6) {
            Image(systemName: "heart.text.square.fill")
                .font(.caption)
                .foregroundStyle(.red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Apple Health Integration")
                    .font(.caption2)
                    .fontWeight(.semibold)
                
                if HealthKitManager.shared.isEnabled && HealthKitManager.shared.authorizationStatus == .authorized {
                    Text("Workout will be saved to Health")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                } else {
                    Text("Enable in Settings to sync with Health")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}

#Preview {
    EndWorkoutView()
        .environment(WatchWorkoutViewModel(modelContext: PreviewHelper.previewContext))
}