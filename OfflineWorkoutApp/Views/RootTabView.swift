import SwiftUI
import SwiftData
import Foundation

/**
 * Root tab view for the iPhone app with History, Exercises, and Settings tabs.
 * Note: Workouts can only be created and managed on Apple Watch.
 */
struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingSettings = false
    @State private var historyViewModel: HistoryViewModel?
    @State private var exerciseViewModel: ExerciseLibraryViewModel?
    
    var body: some View {
        TabView {
            // History Tab
            Group {
                if let viewModel = historyViewModel {
                    HistoryCalendarView()
                        .environment(viewModel)
                } else {
                    ProgressView("Loading...")
                }
            }
            .tabItem {
                Label("History", systemImage: "calendar")
            }
            
            // Exercises Tab
            Group {
                if let viewModel = exerciseViewModel {
                    ExerciseLibraryView()
                        .environment(viewModel)
                } else {
                    ProgressView("Loading...")
                }
            }
            .tabItem {
                Label("Exercises", systemImage: "dumbbell")
            }
            
            // Settings Tab - REQUIRED for App Store (shows HealthKit integration)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            initializeViewModels()
            print("✅ RootTabView appeared")
        }
    }
    
    private func initializeViewModels() {
        if historyViewModel == nil {
            historyViewModel = HistoryViewModel(modelContext: modelContext)
        }
        if exerciseViewModel == nil {
            exerciseViewModel = ExerciseLibraryViewModel(modelContext: modelContext)
        }
    }
}

/**
 * Placeholder view for Workouts tab - workouts can only be created/edited on Apple Watch.
 */
struct WorkoutsPlaceholderView: View {
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "applewatch")
                    .font(.system(size: 70))
                    .foregroundColor(.orange)
                
                VStack(spacing: 12) {
                    Text("Workouts on Apple Watch")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Start, track, and manage your workouts directly on your Apple Watch")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(
                        icon: "plus.circle.fill",
                        title: "Create Workouts",
                        description: "Start new workout sessions"
                    )
                    
                    FeatureRow(
                        icon: "pencil.circle.fill",
                        title: "Track Sets",
                        description: "Log reps, weight, and metrics"
                    )
                    
                    FeatureRow(
                        icon: "checkmark.circle.fill",
                        title: "End Workouts",
                        description: "Complete and save your sessions"
                    )
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)
                
                Spacer()
                
                Text("View your workout history in the History tab")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 16)
            }
            .padding(.top, 40)
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SimpleSettingsView()
            }
        }
    }
}

/**
 * Row displaying a feature with icon and description.
 */
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

/**
 * Simplified settings view that doesn't depend on complex shared models.
 */
struct SimpleSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("enableHealthKit") private var enableHealthKit = false
    @AppStorage("showAdvancedMetrics") private var showAdvancedMetrics = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Enable HealthKit", isOn: $enableHealthKit)
                } header: {
                    Text("Health Integration")
                } footer: {
                    Text("HealthKit integration is currently dormant.")
                }
                
                Section {
                    Toggle("Show Advanced Metrics", isOn: $showAdvancedMetrics)
                } header: {
                    Text("Display Options")
                }
                
                Section {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RootTabView()
}

