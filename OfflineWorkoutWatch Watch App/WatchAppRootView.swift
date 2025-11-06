import SwiftUI

/**
 * Root view for the Apple Watch app with workout flow integration.
 */
struct WatchAppRootView: View {
    @Environment(WatchWorkoutViewModel.self) private var viewModel
    
    var body: some View {
        TabView {
            // Main workout tab
            NavigationStack {
                if viewModel.isWorkoutActive {
                    // Show active workout view
                    ActiveWorkoutView()
                } else {
                    // Show start workout view with ongoing workout indicator
                    StartWorkoutView()
                }
            }
            .tabItem {
                Image(systemName: "figure.strengthtraining.traditional")
                Text("Workout")
            }
            
            // Exercise library tab
            NavigationStack {
                ExerciseLibraryView()
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Exercises")
            }
            
            // Settings tab - REQUIRED for App Store (shows HealthKit integration)
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
        }
    }
}

#Preview {
    WatchAppRootView()
        .environment(WatchWorkoutViewModel(modelContext: PreviewHelper.previewContext))
}
