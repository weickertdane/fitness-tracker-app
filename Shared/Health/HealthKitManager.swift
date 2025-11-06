import Foundation
import HealthKit
import Observation

/**
 * Manages HealthKit integration for the OfflineWorkout app.
 * 
 * IMPORTANT: This manager is DORMANT by default and will not write any data to HealthKit
 * until explicitly enabled via the isEnabled feature flag.
 * 
 * To enable HealthKit integration:
 * 1. Set HealthKitManager.shared.isEnabled = true
 * 2. Call requestAuthorization() to get user permissions
 * 3. Use saveStrengthWorkout() and saveRunningWorkout() to write data
 * 
 * The app will function completely without HealthKit - this is purely additive functionality.
 */
@Observable
final class HealthKitManager {
    static let shared = HealthKitManager()
    
    // MARK: - Feature Flag
    
    /**
     * Feature flag to enable/disable HealthKit functionality.
     * 
     * DEFAULT: false - HealthKit is completely dormant
     * 
     * When false:
     * - No HealthKit permissions are requested
     * - No data is written to HealthKit
     * - All HealthKit methods return early without action
     * 
     * When true:
     * - User can be prompted for HealthKit permissions
     * - Workout data can be written to HealthKit
     * - Integration becomes active
     */
    var isEnabled: Bool = false
    
    // MARK: - State
    
    /// Whether HealthKit is available on this device
    var isHealthKitAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    /// Current authorization status
    var authorizationStatus: AuthorizationStatus = .notDetermined
    
    /// Last error encountered
    var lastError: HealthKitError?
    
    // MARK: - Private Properties
    
    private let healthStore = HKHealthStore()
    
    // MARK: - Enums
    
    enum AuthorizationStatus {
        case notDetermined
        case denied
        case authorized
        case notSupported
    }
    
    struct HealthKitError {
        let message: String
        let code: Int?
        let timestamp: Date
        
        init(_ error: Error) {
            self.message = error.localizedDescription
            self.code = (error as NSError).code
            self.timestamp = Date()
        }
    }
    
    private init() {
        // HealthKit manager starts dormant - no initialization until enabled
    }
    
    // MARK: - Authorization
    
    /**
     * Requests HealthKit authorization for reading and writing workout data.
     * 
     * Permissions requested:
     * - READ: Strength Training workouts, Running workouts, Distance, Steps
     * - WRITE: Strength Training workouts, Running workouts, Distance, Steps
     * 
     * NOTE: This method does nothing if isEnabled is false.
     */
    func requestAuthorization() async -> Bool {
        guard isEnabled else {
            print("⚠️ HealthKitManager: Authorization skipped - HealthKit is disabled")
            return false
        }
        
        guard isHealthKitAvailable else {
            authorizationStatus = .notSupported
            lastError = HealthKitError(NSError(
                domain: "HealthKitManager",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]
            ))
            return false
        }
        
        // Define the data types we want to read and write
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]
        
        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
            
            // Check authorization status for workout type
            let workoutAuthStatus = healthStore.authorizationStatus(for: HKObjectType.workoutType())
            
            switch workoutAuthStatus {
            case .sharingAuthorized:
                authorizationStatus = .authorized
                lastError = nil
                print("✅ HealthKit authorization granted")
                return true
            case .sharingDenied:
                authorizationStatus = .denied
                print("❌ HealthKit authorization denied")
                return false
            case .notDetermined:
                authorizationStatus = .notDetermined
                print("⚠️ HealthKit authorization not determined")
                return false
            @unknown default:
                authorizationStatus = .notDetermined
                return false
            }
        } catch {
            authorizationStatus = .denied
            lastError = HealthKitError(error)
            print("❌ HealthKit authorization error: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Workout Saving (Stubbed - Not Implemented)
    
    /**
     * Saves a strength training workout to HealthKit.
     * 
     * STUB: This function is not yet implemented and will not write any data.
     * 
     * Future implementation will:
     * - Convert OfflineWorkout Workout model to HKWorkout
     * - Include exercise sets as workout events
     * - Set appropriate workout type (HKWorkoutActivityType.traditionalStrengthTraining)
     * - Include total duration, calories burned (if available)
     * 
     * @param workout The workout to save to HealthKit
     * @return Success/failure of the save operation
     */
    func saveStrengthWorkout(_ workout: Workout) async -> Bool {
        guard isEnabled else {
            print("⚠️ HealthKitManager: Strength workout save skipped - HealthKit is disabled")
            return false
        }
        
        guard authorizationStatus == .authorized else {
            print("⚠️ HealthKitManager: Strength workout save skipped - not authorized")
            return false
        }
        
        // TODO: Implement in future prompt
        // This is intentionally stubbed for now
        print("🚧 HealthKitManager: saveStrengthWorkout() not yet implemented")
        print("   Workout: \(workout.startedAt) - \(workout.endedAt?.description ?? "ongoing")")
        print("   Sets: \(workout.sets?.count ?? 0)")
        
        return false
    }
    
    /**
     * Saves a running/cardio workout to HealthKit.
     * 
     * STUB: This function is not yet implemented and will not write any data.
     * 
     * Future implementation will:
     * - Convert OfflineWorkout Workout model to HKWorkout
     * - Include distance and steps data
     * - Set appropriate workout type (HKWorkoutActivityType.running, .walking, etc.)
     * - Include route data if GPS tracking is added later
     * 
     * @param workout The workout to save to HealthKit
     * @return Success/failure of the save operation
     */
    func saveRunningWorkout(_ workout: Workout) async -> Bool {
        guard isEnabled else {
            print("⚠️ HealthKitManager: Running workout save skipped - HealthKit is disabled")
            return false
        }
        
        guard authorizationStatus == .authorized else {
            print("⚠️ HealthKitManager: Running workout save skipped - not authorized")
            return false
        }
        
        // TODO: Implement in future prompt
        // This is intentionally stubbed for now
        print("🚧 HealthKitManager: saveRunningWorkout() not yet implemented")
        print("   Workout: \(workout.startedAt) - \(workout.endedAt?.description ?? "ongoing")")
        print("   Sets: \(workout.sets?.count ?? 0)")
        
        // Calculate total distance and steps from sets
        let totalDistance = workout.sets?.compactMap { $0.distanceMeters }.reduce(0, +) ?? 0
        let totalSteps = workout.sets?.compactMap { $0.steps }.reduce(0, +) ?? 0
        
        print("   Distance: \(totalDistance) meters")
        print("   Steps: \(totalSteps)")
        
        return false
    }
}

// MARK: - Future Implementation Guide
extension HealthKitManager {
    /**
     * COMPREHENSIVE GUIDE: How to Enable HealthKit Integration
     * 
     * This HealthKitManager is currently DORMANT and ready for future activation.
     * Follow these steps to enable full HealthKit integration:
     * 
     * STEP 1: Enable the Feature Flag
     * ```swift
     * HealthKitManager.shared.isEnabled = true
     * ```
     * 
     * STEP 2: Request Authorization (typically in app settings or onboarding)
     * ```swift
     * let authorized = await HealthKitManager.shared.requestAuthorization()
     * if authorized {
     *     // HealthKit is ready to use
     * }
     * ```
     * 
     * STEP 3: Save Workouts (after completing a workout)
     * ```swift
     * // For strength training workouts
     * let success = await HealthKitManager.shared.saveStrengthWorkout(workout)
     * 
     * // For running/cardio workouts
     * let success = await HealthKitManager.shared.saveRunningWorkout(workout)
     * ```
     * 
     * STEP 4: Implement the Stubbed Functions
     * The saveStrengthWorkout() and saveRunningWorkout() functions are currently
     * stubbed and need full implementation. They should:
     * 
     * For Strength Workouts:
     * - Create HKWorkout with type .traditionalStrengthTraining
     * - Convert exercise sets to HKWorkoutEvents
     * - Include total duration from workout.durationSeconds
     * - Optionally estimate calories burned
     * 
     * For Running Workouts:
     * - Create HKWorkout with appropriate type (.running, .walking, etc.)
     * - Include distance data from sets
     * - Include step count data from sets
     * - Set workout duration
     * - Optionally include route data if GPS is added
     * 
     * STEP 5: Error Handling
     * Monitor HealthKitManager.shared.lastError for any issues
     * Check HealthKitManager.shared.authorizationStatus for permission state
     * 
     * STEP 6: UI Integration
     * Use @Observable properties to update UI:
     * - isEnabled: Show/hide HealthKit settings
     * - authorizationStatus: Show permission state
     * - lastError: Display error messages
     * 
     * IMPORTANT NOTES:
     * - The app works completely without HealthKit
     * - HealthKit is purely additive functionality
     * - All data is stored in SwiftData regardless of HealthKit status
     * - Users can enable/disable HealthKit at any time
     * - No HealthKit data is written until explicitly enabled and authorized
     */
    
    /**
     * Validates that HealthKit is properly configured and ready for use.
     * Call this method during app startup to verify HealthKit setup.
     */
    func validateConfiguration() {
        print("🏥 HealthKit Configuration:")
        print("   Available: \(isHealthKitAvailable)")
        print("   Enabled: \(isEnabled)")
        print("   Authorization: \(authorizationStatus)")
        
        if !isEnabled {
            print("   ✅ HealthKit is dormant (as expected)")
        } else {
            print("   ⚠️ HealthKit is enabled - ensure authorization is requested")
        }
    }
}
