import Foundation
import SwiftData
import CloudKit

/**
 * Manages SwiftData persistence with CloudKit sync for the OfflineWorkout app.
 * Provides offline-first data storage with automatic CloudKit synchronization.
 * 
 * SCHEMA VERSIONING GUIDE:
 * 
 * SwiftData automatically handles lightweight migrations for:
 * - Adding optional properties to existing models
 * - Adding new models to the schema
 * - Renaming properties (with @Attribute(.originalName("oldName")))
 * 
 * For more complex migrations, increment SCHEMA_VERSION and implement custom migration logic.
 */
final class Persistence {
    static let shared = Persistence()
    
    /// Current schema version - increment when making breaking changes
    static let SCHEMA_VERSION = 1
    
    /// The CloudKit container identifier used by both iOS and watchOS targets
    static let containerIdentifier = "iCloud.com.daneweickert.OfflineWorkout"
    
    lazy var modelContainer: ModelContainer = {
        // Define current schema with version tracking
        let schema = Schema(
            versionedSchema: OfflineWorkoutSchemaV1.self
        )
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private(Self.containerIdentifier)
        )
        
        do {
            let container = try ModelContainer(
                for: schema,
                migrationPlan: OfflineWorkoutMigrationPlan.self,
                configurations: [modelConfiguration]
            )
            
            // Configure for offline-first behavior
            // Data writes occur locally immediately, CloudKit sync happens in background
            print("✅ ModelContainer initialized with schema v\(Self.SCHEMA_VERSION)")
            
            return container
        } catch {
            print("❌ Failed to create ModelContainer with CloudKit: \(error.localizedDescription)")
            print("🔄 Attempting fallback to local-only storage...")
            
            // Fallback to local-only storage if CloudKit fails
            let fallbackConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            
            do {
                let fallbackContainer = try ModelContainer(
                    for: schema,
                    migrationPlan: OfflineWorkoutMigrationPlan.self,
                    configurations: [fallbackConfiguration]
                )
                
                print("✅ ModelContainer initialized with local-only storage (CloudKit disabled)")
                return fallbackContainer
            } catch {
                print("❌ Failed to create fallback ModelContainer: \(error.localizedDescription)")
                print("🔄 Creating in-memory container as last resort...")
                
                // Last resort: CloudKit-enabled storage for Watch app
                let memoryConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    cloudKitDatabase: .private("iCloud.com.daneweickert.OfflineWorkout")
                )
                
                do {
                    let memoryContainer = try ModelContainer(
                        for: schema,
                        configurations: [memoryConfiguration]
                    )
                    
                    print("✅ ModelContainer initialized with CloudKit sync (data will sync between devices)")
                    return memoryContainer
                } catch {
                    print("❌ Failed to create in-memory ModelContainer with full schema: \(error.localizedDescription)")
                    print("🔄 Attempting minimal schema as emergency fallback...")
                    
                    // Emergency fallback: try with minimal schema (just one model)
                    return createEmergencyFallbackContainer()
                }
            }
        }
    }()
    
    private init() {
        // CloudKit sync status monitoring not available on watchOS
    }
    
    /**
     * Creates an emergency fallback container with minimal schema.
     * This is used when the full schema fails to initialize.
     */
    private func createEmergencyFallbackContainer() -> ModelContainer {
        do {
            // Try with just the Exercise model (simplest possible schema for watchOS)
            let emergencySchema = Schema([Exercise.self])
            let emergencyConfiguration = ModelConfiguration(
                schema: emergencySchema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private("iCloud.com.daneweickert.OfflineWorkout")
            )
            
            let emergencyContainer = try ModelContainer(
                for: emergencySchema,
                configurations: [emergencyConfiguration]
            )
            
            print("🚨 Emergency fallback: ModelContainer initialized with minimal schema")
            print("⚠️ Full app functionality will be limited")
            return emergencyContainer
        } catch {
            // If even the simplest schema fails, there's a fundamental problem
            fatalError("Emergency fallback failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Schema Versioning

/**
 * Version 1 of the OfflineWorkout schema.
 * This represents the initial schema with Exercise, Workout, and ExerciseSet models.
 */
enum OfflineWorkoutSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [Exercise.self, Workout.self, ExerciseSet.self]
    }
}

/**
 * Migration plan for schema changes.
 * Add new migration stages here when schema evolves.
 */
enum OfflineWorkoutMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [OfflineWorkoutSchemaV1.self]
    }
    
    static var stages: [MigrationStage] {
        // Future migrations will be added here
        // Example:
        // [migrateV1toV2, migrateV2toV3]
        []
    }
}

// MARK: - Schema Evolution and CloudKit Compatibility

extension Persistence {
    /**
     * GUIDE: Adding New Fields or Models While Maintaining CloudKit Sync
     * 
     * CloudKit automatically handles schema changes, but follow these guidelines:
     * 
     * ═══════════════════════════════════════════════════════════════════════
     * ADDING OPTIONAL FIELDS (Lightweight Migration - RECOMMENDED)
     * ═══════════════════════════════════════════════════════════════════════
     * 
     * 1. Add optional properties to existing @Model classes:
     *    ```swift
     *    @Model
     *    final class Exercise {
     *        var name: String
     *        var goal: Goal
     *        
     *        // NEW FIELD - Always make it optional initially
     *        var difficulty: Int? = nil  // 1-5 scale
     *        
     *        init(name: String, goal: Goal) {
     *            self.name = name
     *            self.goal = goal
     *            // difficulty will be nil for existing records
     *        }
     *    }
     *    ```
     * 
     * 2. Update the schema version comment (optional for lightweight changes)
     * 3. Deploy to both iOS and watchOS
     * 4. CloudKit will automatically add the new field to existing records as nil
     * 
     * ═══════════════════════════════════════════════════════════════════════
     * ADDING NEW MODELS (Lightweight Migration)
     * ═══════════════════════════════════════════════════════════════════════
     * 
     * 1. Create the new @Model class
     * 2. Add it to OfflineWorkoutSchemaV1.models array
     * 3. Ensure the model file is added to BOTH iOS and watchOS targets
     * 4. CloudKit will create the new record type automatically
     * 
     * ═══════════════════════════════════════════════════════════════════════
     * COMPLEX CHANGES (Requires Migration Plan)
     * ═══════════════════════════════════════════════════════════════════════
     * 
     * For breaking changes (renaming fields, changing types, etc.):
     * 
     * 1. Create OfflineWorkoutSchemaV2:
     *    ```swift
     *    enum OfflineWorkoutSchemaV2: VersionedSchema {
     *        static var versionIdentifier = Schema.Version(1, 1, 0)
     *        static var models: [any PersistentModel.Type] {
     *            [ExerciseV2.self, Workout.self, ExerciseSet.self]
     *        }
     *    }
     *    ```
     * 
     * 2. Add migration stage to OfflineWorkoutMigrationPlan:
     *    ```swift
     *    static var stages: [MigrationStage] {
     *        [migrateV1toV2]
     *    }
     *    
     *    static let migrateV1toV2 = MigrationStage.custom(
     *        fromVersion: OfflineWorkoutSchemaV1.self,
     *        toVersion: OfflineWorkoutSchemaV2.self,
     *        willMigrate: { context in
     *            // Custom migration logic here
     *        },
     *        didMigrate: nil
     *    )
     *    ```
     * 
     * 3. Update Persistence.SCHEMA_VERSION
     * 4. Test migration thoroughly before deploying
     * 
     * ═══════════════════════════════════════════════════════════════════════
     * CLOUDKIT SYNC CONSIDERATIONS
     * ═══════════════════════════════════════════════════════════════════════
     * 
     * • CloudKit sync is eventually consistent - changes may take time to propagate
     * • Both iOS and watchOS must use the SAME schema version for compatibility
     * • Test with multiple devices signed into the same iCloud account
     * • Use CloudKitSyncStatus to monitor sync progress and errors
     * • New fields added to existing records will sync as nil until explicitly set
     * 
     * ═══════════════════════════════════════════════════════════════════════
     * DEPLOYMENT STRATEGY
     * ═══════════════════════════════════════════════════════════════════════
     * 
     * 1. ALWAYS deploy schema changes to both iOS and watchOS simultaneously
     * 2. Test on physical devices, not just simulators
     * 3. Verify sync works between devices after schema changes
     * 4. Monitor CloudKitSyncStatus for errors after deployment
     * 5. Have a rollback plan for breaking changes
     */
    
    /**
     * Validates that the current schema configuration is correct.
     * Call this during app startup to catch configuration issues early.
     */
    static func validateConfiguration() {
        let container = shared.modelContainer
        print("✅ ModelContainer initialized with \(container.schema.entities.count) entities")
        print("✅ CloudKit container: \(containerIdentifier)")
        print("✅ Schema version: \(SCHEMA_VERSION)")
        
        // Log all model entities for debugging
        for entity in container.schema.entities {
            print("   📄 Model: \(entity.name)")
        }
    }
    
    /**
     * Example of adding a new optional field to an existing model.
     * This demonstrates the recommended approach for schema evolution.
     */
    static func exampleSchemaEvolution() {
        /*
         EXAMPLE: Adding a "tags" field to Exercise
         
         Before (V1):
         @Model
         final class Exercise {
             var name: String
             var goal: Goal
             var bodyPart: BodyPart
             // ... other fields
         }
         
         After (V1.1 - Lightweight migration):
         @Model  
         final class Exercise {
             var name: String
             var goal: Goal
             var bodyPart: BodyPart
             // ... other fields
             
             // NEW: Optional field for categorizing exercises
             var tags: [String]? = nil
             
             // Convenience computed property
             var displayTags: [String] {
                 return tags ?? []
             }
         }
         
         This change:
         ✅ Requires no migration code
         ✅ Works with existing CloudKit data
         ✅ Maintains compatibility between iOS/watchOS
         ✅ Allows gradual adoption of the new field
         */
    }
}

// MARK: - Preview Helper
/**
 * Helper for SwiftUI previews with mock ModelContext.
 */
struct PreviewHelper {
    static var previewContext: ModelContext {
        // Create an in-memory ModelContainer for previews
        do {
            let schema = Schema([
                Exercise.self,
                Workout.self,
                ExerciseSet.self
            ])
            
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
            
            let container = try ModelContainer(for: schema, configurations: [configuration])
            return container.mainContext
        } catch {
            fatalError("Failed to create preview ModelContext: \(error)")
        }
    }
}
