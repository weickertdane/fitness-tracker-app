import SwiftUI

/**
 * Settings screen for configuring app behavior and feature toggles.
 * Clearly displays HealthKit integration per App Store Guideline 2.5.1.
 */
struct SettingsView: View {
    @AppStorage("enableHealthKit") private var enableHealthKit = false
    @AppStorage("showAdvancedMetrics") private var showAdvancedMetrics = true
    @Environment(\.dismiss) private var dismiss
    @State private var healthKitManager = HealthKitManager.shared
    @State private var showingHealthKitInfo = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Apple Health Integration Section - REQUIRED for App Store
                Section {
                    // Status Row
                    HStack {
                        Image(systemName: "heart.text.square.fill")
                            .foregroundStyle(.red)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Apple Health Integration")
                                .font(.headline)
                            
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(statusColor)
                                    .frame(width: 8, height: 8)
                                
                                Text(statusText)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    
                    // Enable/Authorize Button
                    if healthKitManager.isHealthKitAvailable {
                        Button(action: requestHealthKitPermission) {
                            HStack {
                                Image(systemName: healthKitManager.authorizationStatus == .authorized ? "checkmark.circle.fill" : "heart.fill")
                                Text(healthKitManager.authorizationStatus == .authorized ? "Authorized" : "Enable Health Integration")
                                Spacer()
                                if healthKitManager.authorizationStatus != .authorized {
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .disabled(healthKitManager.authorizationStatus == .authorized)
                    }
                    
                    // What's Accessed
                    Button(action: { showingHealthKitInfo = true }) {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("About Health Integration")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        }
                } header: {
                    Text("Health Integration")
                } footer: {
                    Text("OfflineWorkout integrates with Apple Health to save your workout data. Tap 'About Health Integration' to learn what data is accessed and why.")
                }
                
                // Display Options Section
                Section {
                    Toggle("Show Advanced Metrics", isOn: $showAdvancedMetrics)
                } header: {
                    Text("Display Options")
                } footer: {
                    Text("When disabled, distance and steps metrics are hidden unless specifically allowed by the exercise.")
                }
                
                // About Section
                Section {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(Theme.secondaryText)
                    }
                    
                    HStack {
                        Text("Schema Version")
                        Spacer()
                        Text("v\(Persistence.SCHEMA_VERSION)")
                            .foregroundStyle(Theme.secondaryText)
                    }
                } header: {
                    Text("About")
                }
                
                // Debug Section (for development)
                #if DEBUG
                Section {
                    Button("Validate Configuration") {
                        Persistence.validateConfiguration()
                    }
                    
                    Button("Simulate Sync") {
                        CloudKitSyncStatus.shared.simulateSync()
                    }
                } header: {
                    Text("Debug")
                } footer: {
                    Text("Development tools - not visible in production builds.")
                }
                #endif
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
            .sheet(isPresented: $showingHealthKitInfo) {
                HealthKitInfoDetailView()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var statusColor: Color {
        switch healthKitManager.authorizationStatus {
        case .authorized:
            return .green
        case .denied:
            return .red
        case .notDetermined:
            return .orange
        case .notSupported:
            return .gray
        }
    }
    
    private var statusText: String {
        if !healthKitManager.isHealthKitAvailable {
            return "Not Available"
        }
        
        switch healthKitManager.authorizationStatus {
        case .authorized:
            return "Connected to Apple Health"
        case .denied:
            return "Access Denied"
        case .notDetermined:
            return "Not Set Up"
        case .notSupported:
            return "Not Supported"
        }
    }
    
    // MARK: - Private Methods
    
    private func requestHealthKitPermission() {
        Task {
            // Enable HealthKit first
            healthKitManager.isEnabled = true
            
            // Request authorization
            let granted = await healthKitManager.requestAuthorization()
            
            if granted {
                print("✅ HealthKit authorization granted")
        } else {
                print("❌ HealthKit authorization denied or not determined")
            }
        }
    }
}

/**
 * Detailed information view about HealthKit integration for iOS.
 * Provides transparency about what data is accessed and why.
 */
struct HealthKitInfoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.red)
                        
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    // What We Access
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What We Access")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HealthDataCard(
                            icon: "figure.strengthtraining.traditional",
                            title: "Workout Sessions",
                            description: "Your completed workouts are saved to Apple Health for a complete fitness history."
                        )
                        
                        HealthDataCard(
                            icon: "chart.bar.fill",
                            title: "Exercise Metrics",
                            description: "Reps, sets, weight, and duration are recorded for each exercise you perform."
                        )
                        
                        HealthDataCard(
                            icon: "ruler",
                            title: "Distance & Steps",
                            description: "For cardio workouts, distance and step counts are tracked and saved."
                        )
                    }
                    
                    Divider()
                    
                    // Why We Need It
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Why We Need It")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("OfflineWorkout integrates with Apple Health to provide you with a unified view of your fitness activity. Your workout data is securely stored in the Health app and can be shared with other health and fitness apps you trust.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                    
                    // Privacy
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Privacy")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            PrivacyPoint(
                                icon: "lock.shield.fill",
                                text: "Your health data is encrypted and stored securely on your device"
                            )
                            
                            PrivacyPoint(
                                icon: "icloud.slash.fill",
                                text: "We never send your health data to external servers"
                            )
                            
                            PrivacyPoint(
                                icon: "hand.raised.fill",
                                text: "You can revoke access at any time in the Health app settings"
                            )
                        }
                    }
                }
                .padding(24)
            }
            .navigationTitle("Health Integration")
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

struct HealthDataCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(Theme.accentColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct PrivacyPoint: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.accentColor)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SettingsView()
}
