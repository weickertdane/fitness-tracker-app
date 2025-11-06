import Foundation
import SwiftUI
import Observation

/**
 * Centralized app settings manager using @AppStorage for persistence.
 * Provides observable settings that can be used throughout the app.
 */
@Observable
final class AppSettings {
    static let shared = AppSettings()
    
    // MARK: - Health Integration Settings
    
    /// Whether HealthKit integration is enabled (off by default)
    @AppStorage("enableHealthKit") var isHealthKitEnabled: Bool = false
    
    // MARK: - Display Settings
    
    /// Whether to show advanced metrics like distance/steps (on by default)
    @AppStorage("showAdvancedMetrics") var showAdvancedMetrics: Bool = true
    
    // MARK: - Development Settings
    
    #if DEBUG
    /// Enable debug logging (development only)
    @AppStorage("enableDebugLogging") var enableDebugLogging: Bool = false
    #endif
    
    private init() {}
    
    // MARK: - Computed Properties
    
    /**
     * Whether HealthKit features should be visible in the UI.
     * Currently always returns false since HealthKit is dormant.
     */
    var shouldShowHealthKitFeatures: Bool {
        return isHealthKitEnabled && false  // Force false until HealthKit is implemented
    }
    
    /**
     * Whether advanced metrics should be shown for a given exercise.
     * Respects both the global setting and exercise-specific allowed metrics.
     */
    func shouldShowAdvancedMetrics(for exercise: Exercise?) -> Bool {
        guard showAdvancedMetrics else { return false }
        
        // If no exercise specified, show advanced metrics
        guard let exercise = exercise else { return true }
        
        // Show advanced metrics if the exercise specifically allows them
        let hasAdvancedMetrics = exercise.allowedMetrics.contains { metric in
            switch metric {
            case .distanceMeters, .steps:
                return true
            default:
                return false
            }
        }
        
        return hasAdvancedMetrics
    }
    
    // MARK: - Settings Actions
    
    /**
     * Toggles HealthKit integration with proper logging.
     * Safe to call - will not crash even when HealthKit is not implemented.
     */
    func toggleHealthKit() {
        isHealthKitEnabled.toggle()
        
        if isHealthKitEnabled {
            print("⚠️ HealthKit enabled but dormant - no data will be written until implementation is complete")
            // Future: Request HealthKit authorization here
            // HealthKitManager.shared.requestAuthorization()
        } else {
            print("ℹ️ HealthKit disabled")
        }
    }
    
    /**
     * Resets all settings to their default values.
     */
    func resetToDefaults() {
        isHealthKitEnabled = false
        showAdvancedMetrics = true
        
        #if DEBUG
        enableDebugLogging = false
        #endif
        
        print("🔄 Settings reset to defaults")
    }
}

// MARK: - Convenience Extensions

extension AppSettings {
    /**
     * Returns user-friendly descriptions for settings values.
     */
    var healthKitStatusDescription: String {
        if isHealthKitEnabled {
            return "Enabled (Dormant)"
        } else {
            return "Disabled"
        }
    }
    
    var advancedMetricsDescription: String {
        return showAdvancedMetrics ? "Shown" : "Hidden"
    }
}

// MARK: - Settings Keys Documentation

/**
 * Documentation of all @AppStorage keys used in the app.
 * 
 * IMPORTANT: When adding new settings, document them here to avoid key conflicts.
 * 
 * Current Keys:
 * - "enableHealthKit": Bool - Whether HealthKit integration is enabled
 * - "showAdvancedMetrics": Bool - Whether to show distance/steps metrics
 * - "enableDebugLogging": Bool - Debug logging (DEBUG builds only)
 * 
 * Reserved for Future Use:
 * - "defaultWorkoutGoal": String - Default goal for new exercises
 * - "preferredWeightUnit": String - lbs vs kg preference
 * - "autoEndWorkouts": Bool - Automatically end workouts after inactivity
 * - "syncPreference": String - WiFi only vs cellular sync preference
 */
