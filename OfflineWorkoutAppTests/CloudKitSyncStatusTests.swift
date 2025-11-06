import XCTest
@testable import OfflineWorkoutApp

/**
 * Unit tests for CloudKit sync status functionality.
 */
final class CloudKitSyncStatusTests: XCTestCase {
    
    private var syncStatus: CloudKitSyncStatus!
    
    override func setUpWithError() throws {
        syncStatus = CloudKitSyncStatus.shared
        syncStatus.resetForTesting()
    }
    
    override func tearDownWithError() throws {
        syncStatus.resetForTesting()
        syncStatus = nil
    }
    
    // MARK: - Initial State Tests
    
    /**
     * Test initial sync status state.
     */
    func testInitialState() throws {
        XCTAssertEqual(syncStatus.syncState, .unknown)
        XCTAssertNil(syncStatus.lastSuccessfulSync)
        XCTAssertEqual(syncStatus.operationsInFlight, 0)
        XCTAssertNil(syncStatus.currentError)
        XCTAssertFalse(syncStatus.isCloudKitAvailable)
        XCTAssertFalse(syncStatus.isSyncing)
        XCTAssertFalse(syncStatus.hasError)
        
        print("✅ Initial state test passed")
    }
    
    // MARK: - Sync Operation Tests
    
    /**
     * Test successful sync operation tracking.
     */
    func testSuccessfulSyncOperation() throws {
        let expectation = XCTestExpectation(description: "Sync operation completes successfully")
        
        // Start sync operation
        syncStatus.recordOperationStart()
        
        XCTAssertEqual(syncStatus.operationsInFlight, 1)
        XCTAssertEqual(syncStatus.syncState, .syncing)
        XCTAssertTrue(syncStatus.isSyncing)
        
        // Complete sync operation successfully
        syncStatus.recordOperationComplete(success: true)
        
        XCTAssertEqual(syncStatus.operationsInFlight, 0)
        XCTAssertEqual(syncStatus.syncState, .synced)
        XCTAssertFalse(syncStatus.isSyncing)
        XCTAssertNotNil(syncStatus.lastSuccessfulSync)
        XCTAssertNil(syncStatus.currentError)
        
        expectation.fulfill()
        wait(for: [expectation], timeout: 1.0)
        
        print("✅ Successful sync operation test passed")
    }
    
    /**
     * Test failed sync operation tracking.
     */
    func testFailedSyncOperation() throws {
        let testError = NSError(domain: "TestError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Test sync failure"])
        
        // Start sync operation
        syncStatus.recordOperationStart()
        XCTAssertTrue(syncStatus.isSyncing)
        
        // Complete sync operation with error
        syncStatus.recordOperationComplete(success: false, error: testError)
        
        XCTAssertEqual(syncStatus.operationsInFlight, 0)
        XCTAssertEqual(syncStatus.syncState, .error)
        XCTAssertFalse(syncStatus.isSyncing)
        XCTAssertTrue(syncStatus.hasError)
        XCTAssertNotNil(syncStatus.currentError)
        XCTAssertEqual(syncStatus.currentError?.message, "Test sync failure")
        XCTAssertEqual(syncStatus.currentError?.code, 1001)
        
        print("✅ Failed sync operation test passed")
    }
    
    /**
     * Test multiple concurrent sync operations.
     */
    func testMultipleConcurrentOperations() throws {
        // Start multiple operations
        syncStatus.recordOperationStart()
        syncStatus.recordOperationStart()
        syncStatus.recordOperationStart()
        
        XCTAssertEqual(syncStatus.operationsInFlight, 3)
        XCTAssertEqual(syncStatus.syncState, .syncing)
        
        // Complete first operation
        syncStatus.recordOperationComplete(success: true)
        XCTAssertEqual(syncStatus.operationsInFlight, 2)
        XCTAssertEqual(syncStatus.syncState, .syncing) // Still syncing
        
        // Complete second operation
        syncStatus.recordOperationComplete(success: true)
        XCTAssertEqual(syncStatus.operationsInFlight, 1)
        XCTAssertEqual(syncStatus.syncState, .syncing) // Still syncing
        
        // Complete final operation
        syncStatus.recordOperationComplete(success: true)
        XCTAssertEqual(syncStatus.operationsInFlight, 0)
        XCTAssertEqual(syncStatus.syncState, .synced) // Now synced
        
        print("✅ Multiple concurrent operations test passed")
    }
    
    // MARK: - Status Message Tests
    
    /**
     * Test status message generation for different states.
     */
    func testStatusMessages() throws {
        // Test unknown state
        syncStatus.syncState = .unknown
        XCTAssertEqual(syncStatus.statusMessage, "Checking sync status...")
        
        // Test syncing state
        syncStatus.syncState = .syncing
        syncStatus.operationsInFlight = 2
        XCTAssertEqual(syncStatus.statusMessage, "Syncing...")
        
        // Test synced state without last sync time
        syncStatus.syncState = .synced
        syncStatus.operationsInFlight = 0
        XCTAssertEqual(syncStatus.statusMessage, "Synced")
        
        // Test synced state with recent sync time
        syncStatus.lastSuccessfulSync = Date().addingTimeInterval(-30) // 30 seconds ago
        let message = syncStatus.statusMessage
        XCTAssertTrue(message.contains("Synced"), "Message should contain 'Synced': \(message)")
        
        // Test error state
        syncStatus.syncState = .error
        XCTAssertEqual(syncStatus.statusMessage, "Sync error")
        
        // Test offline state
        syncStatus.syncState = .offline
        XCTAssertEqual(syncStatus.statusMessage, "Offline")
        
        print("✅ Status messages test passed")
    }
    
    // MARK: - Simulation Tests
    
    /**
     * Test sync simulation functionality.
     */
    func testSyncSimulation() throws {
        let expectation = XCTestExpectation(description: "Sync simulation completes")
        
        // Start simulation
        syncStatus.simulateSync(duration: 0.1, shouldSucceed: true)
        
        // Should immediately show syncing
        XCTAssertEqual(syncStatus.syncState, .syncing)
        XCTAssertEqual(syncStatus.operationsInFlight, 1)
        
        // Wait for simulation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(self.syncStatus.syncState, .synced)
            XCTAssertEqual(self.syncStatus.operationsInFlight, 0)
            XCTAssertNotNil(self.syncStatus.lastSuccessfulSync)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        print("✅ Sync simulation test passed")
    }
    
    /**
     * Test failed sync simulation.
     */
    func testFailedSyncSimulation() throws {
        let expectation = XCTestExpectation(description: "Failed sync simulation completes")
        
        // Start failed simulation
        syncStatus.simulateSync(duration: 0.1, shouldSucceed: false)
        
        // Should immediately show syncing
        XCTAssertEqual(syncStatus.syncState, .syncing)
        
        // Wait for simulation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(self.syncStatus.syncState, .error)
            XCTAssertEqual(self.syncStatus.operationsInFlight, 0)
            XCTAssertNotNil(self.syncStatus.currentError)
            XCTAssertTrue(self.syncStatus.hasError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        print("✅ Failed sync simulation test passed")
    }
    
    // MARK: - Reset Tests
    
    /**
     * Test that reset functionality works correctly.
     */
    func testResetFunctionality() throws {
        // Set up some state
        syncStatus.syncState = .synced
        syncStatus.lastSuccessfulSync = Date()
        syncStatus.operationsInFlight = 2
        syncStatus.currentError = CloudKitSyncStatus.CloudKitError(NSError(domain: "Test", code: 1, userInfo: [:]))
        syncStatus.isCloudKitAvailable = true
        
        // Reset
        syncStatus.resetForTesting()
        
        // Verify reset state
        XCTAssertEqual(syncStatus.syncState, .unknown)
        XCTAssertNil(syncStatus.lastSuccessfulSync)
        XCTAssertEqual(syncStatus.operationsInFlight, 0)
        XCTAssertNil(syncStatus.currentError)
        XCTAssertFalse(syncStatus.isCloudKitAvailable)
        
        print("✅ Reset functionality test passed")
    }
    
    // MARK: - Edge Cases
    
    /**
     * Test edge cases and boundary conditions.
     */
    func testEdgeCases() throws {
        // Test negative operations in flight (should not go below 0)
        syncStatus.recordOperationComplete(success: true)
        XCTAssertEqual(syncStatus.operationsInFlight, 0)
        
        // Test completing operation when none are in flight
        syncStatus.recordOperationComplete(success: true)
        XCTAssertEqual(syncStatus.operationsInFlight, 0)
        
        // Test error handling with nil error
        syncStatus.recordOperationComplete(success: false, error: nil)
        XCTAssertEqual(syncStatus.syncState, .error)
        XCTAssertNil(syncStatus.currentError)
        
        print("✅ Edge cases test passed")
    }
}
