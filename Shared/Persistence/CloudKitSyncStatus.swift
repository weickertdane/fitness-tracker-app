import Foundation
import SwiftUI
import CloudKit
import Observation

/**
 * Tracks CloudKit synchronization status and provides observable state for UI updates.
 */
@Observable
final class CloudKitSyncStatus {
    static let shared = CloudKitSyncStatus()
    
    // MARK: - Published State
    
    /// Current sync state
    var syncState: SyncState = .unknown
    
    /// Last successful sync timestamp
    var lastSuccessfulSync: Date?
    
    /// Number of operations currently in flight
    var operationsInFlight: Int = 0
    
    /// Current error, if any
    var currentError: CloudKitError?
    
    /// Whether CloudKit is available (user signed in, network available, etc.)
    var isCloudKitAvailable: Bool = false
    
    // MARK: - Sync State Enum
    
    enum SyncState {
        case unknown
        case syncing
        case synced
        case error
        case offline
    }
    
    // MARK: - CloudKit Error Wrapper
    
    struct CloudKitError {
        let message: String
        let code: Int?
        let timestamp: Date
        
        init(_ error: Error) {
            self.message = error.localizedDescription
            self.code = (error as? CKError)?.code.rawValue
            self.timestamp = Date()
        }
    }
    
    private init() {}
    
    // MARK: - Public Methods
    
    /**
     * Starts monitoring CloudKit sync status.
     */
    func startMonitoring() {
        checkCloudKitAvailability()
        
        // Set up periodic status checks
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            self.checkCloudKitAvailability()
        }
    }
    
    /**
     * Manually triggers a sync status update.
     */
    func refreshStatus() {
        checkCloudKitAvailability()
    }
    
    /**
     * Records the start of a sync operation.
     */
    func recordOperationStart() {
        operationsInFlight += 1
        if syncState != .error {
            syncState = .syncing
        }
    }
    
    /**
     * Records the completion of a sync operation.
     */
    func recordOperationComplete(success: Bool, error: Error? = nil) {
        operationsInFlight = max(0, operationsInFlight - 1)
        
        if success {
            lastSuccessfulSync = Date()
            if operationsInFlight == 0 {
                syncState = .synced
            }
            currentError = nil
        } else if let error = error {
            syncState = .error
            currentError = CloudKitError(error)
        }
    }
    
    // MARK: - Private Methods
    
    private func checkCloudKitAvailability() {
        let container = CKContainer(identifier: Persistence.containerIdentifier)
        
        container.accountStatus { [weak self] accountStatus, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    self.isCloudKitAvailable = false
                    self.syncState = .error
                    self.currentError = CloudKitError(error)
                    return
                }
                
                switch accountStatus {
                case .available:
                    self.isCloudKitAvailable = true
                    if self.syncState == .unknown || self.syncState == .offline {
                        self.syncState = .synced
                    }
                case .noAccount, .restricted, .couldNotDetermine:
                    self.isCloudKitAvailable = false
                    self.syncState = .offline
                @unknown default:
                    self.isCloudKitAvailable = false
                    self.syncState = .unknown
                }
            }
        }
    }
}

// MARK: - Computed Properties for UI
extension CloudKitSyncStatus {
    /**
     * Human-readable status message for display in UI.
     */
    var statusMessage: String {
        switch syncState {
        case .unknown:
            return "Checking sync status..."
        case .syncing:
            return operationsInFlight > 0 ? "Syncing..." : "Sync in progress"
        case .synced:
            if let lastSync = lastSuccessfulSync {
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .abbreviated
                return "Synced \(formatter.localizedString(for: lastSync, relativeTo: Date()))"
            } else {
                return "Synced"
            }
        case .error:
            return "Sync error"
        case .offline:
            return "Offline"
        }
    }
    
    /**
     * Whether sync is currently active.
     */
    var isSyncing: Bool {
        return syncState == .syncing || operationsInFlight > 0
    }
    
    /**
     * Whether there's a sync error.
     */
    var hasError: Bool {
        return syncState == .error || currentError != nil
    }
}

// MARK: - Testing and Simulation
extension CloudKitSyncStatus {
    /**
     * Simulates a sync operation for testing purposes.
     * This can be used to test the sync status UI without actual CloudKit operations.
     */
    func simulateSync(duration: TimeInterval = 2.0, shouldSucceed: Bool = true) {
        recordOperationStart()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if shouldSucceed {
                self.recordOperationComplete(success: true)
            } else {
                let simulatedError = NSError(
                    domain: "SimulatedError", 
                    code: 1001, 
                    userInfo: [NSLocalizedDescriptionKey: "Simulated sync failure for testing"]
                )
                self.recordOperationComplete(success: false, error: simulatedError)
            }
        }
    }
    
    /**
     * Resets sync status to initial state for testing.
     */
    func resetForTesting() {
        syncState = .unknown
        lastSuccessfulSync = nil
        operationsInFlight = 0
        currentError = nil
        isCloudKitAvailable = false
    }
}
