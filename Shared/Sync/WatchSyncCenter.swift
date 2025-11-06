import Foundation
import SwiftData

#if canImport(WatchConnectivity)
import WatchConnectivity

/**
 * Provides lightweight, bidirectional sync between iOS and watchOS using WatchConnectivity.
 * This complements CloudKit so that simulator-to-simulator sync works even when iCloud isn't available.
 */
final class WatchSyncCenter: NSObject {
    static let shared = WatchSyncCenter()

    private var modelContext: ModelContext?

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Public API (Upserts)

    func upsertExercise(_ exercise: Exercise) {
        #if os(watchOS)
        print("🔄 [WATCH] WatchSyncCenter: Syncing exercise '\(exercise.name)' to iOS")
        #else
        print("🔄 [iOS] WatchSyncCenter: Syncing exercise '\(exercise.name)' to Watch")
        #endif
        let dto = ExerciseDTO(from: exercise)
        let json = encode(dto)
        print("   📋 Exercise DTO: id=\(dto.id), name=\(dto.name)")
        send(messageType: "exerciseUpsert", json: json)
    }

    func deleteExercise(id: UUID) {
        send(messageType: "exerciseDelete", json: encode(["id": id.uuidString]))
    }

    func upsertWorkout(_ workout: Workout) {
        print("🔄 WatchSyncCenter: Syncing workout \(workout.id)")
        let dto = WorkoutDTO(from: workout)
        send(messageType: "workoutUpsert", json: encode(dto))
    }

    func deleteWorkout(id: UUID) {
        send(messageType: "workoutDelete", json: encode(["id": id.uuidString]))
    }

    func upsertExerciseSet(_ set: ExerciseSet) {
        let dto = ExerciseSetDTO(from: set)
        send(messageType: "exerciseSetUpsert", json: encode(dto))
    }

    func deleteExerciseSet(id: UUID) {
        send(messageType: "exerciseSetDelete", json: encode(["id": id.uuidString]))
    }

    // MARK: - Transport

    private func send(messageType: String, json: String) {
        guard WCSession.isSupported() else {
            print("❌ WatchConnectivity not supported")
            return
        }
        
        let payload: [String: Any] = [
            "type": messageType,
            "json": json,
            "timestamp": Date().timeIntervalSince1970
        ]

        #if os(watchOS)
        print("📤 [WATCH→iOS] Sending: \(messageType), isReachable: \(WCSession.default.isReachable)")
        #else
        print("📤 [iOS→WATCH] Sending: \(messageType), isReachable: \(WCSession.default.isReachable)")
        #endif
        print("   - activationState: \(WCSession.default.activationState.rawValue)")
        
        if WCSession.default.isReachable {
            print("   - Using sendMessage (immediate)")
            WCSession.default.sendMessage(payload, replyHandler: { response in
                print("✅ Message sent successfully: \(messageType)")
            }, errorHandler: { error in
                print("❌ Error sending message: \(error.localizedDescription)")
                print("   - Falling back to transferUserInfo")
                WCSession.default.transferUserInfo(payload)
            })
        } else {
            print("   - Using transferUserInfo (not reachable, will sync in background)")
            WCSession.default.transferUserInfo(payload)
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchSyncCenter: WCSessionDelegate {
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { WCSession.default.activate() }
    #endif

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("❌ WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("✅ WCSession activated: \(activationState.rawValue)")
            #if os(iOS)
            print("   - isPaired: \(session.isPaired)")
            print("   - isWatchAppInstalled: \(session.isWatchAppInstalled)")
            #endif
            print("   - isReachable: \(session.isReachable)")
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        #if os(watchOS)
        print("🔄 [WATCH] Reachability changed: isReachable = \(session.isReachable)")
        #else
        print("🔄 [iOS] Reachability changed: isReachable = \(session.isReachable)")
        #endif
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        #if os(watchOS)
        print("📥 [WATCH] Received message via sendMessage from iOS (no reply)")
        #else
        print("📥 [iOS] Received message via sendMessage from Watch (no reply)")
        #endif
        if let type = message["type"] as? String {
            print("   📋 Message type: \(type)")
        }
        apply(message: message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        #if os(watchOS)
        print("📥 [WATCH] Received message via sendMessage from iOS (with reply)")
        #else
        print("📥 [iOS] Received message via sendMessage from Watch (with reply)")
        #endif
        if let type = message["type"] as? String {
            print("   📋 Message type: \(type)")
        }
        apply(message: message)
        // Send acknowledgment
        replyHandler(["status": "received"])
        print("   ✅ Sent reply acknowledgment")
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        #if os(watchOS)
        print("📥 [WATCH] Received message via transferUserInfo from iOS")
        #else
        print("📥 [iOS] Received message via transferUserInfo from Watch")
        #endif
        if let type = userInfo["type"] as? String {
            print("   📋 Message type: \(type)")
        }
        apply(message: userInfo)
    }

    private func apply(message: [String: Any]) {
        guard let type = message["type"] as? String,
              let json = message["json"] as? String,
              let context = modelContext else {
            print("❌ Invalid message format or no context")
            return
        }
        
        print("📥 Processing message type: \(type)")

        switch type {
        case "exerciseUpsert":
            if let dto: ExerciseDTO = decode(json) {
                Task { @MainActor in
                    self.upsertExercise(dto, in: context)
                }
            }
        case "exerciseDelete":
            if let payload: DeleteDTO = decode(json), let id = UUID(uuidString: payload.id) {
                Task { @MainActor in
                    self.deleteExercise(id: id, in: context)
                }
            }
        case "workoutUpsert":
            if let dto: WorkoutDTO = decode(json) {
                Task { @MainActor in
                    self.upsertWorkout(dto, in: context)
                }
            }
        case "workoutDelete":
            if let payload: DeleteDTO = decode(json), let id = UUID(uuidString: payload.id) {
                Task { @MainActor in
                    self.deleteWorkout(id: id, in: context)
                }
            }
        case "exerciseSetUpsert":
            if let dto: ExerciseSetDTO = decode(json) {
                Task { @MainActor in
                    self.upsertExerciseSet(dto, in: context)
                }
            }
        case "exerciseSetDelete":
            if let payload: DeleteDTO = decode(json), let id = UUID(uuidString: payload.id) {
                Task { @MainActor in
                    self.deleteExerciseSet(id: id, in: context)
                }
            }
        default:
            break
        }
    }
}

// MARK: - DTOs

private struct DeleteDTO: Codable { let id: String }

private struct ExerciseDTO: Codable {
    let id: String
    let name: String
    let goal: String?
    let bodyPart: String?
    let muscles: [String]
    let allowedMetrics: [String]
    let createdAt: Double
    let difficulty: Int?

    init(from model: Exercise) {
        self.id = model.id.uuidString
        self.name = model.name
        self.goal = model.goal?.rawValue
        self.bodyPart = model.bodyPart?.rawValue
        self.muscles = model.muscles
        self.allowedMetrics = model.allowedMetrics.map { $0.rawValue }
        self.createdAt = model.createdAt.timeIntervalSince1970
        self.difficulty = model.difficulty
    }
}

private struct WorkoutDTO: Codable {
    let id: String
    let startedAt: Double
    let endedAt: Double?
    let note: String?

    init(from model: Workout) {
        self.id = model.id.uuidString
        self.startedAt = model.startedAt.timeIntervalSince1970
        self.endedAt = model.endedAt?.timeIntervalSince1970
        self.note = model.note
    }
}

private struct ExerciseSetDTO: Codable {
    let id: String
    let timestamp: Double
    let workoutId: String?
    let exerciseId: String?
    let reps: Int?
    let weightLbs: Double?
    let durationSeconds: Int?
    let distanceMeters: Double?
    let steps: Int?
    let isBodyweight: Bool
    let painLevel: Int?
    let rangeOfMotion: Int?

    init(from model: ExerciseSet) {
        self.id = model.id.uuidString
        self.timestamp = model.timestamp.timeIntervalSince1970
        self.workoutId = model.workout?.id.uuidString
        self.exerciseId = model.exercise?.id.uuidString
        self.reps = model.reps
        self.weightLbs = model.weightLbs
        self.durationSeconds = model.durationSeconds
        self.distanceMeters = model.distanceMeters
        self.steps = model.steps
        self.isBodyweight = model.isBodyweight
        self.painLevel = model.painLevel
        self.rangeOfMotion = model.rangeOfMotion
    }
}

// MARK: - Apply DTOs into SwiftData

private extension WatchSyncCenter {
    func upsertExercise(_ dto: ExerciseDTO, in context: ModelContext) {
        let id = UUID(uuidString: dto.id) ?? UUID()
        let predicate = #Predicate<Exercise> { $0.id == id }
        let descriptor = FetchDescriptor<Exercise>(predicate: predicate)
        let existing = try? context.fetch(descriptor).first

        let model = existing ?? Exercise(name: dto.name)
        model.id = id
        model.name = dto.name
        model.goal = dto.goal.flatMap { Goal(rawValue: $0) }
        model.bodyPart = dto.bodyPart.flatMap { BodyPart(rawValue: $0) }
        model.muscles = dto.muscles
        model.allowedMetrics = dto.allowedMetrics.compactMap { MetricType(rawValue: $0) }
        model.createdAt = Date(timeIntervalSince1970: dto.createdAt)
        model.difficulty = dto.difficulty

        if existing == nil { 
            context.insert(model)
            print("✅ Inserted new exercise: \(model.name)")
        } else {
            print("✅ Updated existing exercise: \(model.name)")
        }
        
        do {
            try context.save()
            print("✅ Exercise saved to database: \(model.name)")
            // Post notification to refresh UI
            NotificationCenter.default.post(name: NSNotification.Name("ExerciseDataDidChange"), object: nil)
        } catch {
            print("❌ Failed to save exercise: \(error)")
        }
    }

    func deleteExercise(id: UUID, in context: ModelContext) {
        let predicate = #Predicate<Exercise> { $0.id == id }
        let descriptor = FetchDescriptor<Exercise>(predicate: predicate)
        if let model = try? context.fetch(descriptor).first {
            let exerciseName = model.name
            context.delete(model)
            do {
                try context.save()
                print("✅ Deleted exercise from database: \(exerciseName)")
                // Post notification to refresh UI
                NotificationCenter.default.post(name: NSNotification.Name("ExerciseDataDidChange"), object: nil)
            } catch {
                print("❌ Failed to delete exercise: \(error)")
            }
        } else {
            print("⚠️ Exercise with id \(id) not found for deletion")
        }
    }

    func upsertWorkout(_ dto: WorkoutDTO, in context: ModelContext) {
        let id = UUID(uuidString: dto.id) ?? UUID()
        let predicate = #Predicate<Workout> { $0.id == id }
        let descriptor = FetchDescriptor<Workout>(predicate: predicate)
        let existing = try? context.fetch(descriptor).first

        let model = existing ?? Workout(startedAt: Date(timeIntervalSince1970: dto.startedAt))
        model.id = id
        model.startedAt = Date(timeIntervalSince1970: dto.startedAt)
        model.endedAt = dto.endedAt.map { Date(timeIntervalSince1970: $0) }
        model.note = dto.note

        if existing == nil { 
            context.insert(model)
            print("✅ Inserted new workout: \(model.id)")
        } else {
            print("✅ Updated existing workout: \(model.id)")
        }
        
        do {
            try context.save()
            print("✅ Workout saved to database")
            // Post notification to refresh UI
            NotificationCenter.default.post(name: NSNotification.Name("WorkoutDataDidChange"), object: nil)
        } catch {
            print("❌ Failed to save workout: \(error)")
        }
    }

    func deleteWorkout(id: UUID, in context: ModelContext) {
        let predicate = #Predicate<Workout> { $0.id == id }
        let descriptor = FetchDescriptor<Workout>(predicate: predicate)
        if let model = try? context.fetch(descriptor).first {
            context.delete(model)
            do {
                try context.save()
                print("✅ Deleted workout from database: \(id)")
                // Post notification to refresh UI
                NotificationCenter.default.post(name: NSNotification.Name("WorkoutDataDidChange"), object: nil)
            } catch {
                print("❌ Failed to delete workout: \(error)")
            }
        } else {
            print("⚠️ Workout with id \(id) not found for deletion")
        }
    }

    func upsertExerciseSet(_ dto: ExerciseSetDTO, in context: ModelContext) {
        let id = UUID(uuidString: dto.id) ?? UUID()
        let predicate = #Predicate<ExerciseSet> { $0.id == id }
        let descriptor = FetchDescriptor<ExerciseSet>(predicate: predicate)
        let existing = try? context.fetch(descriptor).first

        let model = existing ?? ExerciseSet()
        model.id = id
        model.timestamp = Date(timeIntervalSince1970: dto.timestamp)

        if let workoutIdString = dto.workoutId, let workoutId = UUID(uuidString: workoutIdString) {
            let wp = #Predicate<Workout> { $0.id == workoutId }
            let wd = FetchDescriptor<Workout>(predicate: wp)
            model.workout = try? context.fetch(wd).first
        }
        if let exerciseIdString = dto.exerciseId, let exerciseId = UUID(uuidString: exerciseIdString) {
            let ep = #Predicate<Exercise> { $0.id == exerciseId }
            let ed = FetchDescriptor<Exercise>(predicate: ep)
            model.exercise = try? context.fetch(ed).first
        }

        model.reps = dto.reps
        model.weightLbs = dto.weightLbs
        model.durationSeconds = dto.durationSeconds
        model.distanceMeters = dto.distanceMeters
        model.steps = dto.steps
        model.isBodyweight = dto.isBodyweight
        model.painLevel = dto.painLevel
        model.rangeOfMotion = dto.rangeOfMotion

        if existing == nil { 
            context.insert(model)
            print("✅ Inserted new exercise set")
        } else {
            print("✅ Updated existing exercise set")
        }
        
        do {
            try context.save()
            print("✅ Exercise set saved to database")
            // Post notification to refresh UI since sets are part of workouts
            NotificationCenter.default.post(name: NSNotification.Name("WorkoutDataDidChange"), object: nil)
        } catch {
            print("❌ Failed to save exercise set: \(error)")
        }
    }

    func deleteExerciseSet(id: UUID, in context: ModelContext) {
        let predicate = #Predicate<ExerciseSet> { $0.id == id }
        let descriptor = FetchDescriptor<ExerciseSet>(predicate: predicate)
        if let model = try? context.fetch(descriptor).first {
            context.delete(model)
            do {
                try context.save()
                print("✅ Deleted exercise set from database")
                // Post notification to refresh UI since sets are part of workouts
                NotificationCenter.default.post(name: NSNotification.Name("WorkoutDataDidChange"), object: nil)
            } catch {
                print("❌ Failed to delete exercise set: \(error)")
            }
        } else {
            print("⚠️ Exercise set with id \(id) not found for deletion")
        }
    }
}

// MARK: - JSON helpers

private func encode<T: Encodable>(_ value: T) -> String {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .secondsSince1970
    let data = try? encoder.encode(value)
    return String(data: data ?? Data(), encoding: .utf8) ?? "{}"
}

private func decode<T: Decodable>(_ json: String) -> T? {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    guard let data = json.data(using: .utf8) else { return nil }
    return try? decoder.decode(T.self, from: data)
}

#endif


