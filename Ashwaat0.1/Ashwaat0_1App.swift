import SwiftUI
import SwiftData
import CoreMotion
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
    }

    var body: some Scene {
        WindowGroup {
            tawaf()
                .environmentObject(locationManager)
                .environmentObject(trackingManager)
                .environmentObject(watchConnectivityManager)
                .modelContainer(modelContainer) // ✅ Inject modelContainer here!
        }
    }
}
