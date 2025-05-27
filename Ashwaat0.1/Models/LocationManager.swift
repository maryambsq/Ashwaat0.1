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
    private var locationManager = CLLocationManager()
    
    @Published var currentUserLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var shouldOpenSettings = false
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.allowsBackgroundLocationUpdates = true
        checkAuthorization()
    }
    
    // MARK: - Authorization Methods
    func checkAuthorization() {
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
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
        switch locationManager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            default:
                break
        }
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Location Manager Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentUserLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error fetching location: \(error)")
    }
    
    // MARK: - Helper Methods
    func handleLocationAuthorization() {
        switch authorizationStatus {
        case .notDetermined:
            requestLocationPermission()
        case .denied, .restricted:
            shouldOpenSettings = true
        default:
            break
        }
    }
    
    func registerGeofences() {
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
            // Add other regions similarly...
        ]

        for region in geofences {
            region.notifyOnEntry = true
            region.notifyOnExit = true
            locationManager.startMonitoring(for: region)
        }
    }
}
