//
//  TrackerAttributes.swift
//  Ashwaat
//
//  Created by Ashwaq on 27/11/1446 AH.
//

import Foundation
import ActivityKit
struct TrackerAttributes: ActivityAttributes {
    // ContentState is required and contains the dynamic data
    public struct ContentState: Codable, Hashable {
        // Dynamic data that will change during the Live Activity
        var currentLap: Int
        var elapsedTime: TimeInterval
        var isActive: Bool
        var lapProgress: Double
    }
    
    // Static data that won't change during the Live Activity
    var totalLaps: Int = 7  // For Tawaaf
    var startTime: Date
}
