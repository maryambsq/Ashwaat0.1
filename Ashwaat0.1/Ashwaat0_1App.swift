//
//  Ashwaat0_1App.swift
//  Ashwaat0.1
//
//  Created by Maryam Amer Bin Siddique on 09/11/1446 AH.
//

import SwiftUI
import SwiftData
import CoreMotion
import WatchConnectivity

@main
struct Ashwaat0_1App: App {
    let locationManager = LocationManager()
    let trackingManager: TrackingManager
    let watchConnectivityManager = WatchConnectivityManager.shared
    
    init() {
        let modelContainer = try! ModelContainer(for: TawafData.self)
        let modelContext = modelContainer.mainContext
        self.trackingManager = TrackingManager(locationManager: locationManager, modelContext: modelContext)
    }
    
    var body: some Scene {
        WindowGroup {
            //AccessLocation()
            tawaf()
                .environmentObject(locationManager)
                .environmentObject(trackingManager)
                .environmentObject(watchConnectivityManager)
        }
    }
}
