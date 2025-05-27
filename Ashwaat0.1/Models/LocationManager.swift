//
//  LocationManager.swift
//  Ashwaat0.1
//
//  Created by Wilson Chan on 2/2/24.
//

import Foundation
//1. Import CoreLocation Framework
import CoreLocation
import MapKit
import SwiftUI

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - Properties
    private var locationManager: CLLocationManager? = nil
    
    @Published var currentUserLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var shouldOpenSettings = false
    
    // MARK: - Initialization
    override init() {
        super.init()
        // DO NOT setup locationManager here to avoid triggering popup at splash
    }
    
    /// Call this manually only when location is needed
    func setupLocationManager() {
        if locationManager == nil {
            let manager = CLLocationManager()
            locationManager = manager
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.distanceFilter = kCLDistanceFilterNone
            manager.allowsBackgroundLocationUpdates = true
            manager.pausesLocationUpdatesAutomatically = false
        }
    }

    // MARK: - Authorization Methods

    func checkAuthorization() {
        setupLocationManager() // ensure manager exists
        authorizationStatus = CLLocationManager.authorizationStatus()
    }

    func requestLocationPermission() {
        setupLocationManager()
        locationManager?.requestWhenInUseAuthorization()
    }

    func handleLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            requestLocationPermission()
        case .denied, .restricted:
            shouldOpenSettings = true
        default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                currentUserLocation = nil
                startLocationUpdates()
            default:
                stopLocationUpdates()
        }
    }

    // MARK: - Location Updates

    func startLocationUpdates() {
        setupLocationManager()
        switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager?.startUpdatingLocation()
            case .notDetermined:
                requestLocationPermission()
            default:
                break
        }
    }

    func stopLocationUpdates() {
        locationManager?.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentUserLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error fetching location: \(error)")
    }

    // MARK: - Geofencing

    func registerGeofences() {
        setupLocationManager()

        let geofences = [
            CLCircularRegion(center: CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262),
                             radius: 150.0,
                             identifier: "haram_main"),
            CLCircularRegion(center: CLLocationCoordinate2D(latitude: 21.4227, longitude: 39.8263),
                             radius: 20.0,
                             identifier: "tawaf_ground"),
            CLCircularRegion(center: CLLocationCoordinate2D(latitude: 21.4227, longitude: 39.8263),
                             radius: 30.0,
                             identifier: "tawaf_first"),
            // Add more as needed
        ]

        for region in geofences {
            region.notifyOnEntry = true
            region.notifyOnExit = true
            locationManager?.startMonitoring(for: region)
        }
    }
}
