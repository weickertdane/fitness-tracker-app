import XCTest
@testable import OfflineWorkoutApp

/**
 * Unit tests for AppSettings functionality and feature flags.
 */
final class AppSettingsTests: XCTestCase {
    
    private var appSettings: AppSettings!
    
    override func setUpWithError() throws {
        appSettings = AppSettings.shared
        // Reset to defaults before each test
        appSettings.resetToDefaults()
    }
    
    override func tearDownWithError() throws {
        // Clean up after each test
        appSettings.resetToDefaults()
        appSettings = nil
    }
    
    // MARK: - Default Settings Tests
    
    /**
     * Test that default settings are correct.
     */
    func testDefaultSettings() throws {
        XCTAssertFalse(appSettings.isHealthKitEnabled, "HealthKit should be disabled by default")
        XCTAssertTrue(appSettings.showAdvancedMetrics, "Advanced metrics should be shown by default")
        XCTAssertFalse(appSettings.shouldShowHealthKitFeatures, "HealthKit features should be hidden by default")
        
        // Test status descriptions
        XCTAssertEqual(appSettings.healthKitStatusDescription, "Disabled")
        XCTAssertEqual(appSettings.advancedMetricsDescription, "Shown")
        
        print("✅ Default settings test passed")
    }
    
    // MARK: - HealthKit Toggle Tests
    
    /**
     * Test that HealthKit toggle works without crashing.
     */
    func testHealthKitToggleDoesNotCrash() throws {
        let initialValue = appSettings.isHealthKitEnabled
        
        // This should not crash
        XCTAssertNoThrow(appSettings.toggleHealthKit())
        
        // Verify the value changed
        XCTAssertNotEqual(appSettings.isHealthKitEnabled, initialValue)
        
        // Toggle again
        XCTAssertNoThrow(appSettings.toggleHealthKit())
        
        // Should be back to original value
        XCTAssertEqual(appSettings.isHealthKitEnabled, initialValue)
        
        print("✅ HealthKit toggle test passed: no crashes occurred")
    }
    
    /**
     * Test HealthKit status descriptions.
     */
    func testHealthKitStatusDescriptions() throws {
        // Test disabled state
        appSettings.isHealthKitEnabled = false
        XCTAssertEqual(appSettings.healthKitStatusDescription, "Disabled")
        
        // Test enabled state
        appSettings.isHealthKitEnabled = true
        XCTAssertEqual(appSettings.healthKitStatusDescription, "Enabled (Dormant)")
        
        // Test that features are still hidden even when enabled
        XCTAssertFalse(appSettings.shouldShowHealthKitFeatures, "HealthKit features should remain hidden until implemented")
        
        print("✅ HealthKit status descriptions test passed")
    }
    
    // MARK: - Advanced Metrics Tests
    
    /**
     * Test advanced metrics toggle functionality.
     */
    func testAdvancedMetricsToggle() throws {
        // Start with default (true)
        XCTAssertTrue(appSettings.showAdvancedMetrics)
        XCTAssertEqual(appSettings.advancedMetricsDescription, "Shown")
        
        // Toggle off
        appSettings.showAdvancedMetrics = false
        XCTAssertFalse(appSettings.showAdvancedMetrics)
        XCTAssertEqual(appSettings.advancedMetricsDescription, "Hidden")
        
        // Toggle back on
        appSettings.showAdvancedMetrics = true
        XCTAssertTrue(appSettings.showAdvancedMetrics)
        XCTAssertEqual(appSettings.advancedMetricsDescription, "Shown")
        
        print("✅ Advanced metrics toggle test passed")
    }
    
    /**
     * Test advanced metrics logic for different exercises.
     */
    func testAdvancedMetricsLogicForExercises() throws {
        // Create test exercises
        let basicExercise = Exercise(
            name: "Bench Press",
            goal: .strength,
            bodyPart: .chest,
            allowedMetrics: [.reps, .weightLbs]
        )
        
        let runningExercise = Exercise(
            name: "Run",
            goal: .strength,
            bodyPart: .other,
            allowedMetrics: [.durationSeconds, .distanceMeters] // Has advanced metrics
        )
        
        let stairmasterExercise = Exercise(
            name: "Stairmaster",
            goal: .strength,
            bodyPart: .other,
            allowedMetrics: [.steps, .durationSeconds] // Has advanced metrics
        )
        
        // Test with advanced metrics enabled
        appSettings.showAdvancedMetrics = true
        
        XCTAssertFalse(appSettings.shouldShowAdvancedMetrics(for: basicExercise))
        XCTAssertTrue(appSettings.shouldShowAdvancedMetrics(for: runningExercise))
        XCTAssertTrue(appSettings.shouldShowAdvancedMetrics(for: stairmasterExercise))
        XCTAssertTrue(appSettings.shouldShowAdvancedMetrics(for: nil)) // No exercise specified
        
        // Test with advanced metrics disabled
        appSettings.showAdvancedMetrics = false
        
        XCTAssertFalse(appSettings.shouldShowAdvancedMetrics(for: basicExercise))
        XCTAssertFalse(appSettings.shouldShowAdvancedMetrics(for: runningExercise))
        XCTAssertFalse(appSettings.shouldShowAdvancedMetrics(for: stairmasterExercise))
        XCTAssertFalse(appSettings.shouldShowAdvancedMetrics(for: nil))
        
        print("✅ Advanced metrics logic test passed")
    }
    
    // MARK: - Settings Persistence Tests
    
    /**
     * Test that settings reset works correctly.
     */
    func testSettingsReset() throws {
        // Change settings from defaults
        appSettings.isHealthKitEnabled = true
        appSettings.showAdvancedMetrics = false
        
        // Verify they changed
        XCTAssertTrue(appSettings.isHealthKitEnabled)
        XCTAssertFalse(appSettings.showAdvancedMetrics)
        
        // Reset to defaults
        appSettings.resetToDefaults()
        
        // Verify they're back to defaults
        XCTAssertFalse(appSettings.isHealthKitEnabled)
        XCTAssertTrue(appSettings.showAdvancedMetrics)
        
        print("✅ Settings reset test passed")
    }
    
    // MARK: - Edge Cases
    
    /**
     * Test edge cases and boundary conditions.
     */
    func testEdgeCases() throws {
        // Test multiple rapid toggles
        for _ in 0..<10 {
            appSettings.toggleHealthKit()
        }
        
        // Should end up back at starting state (false)
        XCTAssertFalse(appSettings.isHealthKitEnabled)
        
        // Test that settings can handle rapid changes
        for i in 0..<100 {
            appSettings.showAdvancedMetrics = (i % 2 == 0)
        }
        
        // Should end up false (even number of iterations)
        XCTAssertFalse(appSettings.showAdvancedMetrics)
        
        print("✅ Edge cases test passed")
    }
}

// MARK: - Mock Exercise for Testing

extension AppSettingsTests {
    
    /**
     * Helper to create test exercises with specific metrics.
     */
    private func createTestExercise(allowedMetrics: [MetricType]) -> Exercise {
        return Exercise(
            name: "Test Exercise",
            goal: .strength,
            bodyPart: .chest,
            allowedMetrics: allowedMetrics
        )
    }
}
