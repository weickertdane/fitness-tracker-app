//
//  TrackerWatchApp.swift
//  tracker Watch App
//
//  Created by Dane Weickert on 9/22/25.
//

import SwiftUI
import SwiftData

@main
struct TrackerWatch_Watch_AppApp: App {
    private let viewModel: WatchWorkoutViewModel = WatchWorkoutViewModel(modelContext: Persistence.shared.modelContainer.mainContext)
    
    var body: some Scene {
        WindowGroup {
            WatchAppRootView()
                .modelContainer(Persistence.shared.modelContainer)
                .environment(viewModel)
                .onAppear {
                    WatchSyncCenter.shared.configure(modelContext: Persistence.shared.modelContainer.mainContext)
                }
        }
    }
}