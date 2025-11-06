import SwiftUI

/**
 * Initial view for starting a new workout on Apple Watch.
 */
struct StartWorkoutView: View {
    @Environment(WatchWorkoutViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isWorkoutActive {
                    // Active workout layout
                    VStack(spacing: Theme.watchSpacingL) {
                        // Workout Icon
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 50))
                            .foregroundStyle(Theme.warningColor)
                        
                        // Title and Status
                        VStack(spacing: Theme.watchSpacingS) {
                            Text("Workout Active")
                                .font(Theme.titleFont)
                                .foregroundStyle(Theme.warningColor)
                            
                            Text(workoutDuration)
                                .font(Theme.headlineFont)
                                .foregroundStyle(Theme.primaryText)
                            
                            Text("Continue your workout")
                                .font(Theme.watchCaptionFont)
                                .foregroundStyle(Theme.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        
                        Spacer()
                        
                        // Continue Button
                        NavigationLink(destination: ActiveWorkoutView()) {
                            HStack {
                                Image(systemName: "arrow.right")
                                Text("Continue")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.warningColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusS))
                            .accessibleButton(
                                label: "Continue Workout",
                                hint: "Return to your active workout"
                            )
                        }
                    }
                } else {
                    // Start workout layout - vertically centered
                    Spacer()
                    
                    VStack(spacing: Theme.watchSpacingL) {
                        // Workout Icon
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 50))
                            .foregroundStyle(Theme.accentColor)
                        
                        // Start Button
                        NavigationLink(destination: ActiveWorkoutView()) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start")
                            }
                            .font(Theme.buttonFont)
                            .accessibleButton(
                                label: "Start Workout", 
                                hint: "Begin tracking your workout"
                            )
                        }
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                viewModel.startWorkout()
                            }
                        )
                        
                        // HealthKit Integration Badge - REQUIRED for App Store compliance
                        healthKitBadge
                    }
                    
                    Spacer()
                }
            }
            .padding(Theme.spacingM)
            .navigationTitle("Workout")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var workoutDuration: String {
        guard let workout = viewModel.currentWorkout else { return "00:00" }
        let duration = workout.durationSeconds
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - HealthKit Badge
    
    /// Small badge indicating Apple Health integration - required for App Store Guideline 2.5.1
    private var healthKitBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 10))
                .foregroundStyle(.red)
            
            Text("Integrates with Apple Health")
                .font(.system(size: 9))
                .foregroundStyle(Theme.secondaryText)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.2))
        .clipShape(Capsule())
    }
}

#Preview {
    StartWorkoutView()
        .environment(WatchWorkoutViewModel(modelContext: PreviewHelper.previewContext))
}
