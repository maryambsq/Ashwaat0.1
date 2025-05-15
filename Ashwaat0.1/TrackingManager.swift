

import Foundation
import CoreMotion
import Combine
import CoreLocation
import simd
import SwiftData

class TrackingManager: ObservableObject {
    @Published var lapProgress: Double = 0.0 // Progress in percent (0–100%)
    
    // ... existing properties
    private let motionManager = CMMotionManager()
    private let pedometer = CMPedometer()
    private var timer: Timer?
    private var lastPosition: CLLocationCoordinate2D?
    //private var indoorSteps: Int = 0
    //private var indoorDistance: Double = 0.0
    //private var indoorLaps: Int = 0
    private var startTime: Date?
    
    // Location tracking variables
    private let locationManager: LocationManager
    private var lastLocation: CLLocation? = nil
    private var currentLocation: CLLocation?
    private var startLineLocation: CLLocation?
    private var kaabaCenterLocation: CLLocation?
    
    // SwiftData context
    private var modelContext: ModelContext?
    
    // MARK: - Angular Lap Tracking Logic

    // Define Kaaba center and start line globally or in your init
    private var previousAngle: Double?
    private let kaabaCoordinate = CLLocationCoordinate2D(latitude: 24.860870496480675, longitude: 24.860870496480675) // Demo coords
    private let startLineCoordinate = CLLocationCoordinate2D(latitude: 24.860872072775535, longitude: 46.72800847065588) // Demo coords

    // Track progress angle
    private var accumulatedAngle: Double = 0.0

    // Converts coordinate to vector relative to center
    private func angleFromKaaba(to location: CLLocationCoordinate2D) -> Double {
        let dx = location.longitude - kaabaCoordinate.longitude
        let dy = location.latitude - kaabaCoordinate.latitude
        return atan2(dy, dx)
    }
    
    func updateLapProgress(currentLocation: CLLocationCoordinate2D) {
        let currentAngle = angleFromKaaba(to: currentLocation)

        if let last = previousAngle {
            var delta = currentAngle - last
            if delta > .pi { delta -= 2 * .pi }
            if delta < -.pi { delta += 2 * .pi }

            accumulatedAngle += delta

            // Calculate progress as percentage
            let progress = min(abs(accumulatedAngle) / (2 * .pi), 1.0)
            lapProgress = progress * 100.0 // Percent value for UI

            if abs(accumulatedAngle) >= 2 * .pi {
                currentIndoorLaps += 1
                accumulatedAngle = 0
                print("✅ Lap Completed! Total: \(currentIndoorLaps)")
            }
        }

        previousAngle = currentAngle
    }

    // Add initializer
    init(locationManager: LocationManager, modelContext: ModelContext? = nil) {
        self.locationManager = locationManager
        self.modelContext = modelContext
    }
    
    @Published var isIndoorTrackingActive = false
    @Published var currentIndoorLaps = 0
    @Published var currentIndoorDistance = 0.0
    @Published var currentIndoorSteps = 0
    @Published var trackingError: String?
    @Published var lapStatus: String = "Ready to start"
    @Published var hasCrossedStartLine: Bool = false
    @Published var startLineAlert: String = ""
    @Published var lapTimingFeedback: String = ""
    @Published var isTawafComplete: Bool = false
    
    // Enhanced motion tracking variables
    private var isLapInProgress: Bool = false
    private var lapStartDistance: Double = 0.0
//    private var lastLapDistance: Double = 0.0
//    private var lapStartTime: Date?
//    private var lastLapTime: TimeInterval = 0.0
    private var lastStepCount: Int = 0
    private var lastDistance: Double = 0.0
//    private var lastTurnDirection: Double = 0.0
    private var turnCount: Int = 0
    private var lastTurnTime: Date?
//    private var lastAcceleration: CMAcceleration?
    private var stepLength: Double = 0.7
    private var stepConfidence: Double = 0.0
    
    // Rotation bounds and normalization
    private let maxRotation: Double = 2.0 * .pi * 100 // Maximum allowed rotation (100 full circles)
    private let minRotation: Double = -2.0 * .pi * 100 // Minimum allowed rotation
//    private let rotationNormalizationFactor: Double = 2.0 * .pi // Normalize to one full circle
    
    // Kalman filter variables for position estimation
    private var positionEstimate: (x: Double, y: Double) = (0.0, 0.0)
    private var positionCovariance: Double = 1.0
//    private var processNoise: Double = 0.1
//    private var measurementNoise: Double = 0.1
    
    // Motion history for pattern recognition
    private var motionHistory: [(acceleration: CMAcceleration, attitude: CMAttitude, timestamp: Date)] = []
//    private let motionHistorySize: Int = 10
    
    // Step detection thresholds
    private let minVerticalMovement: Double = 0.02
//    private let minTotalAcceleration: Double = 0.3
//    private let minAccelChange: Double = 0.01
//    private let minTimeBetweenSteps: TimeInterval = 0.05
//    private let minPitchChange: Double = 0.1
//    private let minRollChange: Double = 0.1
    private let stepPatternThreshold: Double = 0.5
    
    // Quaternion-based rotation tracking
//    private var currentQuaternion: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
//    private var lastQuaternion: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
//    private var accumulatedRotation: Double = 0.0
//    private var lastYaw: Double = 0.0
    private var rotationHistory: [Double] = []
    
    // Position tracking variables
    private var currentAngle: Double = 0.0
    private var lastPositionUpdate: Date?
//    private var positionHistory: [(x: Double, y: Double)] = []
    private var kaabaCenter: (x: Double, y: Double) = (0.0, 0.0)
    private let kaabaRadius: Double = 7.5 // meters (half of circumference)
    
    // Enhanced turn detection variables
    private var accelerationHistory: [CMAcceleration] = []
    private var lastRotationRate: CMRotationRate?
    private var totalRotation: Double = 0.0
    private var headingHistory: [Double] = []
    
    // Kaaba dimensions and thresholds
//    private let kaabaCircumference: Double = 15.0 // meters
    private let minLapDistance: Double = 20.0 // Minimum distance required for a valid lap (meters)
//    private let lapDetectionThreshold: Double = 10.0 // Distance threshold for start line detection
    private let minStepsPerLap: Int = 5
//    private let turnDetectionThreshold: Double = 0.8
//    private let minTimeBetweenTurns: TimeInterval = 2.0
//    private let minTimeBetweenLaps: TimeInterval = 10.0
    private let maxLaps: Int = 7
//    private let requiredRotation: Double = 2.0 * .pi // Full circle in radians
//    private let earlyLapThreshold: Double = 0.8 // 80% of required rotation
//    private let lateLapThreshold: Double = 1.2 // 120% of required rotation
//    private let rotationSmoothingFactor: Double = 0.1 // Smooth rotation changes
    
    // New variables for enhanced cycle detection
//    private var cycleStartAngle: Double = 0.0
    private var cycleProgress: Double = 0.0
//    private var lastCycleProgress: Double = 0.0
//    private var cycleDirection: Double = 0.0
//    private var cycleStartTime: Date?
//    private var cycleStartDistance: Double = 0.0
//    private var cycleStartSteps: Int = 0
//    private var isCycleInProgress: Bool = false
//    private var cycleCrossings: Int = 0
//    private let minCycleProgress: Double = 0.9 // 90% of full circle required
//    private let maxCycleProgress: Double = 1.1 // 110% of full circle allowed
//    
    // Kaaba center coordinates
    private let kaabaCenterLatitude: Double = 24.860810237081548
    private let kaabaCenterLongitude: Double = 46.727509656759025
    private let startLineLatitude: Double = 24.86064
    private let startLineLongitude: Double = 46.72768
    
    private let startLinePointA = CLLocationCoordinate2D(latitude: 24.860810237081548, longitude: 46.727509656759025)
    private let startLinePointB = CLLocationCoordinate2D(latitude: 24.86064, longitude: 46.72768)
    
    
    private var lastStartLineCrossing: CLLocation? = nil
//    private var lastLapRotation: Double = 0.0
//    private var completedRotations: Int = 0
//    private var lastAngle: Double = 0.0
    
    // Added for motion-based step detection
    private var lastStepTime: Date?
//    private var lastAttitude: CMAttitude?
    
    // Start line detection variables
//    private let startLineAngle: Double = 0.0 // Start line at 0 degrees
//    private let startLineThreshold: Double = 0.2 // Increased threshold to 0.2 radians (~11.5 degrees)
//    private var lastStartLineDistance: Double = 0.0
//    private var startLineCrossingCount: Int = 0
    private var lastStartLineCrossingTime: Date?
    private let minTimeBetweenCrossings: TimeInterval = 1.0 // Reduced to 1 second
//    private var lastCrossingDirection: Double = 0.0 // Track last crossing direction
    
    // Constants for Tawaf tracking
//    private let raceRadiusMeters: Double = 20.0 // Radius of the circle
//    private let startLineLength: Double = 5.0 // Length of the start line
    private var totalLapDistance: Double = 0.0
    private var hasStartedLap: Bool = false
    
    // Add auto-save timer
    private var autoSaveTimer: Timer?
    private let autoSaveInterval: TimeInterval = 30.0 // Save every 30 seconds
    
    // Enhanced location tracking
    private func setupLocationTracking() {
        locationManager.requestLocationPermission()
        locationManager.startLocationUpdates()
        
        // Create location objects for Kaaba and start line
        kaabaCenterLocation = CLLocation(
            latitude: kaabaCenterLatitude,
            longitude: kaabaCenterLongitude
        )
        startLineLocation = CLLocation(
            latitude: startLineLatitude,
            longitude: startLineLongitude
        )
    }
    
    
    let summaryNavigationDelay: TimeInterval = 5 // Change to 5 for faster transition if needed
    // Notification
    static let tawafCompletedNotification = Notification.Name("tawafCompleted")
    
    @Published var useMotionFallback: Bool = false
    
    // Track last known location accuracy
    private var lastLocationAccuracy: CLLocationAccuracy = 1000.0
    private let accuracyThreshold: CLLocationAccuracy = 15.0 // meters
    private let accuracyTimeout: TimeInterval = 10.0
    private var lastAccurateLocationTime: Date?
    
    @Published public var indoorSteps: Int = 0
    @Published public var indoorDistance: Double = 0.0
    @Published public var indoorLaps: Int = 0
    // Geofence state
    @Published var isInHaramRegion: Bool = false
    @Published var isInTawafZone: Bool = false
    @Published var isPausedDueToExit: Bool = false
    
    let geofenceManager = GeofenceMainManager.shared

    // Combined flag to enable/disable Tawaf tracking
    var isTrackingAllowed: Bool {
        return isInHaramRegion && isInTawafZone
    }
    
    private func linesIntersect(p1: CLLocationCoordinate2D, p2: CLLocationCoordinate2D,
                                q1: CLLocationCoordinate2D, q2: CLLocationCoordinate2D) -> Bool {
        func ccw(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D, _ c: CLLocationCoordinate2D) -> Bool {
            return (c.latitude - a.latitude) * (b.longitude - a.longitude) >
            (b.latitude - a.latitude) * (c.longitude - a.longitude)
        }
        return (ccw(p1, q1, q2) != ccw(p2, q1, q2)) &&
        (ccw(p1, p2, q1) != ccw(p1, p2, q2))
    }
    
    private func updateLapTracking() {
        guard let currentLocation = locationManager.currentUserLocation else { return }
        let currentLocationCL = CLLocation(latitude: currentLocation.coordinate.latitude,
                                           longitude: currentLocation.coordinate.longitude)
        let currentCoord = currentLocationCL.coordinate
        
        // ✅ Track location accuracy
        lastLocationAccuracy = currentLocation.horizontalAccuracy
        if lastLocationAccuracy <= accuracyThreshold {
            lastAccurateLocationTime = Date()
            useMotionFallback = false
        } else if let lastGoodTime = lastAccurateLocationTime,
                  Date().timeIntervalSince(lastGoodTime) > accuracyTimeout {
            useMotionFallback = true
        }
        
        // ✅ Use GPS-based line detection if accuracy is acceptable
        if !useMotionFallback {
            if let lastLoc = lastLocation {
                let lastCoord = lastLoc.coordinate
                let crossedLine = linesIntersect(p1: lastCoord, p2: currentCoord, q1: startLinePointA, q2: startLinePointB)
                
                if crossedLine {
                    let now = Date()
                    let timeSinceLast = now.timeIntervalSince(lastStartLineCrossingTime ?? .distantPast)
                    if timeSinceLast > minTimeBetweenCrossings {
                        lastStartLineCrossingTime = now
                        
                        if !hasCrossedStartLine {
                            hasCrossedStartLine = true
                            isLapInProgress = true
                            lapStartDistance = currentIndoorDistance
                            lastStepCount = currentIndoorSteps
                            totalLapDistance = 0.0
                            lapStatus = "Started lap"
                            startLineAlert = "✅ Crossed start line. Tawaf started."
                            hasStartedLap = true
                        } else {
                            if totalLapDistance >= minLapDistance {
                                currentIndoorLaps += 1
                                indoorLaps = currentIndoorLaps
                                lapStatus = "Lap \(currentIndoorLaps) completed!"
                                startLineAlert = "✅ Completed lap \(currentIndoorLaps)"
                                
                                if currentIndoorLaps >= maxLaps {
                                    lapStatus = "Tawaf Complete 🎉"
                                    isTawafComplete = true
                                    stopIndoorTracking()
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + summaryNavigationDelay) {
//                                        NotificationCenter.default.post(name: .tawafCompleted, object: nil)
//                                    }
                                }
                                
                                totalLapDistance = 0
                            } else {
                                startLineAlert = "Incomplete lap. Keep going."
                            }
                        }
                    }
                }
            }
        }
        
        if let lastLoc = lastLocation {
            let distanceFromLast = lastLoc.distance(from: currentLocationCL)
            currentIndoorDistance += distanceFromLast
            if hasStartedLap {
                totalLapDistance += distanceFromLast
            }
        }
        
        lastLocation = currentLocationCL
    }
    
    // ✅ Re-enable motion-based fallback inside updateMotionTracking
    private func updateMotionTracking(motion: CMDeviceMotion) {
        // ... existing Kalman filter, currentAngle, etc.
        
        if useMotionFallback && hasCrossedStartLine && isLapInProgress {
            let motionPattern = calculateMotionPattern()
            let rotationChange = motion.rotationRate.z * motionManager.deviceMotionUpdateInterval
            let previousAngle = currentAngle
            let newAngle = normalizeRotation(currentAngle - rotationChange)
            currentAngle = newAngle
            
            var angleDiff = newAngle - previousAngle
            if angleDiff > .pi { angleDiff -= 2.0 * .pi }
            else if angleDiff < -.pi { angleDiff += 2.0 * .pi }
            
            totalRotation += abs(angleDiff)
            totalRotation = min(totalRotation, 2.0 * .pi * 10)
            
            if totalRotation >= 2.0 * .pi * 0.98 && motionPattern > stepPatternThreshold {
                let currentStepCount = indoorSteps
                let stepsThisLap = currentStepCount - lastStepCount
                let distanceThisLap = indoorDistance - lapStartDistance
                
                if stepsThisLap >= minStepsPerLap && distanceThisLap >= minLapDistance {
                    indoorLaps += 1
                    currentIndoorLaps = indoorLaps
                    totalRotation = 0.0
                    lastStepCount = currentStepCount
                    lapStartDistance = indoorDistance
                    lapStatus = "Lap \(indoorLaps) completed! 🎉"
                    if indoorLaps >= maxLaps {
                        lapStatus = "Tawaf Complete 🎉"
                        isTawafComplete = true
                        stopIndoorTracking()
                       // DispatchQueue.main.asyncAfter(deadline: .now() + summaryNavigationDelay) {
                        //    NotificationCenter.default.post(name: .tawafCompleted, object: nil)
                        }
                    }

                }
            }
        }
   
    
    private func calculateMotionPattern() -> Double {
        guard motionHistory.count >= 3 else { return 0.0 }
        
        var patternScore = 0.0
        
        // Calculate acceleration pattern
        let recentAccelerations = motionHistory.suffix(3).map { $0.acceleration }
        let accelChanges = zip(recentAccelerations.dropFirst(), recentAccelerations).map { curr, prev in
            sqrt(pow(curr.x - prev.x, 2) + pow(curr.y - prev.y, 2) + pow(curr.z - prev.z, 2))
        }
        let avgAccelChange = accelChanges.reduce(0, +) / Double(accelChanges.count)
        patternScore += min(avgAccelChange / 0.5, 1.0)
        
        // Calculate attitude pattern
        let recentAttitudes = motionHistory.suffix(3).map { $0.attitude }
        let pitchChanges = zip(recentAttitudes.dropFirst(), recentAttitudes).map { curr, prev in
            abs(curr.pitch - prev.pitch)
        }
        let rollChanges = zip(recentAttitudes.dropFirst(), recentAttitudes).map { curr, prev in
            abs(curr.roll - prev.roll)
        }
        let avgPitchChange = pitchChanges.reduce(0, +) / Double(pitchChanges.count)
        let avgRollChange = rollChanges.reduce(0, +) / Double(rollChanges.count)
        patternScore += min(avgPitchChange / 0.2, 1.0)
        patternScore += min(avgRollChange / 0.2, 1.0)
        
        return patternScore / 3.0
    }
    
    private func normalizeRotation(_ angle: Double) -> Double {
        // First, bring the angle within reasonable bounds
        let boundedAngle = min(max(angle, minRotation), maxRotation)
        
        // Then normalize to 0-2π range
        let normalized = (boundedAngle + 2.0 * .pi).truncatingRemainder(dividingBy: 2.0 * .pi)
        return normalized
    }
    
    private func calculateAngleFromLocation(_ location: CLLocation) -> Double {
        guard let kaabaCenter = kaabaCenterLocation else { return 0.0 }
        
        // Calculate bearing from Kaaba center to current location
        let lat1 = kaabaCenter.coordinate.latitude * .pi / 180.0
        let lon1 = kaabaCenter.coordinate.longitude * .pi / 180.0
        let lat2 = location.coordinate.latitude * .pi / 180.0
        let lon2 = location.coordinate.longitude * .pi / 180.0
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x)
        
        // Convert bearing to 0-2π range
        return (bearing + 2.0 * .pi).truncatingRemainder(dividingBy: 2.0 * .pi)
    }
    
    private func calculateDistanceFromStartLine(_ location: CLLocation) -> Double {
        guard let startLine = startLineLocation else { return 0.0 }
        return location.distance(from: startLine)
    }
    
    func startIndoorTracking() {
        print("startIndoorTracking")
        guard motionManager.isDeviceMotionAvailable else {
            trackingError = "Device motion not available"
            return
        }
        
        guard CMPedometer.isStepCountingAvailable() else {
            trackingError = "Step counting not available"
            return
        }
        
        isIndoorTrackingActive = true
        trackingError = nil
        hasCrossedStartLine = false
        isLapInProgress = false
        lapStartDistance = 0.0
        lapStatus = "Ready to start"
        lastStepCount = 0
        lastDistance = 0.0
        turnCount = 0
        lastTurnTime = nil
        totalRotation = 0.0
        rotationHistory.removeAll()
        accelerationHistory.removeAll()
        headingHistory.removeAll()
        indoorSteps = 0
        currentIndoorSteps = 0
        lastStepTime = nil
        startTime = Date()
        
        // Start auto-save timer
        // startAutoSaveTimer()
        
        // Setup location tracking
        setupLocationTracking()
        
        // Print Kaaba and start line information
        print("🕋 Kaaba Center:")
        print("Latitude: \(kaabaCenterLatitude)")
        print("Longitude: \(kaabaCenterLongitude)")
        print("Start Line:")
        print("Latitude: \(startLineLatitude)")
        print("Longitude: \(startLineLongitude)")
        
        // Configure motion manager for high accuracy
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.gyroUpdateInterval = 0.1
        
        // Start pedometer updates
        pedometer.startUpdates(from: Date()) { [weak self] data, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.trackingError = error.localizedDescription
                }
                return
            }
            
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                let newSteps = data.numberOfSteps.intValue
                let stepsSinceLastUpdate = newSteps - self.lastStepCount
                self.lastStepCount = newSteps
                self.indoorSteps = newSteps
                self.currentIndoorSteps = newSteps
                
                // Calculate distance with dynamic step length
                let calculatedStepLength = self.calculateStepLength()
                let newDistance = Double(newSteps) * calculatedStepLength
                let distanceSinceLastUpdate = newDistance - self.lastDistance
                self.lastDistance = newDistance
                self.indoorDistance = newDistance
                self.currentIndoorDistance = newDistance
                
                // Update lap tracking with enhanced accuracy
                self.updateLapTracking()
                
                // Send data to watch if available
                WatchConnectivityManager.shared.sendIndoorTrackingData(
                    laps: self.indoorLaps,
                    distance: self.indoorDistance,
                    steps: self.indoorSteps
                )
            }
        }
        
        // Start device motion updates
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.trackingError = error.localizedDescription
                }
                return
            }
            
            guard let motion = motion else { return }
            
            // Update motion tracking
            self.updateMotionTracking(motion: motion)
        }
    }
    
    private func calculateStepLength() -> Double {
        // Calculate step length based on acceleration patterns
        if accelerationHistory.count >= 3 {
            let recentAccelerations = accelerationHistory.suffix(3)
            let verticalAcceleration = recentAccelerations.map { $0.z }.reduce(0, +) / 3.0
            
            // Adjust step length based on vertical movement
            if abs(verticalAcceleration) > 0.2 {
                stepConfidence += 0.1
            } else {
                stepConfidence -= 0.05
            }
            stepConfidence = min(max(stepConfidence, 0.0), 1.0)
            
            // Adjust step length based on confidence
            let adjustedStepLength = stepLength * (0.9 + 0.2 * stepConfidence)
            return min(max(adjustedStepLength, 0.6), 0.8)
        }
        return stepLength
    }
    //
    
    private func stopIndoorTracking() {
        motionManager.stopDeviceMotionUpdates()
        pedometer.stopUpdates()
        //locationManager.stopUpdatingLocation()
        
        isLapInProgress = false
        hasCrossedStartLine = false
        hasStartedLap = false
        
        lapStatus = "Tracking stopped."
        startLineAlert = ""
    }
    
    func resumeIndoorTracking() {
        guard !isIndoorTrackingActive else { return }

        isIndoorTrackingActive = true
        trackingError = nil
        lapStatus = "✅ Resumed tracking"

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }
            self.updateMotionTracking(motion: motion)
        }

        pedometer.startUpdates(from: startTime ?? Date()) { [weak self] data, error in
            guard let self = self, let data = data else { return }
            DispatchQueue.main.async {
                let newSteps = data.numberOfSteps.intValue
                let calculatedStepLength = self.calculateStepLength()
                let newDistance = Double(newSteps) * calculatedStepLength
                self.lastStepCount = newSteps
                self.indoorSteps = newSteps
                self.currentIndoorSteps = newSteps
                self.indoorDistance = newDistance
                self.currentIndoorDistance = newDistance
            }
        }
    }

   
}


extension TrackingManager: GeofenceManagerDelegate {
    
    func didEnterGeofence(identifier: String) {
            print("📍 didEnterGeofence → \(identifier)")

            if identifier == "haram_main" {
                isInHaramRegion = true
            } else if identifier.starts(with: "tawaf") {
                isInTawafZone = true
                print("✅ isInTawafZone = true from \(identifier)")

                if isPausedDueToExit {
                    resumeIndoorTracking()
                    isPausedDueToExit = false
                }
            }
        }

        func didExitGeofence(identifier: String) {
            print("🚪 didExitGeofence → \(identifier)")

            if identifier == "haram_main" {
                isInHaramRegion = false
                stopIndoorTracking()
                trackingError = "❌ You left Masjid al-Haram."
            } else if identifier.starts(with: "tawaf") {
                checkIfStillInTawafRegion()
            }
        }
   func checkIfStillInTawafRegion() {
       guard let currentLocation = locationManager.currentUserLocation else { return }

       let userCoordinate = currentLocation.coordinate

       let tawafRegions = geofenceManager.monitoredRegions
           .compactMap { $0 as? CLCircularRegion }
           .filter { $0.identifier.starts(with: "tawaf") }

       for region in tawafRegions {
           if region.contains(userCoordinate) {
               print("✅ Still inside region: \(region.identifier), keeping isInTawafZone = true")
               return
           }
       }

       // Fully outside all regions
       isInTawafZone = false
       print("❌ Fully outside all Tawaf zones — isInTawafZone = false")
       if isIndoorTrackingActive {
           stopIndoorTracking()
           isPausedDueToExit = true
           trackingError = "⚠️ You exited the Tawaf area. Tracking paused."
       }
   }



}


//extension Notification.Name {
//    static let tawafCompleted = Notification.Name("tawafCompleted")
//}
