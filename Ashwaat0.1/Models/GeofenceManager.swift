import Foundation
import CoreLocation

protocol GeofenceManagerDelegate: AnyObject {
    func didEnterGeofence(identifier: String)
    func didExitGeofence(identifier: String)
}

final class GeofenceMainManager: NSObject, CLLocationManagerDelegate {
    static let shared = GeofenceMainManager()

    private let locationManager = CLLocationManager()
    weak var delegate: GeofenceManagerDelegate?

    private var lastKnownGeofenceStates: [String: Bool] = [:]

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1.0
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    var monitoredRegions: Set<CLRegion> {
        return locationManager.monitoredRegions
    }
    
    func startMonitoring() {
        locationManager.requestAlwaysAuthorization()

        // Masjid al-Haram
        addRegion(identifier: "haram_main", center: CLLocationCoordinate2D(latitude: 24.78676046638857, longitude: 46.797685303859474), radius: 150)

        // Tawaf Zones
        addRegion(identifier: "tawaf_ground", center: tawafCenter, radius: 20)
        addRegion(identifier: "tawaf_first", center: tawafCenter, radius: 25)
        addRegion(identifier: "tawaf_second", center: tawafCenter, radius: 30)
        addRegion(identifier: "tawaf_third", center: tawafCenter, radius: 35)
        addRegion(identifier: "tawaf_roof", center: tawafCenter, radius: 40)

        // Sa’i Zones
        addRegion(identifier: "sai_ground", center: CLLocationCoordinate2D(latitude: 21.4221, longitude: 39.8272), radius: 10)
        addRegion(identifier: "sai_first", center: CLLocationCoordinate2D(latitude: 21.4221, longitude: 39.8272), radius: 15)
        addRegion(identifier: "sai_second", center: CLLocationCoordinate2D(latitude: 21.4221, longitude: 39.8272), radius: 15)

        // Start location updates to get initial fix
        locationManager.startUpdatingLocation()
    }

    private var tawafCenter: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 24.78676046638857, longitude: 46.797685303859474)
    }

    private func addRegion(identifier: String, center: CLLocationCoordinate2D, radius: CLLocationDistance) {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            print("❌ Geofencing not supported on this device.")
            return
        }

        let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true

        locationManager.startMonitoring(for: region)
        print("📍 Started monitoring region: \(identifier)")
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("✅ Entered region: \(region.identifier)")
        delegate?.didEnterGeofence(identifier: region.identifier)
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("🚪 Exited region: \(region.identifier)")
        delegate?.didExitGeofence(identifier: region.identifier)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❗️ Location Manager Error: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("⚠️ Failed to monitor region: \(region?.identifier ?? "unknown") — \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        print("📍 Updated user location: \(latestLocation.coordinate.latitude), \(latestLocation.coordinate.longitude)")
        checkCurrentGeofenceStatus(with: latestLocation)
    }

    private func checkCurrentGeofenceStatus(with location: CLLocation) {
        for region in locationManager.monitoredRegions {
            if let circular = region as? CLCircularRegion {
                let inside = circular.contains(location.coordinate)
                let lastState = lastKnownGeofenceStates[region.identifier]

                if lastState == nil || lastState != inside {
                    if inside {
                        print("📍 [Live Check] Inside region: \(region.identifier)")
                        delegate?.didEnterGeofence(identifier: region.identifier)
                    } else {
                        print("🚪 [Live Check] Outside region: \(region.identifier)")
                        delegate?.didExitGeofence(identifier: region.identifier)
                    }
                    lastKnownGeofenceStates[region.identifier] = inside
                }
            }
        }
    }
}
