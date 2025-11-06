//
//  Item.swift
//  OfflineWorkout
//
//  Created by Dane Weickert on 9/22/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    // CloudKit requires all attributes to be optional or have default values
    var timestamp: Date = Date()
    
    init(timestamp: Date = Date()) {
        self.timestamp = timestamp
    }
}
