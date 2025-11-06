import SwiftUI

/**
 * Simple test view to verify settings functionality works without crashing.
 * This can be used during development to test the settings system.
 */
struct SettingsTestView: View {
    @Environment(AppSettings.self) private var settings
    @State private var testResults: [String] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Settings Test")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Current Settings Display
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Settings:")
                        .font(.headline)
                    
                    Text("HealthKit: \(settings.healthKitStatusDescription)")
                    Text("Advanced Metrics: \(settings.advancedMetricsDescription)")
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Test Buttons
                VStack(spacing: 12) {
                    Button("Toggle HealthKit") {
                        testHealthKitToggle()
                    }
                    .primaryButtonStyle()
                    
                    Button("Toggle Advanced Metrics") {
                        testAdvancedMetricsToggle()
                    }
                    .secondaryButtonStyle()
                    
                    Button("Reset Settings") {
                        testResetSettings()
                    }
                    .destructiveButtonStyle()
                }
                
                // Test Results
                if !testResults.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Test Results:")
                            .font(.headline)
                        
                        ForEach(testResults.indices, id: \.self) { index in
                            Text("✅ \(testResults[index])")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Settings Test")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Test Methods
    
    private func testHealthKitToggle() {
        let initialValue = settings.isHealthKitEnabled
        
        do {
            // Toggle HealthKit setting
            settings.toggleHealthKit()
            
            // Verify it changed
            let newValue = settings.isHealthKitEnabled
            if newValue != initialValue {
                testResults.append("HealthKit toggle successful: \(initialValue) → \(newValue)")
            } else {
                testResults.append("HealthKit toggle failed - value unchanged")
            }
            
            // Verify no crash occurred
            testResults.append("HealthKit toggle completed without crash")
            
        } catch {
            testResults.append("HealthKit toggle crashed: \(error.localizedDescription)")
        }
    }
    
    private func testAdvancedMetricsToggle() {
        let initialValue = settings.showAdvancedMetrics
        
        // Toggle advanced metrics
        settings.showAdvancedMetrics.toggle()
        
        // Verify it changed
        let newValue = settings.showAdvancedMetrics
        if newValue != initialValue {
            testResults.append("Advanced metrics toggle successful: \(initialValue) → \(newValue)")
        } else {
            testResults.append("Advanced metrics toggle failed - value unchanged")
        }
    }
    
    private func testResetSettings() {
        settings.resetToDefaults()
        testResults.append("Settings reset to defaults")
        
        // Verify defaults
        if !settings.isHealthKitEnabled && settings.showAdvancedMetrics {
            testResults.append("Default values verified correctly")
        } else {
            testResults.append("Default values incorrect")
        }
    }
}

#Preview {
    SettingsTestView()
        .environment(AppSettings.shared)
}
