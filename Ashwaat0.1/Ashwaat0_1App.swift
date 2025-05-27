//
//  Ashwaat0_1App.swift
//  Ashwaat0.1
//
//  Created by Maryam Amer Bin Siddique on 09/11/1446 AH.
//

import SwiftUI
import AppIntents
import SwiftData
import CoreMotion
import CoreLocation
import WatchConnectivity

@main
struct Ashwaat0_1App: App {
    let locationManager = LocationManager()
    let trackingManager: TrackingManager
    let modelContainer: ModelContainer
    let watchConnectivityManager = WatchConnectivityManager.shared

    init() {
        self.modelContainer = try! ModelContainer(for: TawafSession.self)
        let modelContext = modelContainer.mainContext
        self.trackingManager = TrackingManager(locationManager: locationManager, modelContext: modelContext)

        // ✅ Start geofencing logic
        GeofenceMainManager.shared.delegate = trackingManager
        GeofenceMainManager.shared.startMonitoring()
    }

    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environmentObject(locationManager)
                .environmentObject(trackingManager)
                .environmentObject(watchConnectivityManager)
                .modelContainer(modelContainer)
        }
    }
}
