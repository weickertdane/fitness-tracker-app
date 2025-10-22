# OfflineWorkout - Setup Instructions

## Creating the Xcode Project

Since Xcode project files cannot be created programmatically, follow these steps to create the project:

### Step 1: Create New Xcode Project

1. Open Xcode
2. Choose "Create a new Xcode project"
3. Select **iOS** → **App**
4. Configure the project:
   - **Product Name**: `OfflineWorkout`
   - **Bundle Identifier**: `com.hardrockdigital.OfflineWorkout` (or your preferred identifier)
   - **Language**: Swift
   - **Interface**: SwiftUI
   - **Use Core Data**: ❌ (we're using SwiftData)
   - **Include Tests**: ✅

### Step 2: Add watchOS Target

1. In Xcode, go to **File** → **New** → **Target**
2. Select **watchOS** → **Watch App for iOS App**
3. Configure:
   - **Product Name**: `OfflineWorkoutWatch`
   - **Bundle Identifier**: `com.hardrockdigital.OfflineWorkout.watchkitapp`
   - **Language**: Swift
   - **Interface**: SwiftUI

### Step 3: Configure Capabilities

#### For iOS Target:
1. Select your iOS target in Project Navigator
2. Go to **Signing & Capabilities**
3. Click **+ Capability** and add:
   - **iCloud** → Enable CloudKit, use default container
   - **HealthKit**
   - **Background Modes** → Enable "Background fetch"

#### For watchOS Target:
1. Select your watchOS target
2. Go to **Signing & Capabilities**
3. Click **+ Capability** and add:
   - **iCloud** → Enable CloudKit, use the SAME container as iOS
   - **HealthKit**

### Step 4: Set Deployment Targets

- **iOS Target**: iOS 18.0 or later
- **watchOS Target**: watchOS 11.0 or later

### Step 5: Replace Generated Files

1. Delete the default `ContentView.swift` and `OfflineWorkoutApp.swift` files that Xcode created
2. Copy all the files from this directory structure into your Xcode project
3. Make sure to add files to the correct targets:
   - **Shared** folder: Add to both iOS and watchOS targets
   - **iOS** folder: Add to iOS target only
   - **watchOS** folder: Add to watchOS target only

### Step 6: Update Bundle Identifiers

Update the CloudKit container identifier in `Persistence.swift` to match your bundle identifier:

```swift
cloudKitDatabase: .private("iCloud.com.yourteam.OfflineWorkout")
```

### Step 7: Build and Test

1. Select the iOS scheme and build (⌘+B)
2. Select the watchOS scheme and build (⌘+B)
3. Both should build successfully

## Project Structure

```
OfflineWorkout/
├── Shared/
│   ├── Models/          # SwiftData models (to be implemented)
│   ├── Persistence/     # SwiftData + CloudKit setup
│   ├── Health/          # HealthKit integration (dormant)
│   └── Design/          # Theme and styling
├── iOS/
│   ├── Views/           # iPhone/iPad UI
│   └── ViewModels/      # iOS-specific view models
└── watchOS/
    ├── Views/           # Apple Watch UI
    └── ViewModels/      # watchOS-specific view models
```

## Next Steps

This completes **Prompt 1** from the build plan. The project structure is ready for:
- Prompt 2: Implementing SwiftData models
- Prompt 3: Configuring CloudKit sync
- Prompt 4: HealthKit scaffolding
- And subsequent UI implementation prompts

## Notes

- All files currently contain placeholder comments indicating which prompt will implement them
- The `Persistence.swift` file has basic CloudKit configuration but models will be added in Prompt 2
- Both apps will launch with simple placeholder UIs until the full implementation is complete

---

## 📱 Data Persistence & Sync Architecture

### How Your Data Persists

Your exercises and workouts are stored using **three layers of persistence** to ensure they never get lost, even during app updates:

#### 1. **Local Storage (SwiftData)**
- All data is stored locally on your device using SwiftData
- Survives app updates, restarts, and reinstalls (as long as you don't delete the app)
- Provides instant offline access to all exercises and workouts

#### 2. **CloudKit Sync (iCloud)**
- Automatically syncs data to iCloud in the background
- **Survives app deletion and reinstallation**
- Syncs between your iPhone and Apple Watch
- Syncs across all your devices signed into the same iCloud account
- CloudKit schema is versioned and migration-safe

#### 3. **WatchConnectivity (Real-time)**
- Provides instant bidirectional sync between iPhone and Watch
- Works even when iCloud is unavailable (e.g., simulators)
- Complements CloudKit for immediate updates

### What Persists Across App Updates

✅ **Exercises** - All custom exercises you create persist forever
✅ **Workouts** - Complete workout history with all sets
✅ **Settings** - User preferences and configurations

### Data Flow Examples

#### Creating an Exercise on Watch
```
1. User creates exercise on Watch
2. Saved to Watch's local SwiftData
3. WatchSyncCenter sends to iPhone (instant)
4. Saved to iPhone's local SwiftData
5. CloudKit uploads to iCloud (background)
6. Available on all your devices
```

#### Creating an Exercise on iPhone
```
1. User creates exercise on iPhone
2. Saved to iPhone's local SwiftData
3. WatchSyncCenter sends to Watch (instant)
4. Saved to Watch's local SwiftData
5. CloudKit uploads to iCloud (background)
6. Available on all your devices
```

### CloudKit Configuration

The app uses **Private CloudKit Database**:
- Container ID: `iCloud.com.daneweickert.OfflineWorkout`
- Automatic schema migration
- Conflict resolution: Last-write-wins
- All data is private to your iCloud account

### App Capabilities

#### iOS App (`OfflineWorkout`)
- ✅ Create & edit exercises
- ✅ View workout history
- ✅ Browse exercise library
- ❌ Cannot create/edit workouts (Watch-only)

#### Watch App (`OfflineWorkoutWatch`)
- ✅ Create & edit exercises
- ✅ Create & track workouts
- ✅ Add sets to workouts
- ✅ End workouts
- ✅ Browse exercise library

### Schema Versioning

Current schema version: **v1.0.0**

The app supports automatic lightweight migrations for:
- Adding optional fields to existing models
- Adding new models
- Renaming fields (with migration code)

See `Persistence.swift` for detailed migration guidelines.

### Troubleshooting Sync Issues

If exercises aren't syncing between devices:

1. **Check iCloud Sign-In**
   - Settings → iCloud → Make sure you're signed in
   
2. **Check iCloud Drive**
   - Settings → iCloud → iCloud Drive → Enable

3. **Refresh Manually**
   - Pull down on Exercise Library to refresh
   - Pull down on History view to refresh

4. **Check CloudKit Status**
   - Look at the sync status footer in History view
   - Green checkmark = synced
   - Orange spinner = syncing
   - Red error = sync issue

5. **Force Sync**
   - Close both apps completely
   - Reopen iOS app first, wait 10 seconds
   - Open Watch app
   - Data should sync automatically

### Data Privacy

- All data stays in your private iCloud account
- No data is sent to third-party servers
- HealthKit data (future feature) follows Apple's strict privacy guidelines
- You can delete all data by:
  1. Deleting the app from all devices
  2. Go to Settings → iCloud → Manage Storage → OfflineWorkout → Delete Data
