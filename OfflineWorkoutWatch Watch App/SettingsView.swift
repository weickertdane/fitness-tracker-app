import SwiftUI

/**
 * Settings view for Apple Watch app with clear HealthKit integration information.
 * This view satisfies App Store Guideline 2.5.1 by clearly identifying HealthKit functionality.
 */
struct SettingsView: View {
    @State private var healthKitManager = HealthKitManager.shared
    @State private var showingHealthKitInfo = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.watchSpacingM) {
                // App Info Section
                appInfoSection
                
                // HealthKit Section - REQUIRED for App Store approval
                healthKitSection
            }
            .padding(Theme.spacingM)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingHealthKitInfo) {
            HealthKitInfoView()
        }
    }
    
    // MARK: - App Info Section
    
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: Theme.watchSpacingS) {
            Text("About")
                .font(Theme.headlineFont)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                InfoRow(label: "Version", value: "1.0")
                InfoRow(label: "App", value: "OfflineWorkout")
            }
            .padding(Theme.watchSpacingS)
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusS))
        }
    }
    
    // MARK: - HealthKit Section
    
    private var healthKitSection: some View {
        VStack(alignment: .leading, spacing: Theme.watchSpacingS) {
            HStack(spacing: 6) {
                Image(systemName: "heart.text.square.fill")
                    .foregroundStyle(.red)
                    .font(.title3)
                
                Text("Apple Health Integration")
                    .font(Theme.headlineFont)
                    .fontWeight(.bold)
            }
            
            VStack(spacing: 10) {
                // Status Card
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Status")
                            .font(Theme.watchCaptionFont)
                            .foregroundStyle(Theme.secondaryText)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 8, height: 8)
                            
                            Text(statusText)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Spacer()
                    
                    if healthKitManager.isHealthKitAvailable {
                        Button(action: requestHealthKitPermission) {
                            Text(healthKitManager.authorizationStatus == .authorized ? "Authorized" : "Enable")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(healthKitManager.authorizationStatus == .authorized ? Color.green : Theme.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(healthKitManager.authorizationStatus == .authorized)
                    }
                }
                .padding(Theme.watchSpacingS)
                .background(Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusS))
                
                // Data Access Information
                VStack(alignment: .leading, spacing: 8) {
                    Text("Health Data Access")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    HealthDataItem(icon: "figure.strengthtraining.traditional", 
                                 text: "Workout data")
                    HealthDataItem(icon: "chart.bar.fill", 
                                 text: "Exercise metrics")
                    HealthDataItem(icon: "arrow.up.heart.fill", 
                                 text: "Activity tracking")
                }
                .padding(Theme.watchSpacingS)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusS))
                
                // Learn More Button
                Button(action: { showingHealthKitInfo = true }) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("About Health Integration")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Theme.accentColor.opacity(0.15))
                    .foregroundStyle(Theme.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusS))
                }
                .buttonStyle(PlainButtonStyle())
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
            return "Connected"
        case .denied:
            return "Access Denied"
        case .notDetermined:
            return "Not Set Up"
        case .notSupported:
            return "Not Supported"
        }
    }
    
    // MARK: - Actions
    
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

// MARK: - Supporting Views

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(Theme.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct HealthDataItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Theme.accentColor)
                .frame(width: 20)
            
            Text(text)
                .font(.caption2)
            
            Spacer()
        }
    }
}

/**
 * Detailed information view about HealthKit integration.
 * Provides transparency about what data is accessed and why.
 */
struct HealthKitInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.watchSpacingM) {
                    // Header
                    HStack {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.red)
                        
                        Spacer()
                    }
                    .padding(.bottom, Theme.watchSpacingS)
                    
                    // What We Access
                    SectionHeader(text: "What We Access")
                    
                    InfoCard(
                        icon: "figure.strengthtraining.traditional",
                        title: "Workout Sessions",
                        description: "Your completed workouts are saved to Apple Health for a complete fitness history."
                    )
                    
                    InfoCard(
                        icon: "chart.bar.fill",
                        title: "Exercise Metrics",
                        description: "Reps, sets, weight, and duration are recorded for each exercise."
                    )
                    
                    InfoCard(
                        icon: "ruler",
                        title: "Distance & Steps",
                        description: "For cardio workouts, distance and step counts are tracked."
                    )
                    
                    // Why We Need It
                    SectionHeader(text: "Why We Need It")
                    
                    Text("OfflineWorkout integrates with Apple Health to provide you with a unified view of your fitness activity. Your workout data is securely stored in the Health app and can be shared with other health and fitness apps you trust.")
                        .font(.caption2)
                        .foregroundStyle(Theme.secondaryText)
                        .padding(Theme.watchSpacingS)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusS))
                    
                    // Privacy
                    SectionHeader(text: "Your Privacy")
                    
                    Text("Your health data is encrypted and stored securely on your device. We never send your health data to external servers. You can revoke access at any time in the Health app settings.")
                        .font(.caption2)
                        .foregroundStyle(Theme.secondaryText)
                        .padding(Theme.watchSpacingS)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusS))
                }
                .padding(Theme.spacingM)
            }
            .navigationTitle("Health Integration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.caption)
                }
            }
        }
    }
}

struct SectionHeader: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(Theme.primaryText)
            .padding(.top, Theme.watchSpacingS)
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Theme.accentColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption2)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(Theme.watchSpacingS)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusS))
    }
}

#Preview("Settings") {
    NavigationStack {
        SettingsView()
    }
}

#Preview("HealthKit Info") {
    HealthKitInfoView()
}

