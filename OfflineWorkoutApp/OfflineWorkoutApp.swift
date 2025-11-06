import SwiftUI
import SwiftData

/**
 * Main iOS app entry point for tracker.
 */
@main
struct OfflineWorkoutApp: App {
    init() {
        // Validate persistence configuration on app startup
        Persistence.validateConfiguration()
        // Configure simulator sync via WatchConnectivity
        WatchSyncCenter.shared.configure(modelContext: Persistence.shared.modelContainer.mainContext)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(Persistence.shared.modelContainer)
                .onAppear {
                    print("✅ App launched successfully")
                }
        }
    }
}

struct ContentView: View {
    @State private var hasError = false
    @State private var errorMessage = ""
    
    var body: some View {
        if hasError {
            ErrorView(message: errorMessage) {
                hasError = false
                errorMessage = ""
            }
        } else {
            RootTabView()
                .onAppear {
                    // Test that the model container is working
                    do {
                        let _ = Persistence.shared.modelContainer.mainContext
                        print("✅ Model context accessible")
                    } catch {
                        hasError = true
                        errorMessage = "Failed to initialize data storage: \(error.localizedDescription)"
                    }
                }
        }
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Initialization Error")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
