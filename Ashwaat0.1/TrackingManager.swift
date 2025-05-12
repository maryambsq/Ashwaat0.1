//
//  TrackingManager.swift
//  Ashwaat0.1
//
//  Created by Ashwaq on 13/11/1446 AH.
//

import Foundation
import CoreMotion
import Combine
import CoreLocation
import simd
import SwiftData

class TrackingManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private let pedometer = CMPedometer()
    private var timer: Timer?
    private var lastPosition: CLLocationCoordinate2D?
    private var indoorSteps: Int = 0
    private var indoorDistance: Double = 0.0
    private var indoorLaps: Int = 0
    private var startTime: Date?
    
    // Location tracking variables
    private let locationManager: LocationManager
    private var lastLocation: CLLocation? = nil
    private var currentLocation: CLLocation?
    private var startLineLocation: CLLocation?
    private var kaabaCenterLocation: CLLocation?
    
    // SwiftData context
    private var modelContext: ModelContext?
    
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
    private var lastLapDistance: Double = 0.0
    private var lapStartTime: Date?
    private var lastLapTime: TimeInterval = 0.0
    private var lastStepCount: Int = 0
    private var lastDistance: Double = 0.0
    private var lastTurnDirection: Double = 0.0
    private var turnCount: Int = 0
    private var lastTurnTime: Date?
    private var lastAcceleration: CMAcceleration?
    private var stepLength: Double = 0.7
    private var stepConfidence: Double = 0.0
    
    // Rotation bounds and normalization
    private let maxRotation: Double = 2.0 * .pi * 100 // Maximum allowed rotation (100 full circles)
    private let minRotation: Double = -2.0 * .pi * 100 // Minimum allowed rotation
    private let rotationNormalizationFactor: Double = 2.0 * .pi // Normalize to one full circle
    
    // Kalman filter variables for position estimation
    private var positionEstimate: (x: Double, y: Double) = (0.0, 0.0)
    private var positionCovariance: Double = 1.0
    private var processNoise: Double = 0.1
    private var measurementNoise: Double = 0.1
    
    // Motion history for pattern recognition
    private var motionHistory: [(acceleration: CMAcceleration, attitude: CMAttitude, timestamp: Date)] = []
    private let motionHistorySize: Int = 10
    
    // Step detection thresholds
    private let minVerticalMovement: Double = 0.02
    private let minTotalAcceleration: Double = 0.3
    private let minAccelChange: Double = 0.01
    private let minTimeBetweenSteps: TimeInterval = 0.05
    private let minPitchChange: Double = 0.1
    private let minRollChange: Double = 0.1
    private let stepPatternThreshold: Double = 0.5
    
    // Quaternion-based rotation tracking
    private var currentQuaternion: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    private var lastQuaternion: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    private var accumulatedRotation: Double = 0.0
    private var lastYaw: Double = 0.0
    private var rotationHistory: [Double] = []
    
    // Position tracking variables
    private var currentAngle: Double = 0.0
    private var lastPositionUpdate: Date?
    private var positionHistory: [(x: Double, y: Double)] = []
    private var kaabaCenter: (x: Double, y: Double) = (0.0, 0.0)
    private let kaabaRadius: Double = 7.5 // meters (half of circumference)
    
    // Enhanced turn detection variables
    private var accelerationHistory: [CMAcceleration] = []
    private var lastRotationRate: CMRotationRate?
    private var totalRotation: Double = 0.0
    private var headingHistory: [Double] = []
    
    // Kaaba dimensions and thresholds
    private let kaabaCircumference: Double = 15.0 // meters
    private let minLapDistance: Double = 100.0 // Minimum distance required for a valid lap (meters)
    private let lapDetectionThreshold: Double = 10.0 // Distance threshold for start line detection
    private let minStepsPerLap: Int = 5
    private let turnDetectionThreshold: Double = 0.8
    private let minTimeBetweenTurns: TimeInterval = 2.0
    private let minTimeBetweenLaps: TimeInterval = 10.0
    private let maxLaps: Int = 7
    private let requiredRotation: Double = 2.0 * .pi // Full circle in radians
    private let earlyLapThreshold: Double = 0.8 // 80% of required rotation
    private let lateLapThreshold: Double = 1.2 // 120% of required rotation
    private let rotationSmoothingFactor: Double = 0.1 // Smooth rotation changes
    
    // New variables for enhanced cycle detection
    private var cycleStartAngle: Double = 0.0
    private var cycleProgress: Double = 0.0
    private var lastCycleProgress: Double = 0.0
    private var cycleDirection: Double = 0.0
    private var cycleStartTime: Date?
    private var cycleStartDistance: Double = 0.0
    private var cycleStartSteps: Int = 0
    private var isCycleInProgress: Bool = false
    private var cycleCrossings: Int = 0
    private let minCycleProgress: Double = 0.9 // 90% of full circle required
    private let maxCycleProgress: Double = 1.1 // 110% of full circle allowed
    
    // Kaaba center coordinates
    private let kaabaCenterLatitude: Double = 24.860870496480675 //24.860870496480675//24.860810237081548
    private let kaabaCenterLongitude: Double = 24.860870496480675 //46.7282289611649//46.727509656759025
    private let startLineLatitude: Double = 24.860872072775535 //24.860681010858862//24.860872072775535 //24.86064/
    private let startLineLongitude: Double = 46.72800847065588 //46.727716325625636 //24.86064//46.72800847065588
    
    private var lastStartLineCrossing: CLLocation? = nil
    private var lastLapRotation: Double = 0.0
    private var completedRotations: Int = 0
    private var lastAngle: Double = 0.0
    
    // Added for motion-based step detection
    private var lastStepTime: Date?
    private var lastAttitude: CMAttitude?
    
    // Start line detection variables
    private let startLineAngle: Double = 0.0 // Start line at 0 degrees
    private let startLineThreshold: Double = 0.2 // Increased threshold to 0.2 radians (~11.5 degrees)
    private var lastStartLineDistance: Double = 0.0
    private var startLineCrossingCount: Int = 0
    private var lastStartLineCrossingTime: Date?
    private let minTimeBetweenCrossings: TimeInterval = 1.0 // Reduced to 1 second
    private var lastCrossingDirection: Double = 0.0 // Track last crossing direction
    
    // Constants for Tawaf tracking
    private let raceRadiusMeters: Double = 20.0 // Radius of the circle
    private let startLineLength: Double = 10.0 // Length of the start line
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
    
    private func updateMotionTracking(motion: CMDeviceMotion) {
        let rotationRate = motion.rotationRate
        let acceleration = motion.userAcceleration
        let gravity = motion.gravity
        let attitude = motion.attitude
        
        // Store motion data for pattern recognition
        motionHistory.append((acceleration: acceleration, attitude: attitude, timestamp: Date()))
        if motionHistory.count > motionHistorySize {
            motionHistory.removeFirst()
        }
        
        // Calculate motion patterns
        let motionPattern = calculateMotionPattern()
        
        // Update rotation tracking with Kalman filter
        let timeInterval = motionManager.deviceMotionUpdateInterval
        let rotationChange = rotationRate.z * timeInterval
        
        // Store previous angle for lap detection
        let previousAngle = currentAngle
        
        // Calculate new angle with Kalman filter
        let predictedAngle = currentAngle - rotationChange
        let predictedCovariance = positionCovariance + processNoise
        
        // Calculate new angle (negative for clockwise rotation)
        let newAngle = currentAngle - rotationChange
        
        // Normalize angle to 0-2π range
        let normalizedAngle = normalizeRotation(newAngle)
        
        // Measurement update
        let kalmanGain = predictedCovariance / (predictedCovariance + measurementNoise)
        let filteredAngle = predictedAngle + kalmanGain * (normalizedAngle - predictedAngle)
        
        // Normalize filtered angle
        let normalizedFilteredAngle = normalizeRotation(filteredAngle)
        
        positionCovariance = (1 - kalmanGain) * predictedCovariance
        
        // Update current angle with normalized value
        currentAngle = normalizedFilteredAngle
        
        // Update location-based tracking if available
        if let currentLocation = currentLocation {
            // Calculate angle from location
            let locationAngle = calculateAngleFromLocation(currentLocation)
            
            // Calculate distance from start line
            let distanceFromStart = calculateDistanceFromStartLine(currentLocation)
            
            // Debug logging for location tracking
            print("📍 Location Tracking:")
            print("Current Location: (\(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude))")
            print("Location Angle: \(String(format: "%.2f", locationAngle * 180.0 / .pi))°")
            print("Distance from Start: \(String(format: "%.1f", distanceFromStart))m")
            
            // Combine motion and location data
            let combinedAngle = (currentAngle * 0.7 + locationAngle * 0.3)
            currentAngle = normalizeRotation(combinedAngle)
        }
        
        // Calculate distance from start line
        let distanceFromStart = abs(currentAngle - startLineAngle)
        let normalizedDistance = min(distanceFromStart, 2.0 * .pi - distanceFromStart)
        
        // Debug logging for start line detection
        print("🔍 Start Line Detection:")
        print("Current Angle: \(String(format: "%.2f", currentAngle * 180.0 / .pi))°")
        print("Distance from Start: \(String(format: "%.2f", normalizedDistance * 180.0 / .pi))°")
        print("Rotation Rate: \(String(format: "%.2f", rotationRate.z))")
        print("Has Crossed Start Line: \(hasCrossedStartLine)")
        print("Is Lap In Progress: \(isLapInProgress)")
        
        // Start line detection and crossing logic
        if normalizedDistance < startLineThreshold {
            let currentTime = Date()
            let timeSinceLastCrossing = currentTime.timeIntervalSince(lastStartLineCrossingTime ?? Date())
            
            // Calculate direction of movement
            let angleDiff = currentAngle - lastAngle
            let isMovingClockwise = angleDiff < 0
            
            print("🔄 Movement Check:")
            print("Angle Difference: \(String(format: "%.2f", angleDiff * 180.0 / .pi))°")
            print("Is Moving Clockwise: \(isMovingClockwise)")
            print("Time Since Last Crossing: \(String(format: "%.1f", timeSinceLastCrossing))s")
            
            // Check if this is a valid start line crossing
            if timeSinceLastCrossing > minTimeBetweenCrossings {
                // Only count crossing if moving in the right direction
                if isMovingClockwise {
                    startLineCrossingCount += 1
                    lastStartLineCrossingTime = currentTime
                    lastCrossingDirection = angleDiff
                    
                    if !hasCrossedStartLine {
                        // First time crossing start line
                        hasCrossedStartLine = true
                        isLapInProgress = true
                        lapStartDistance = indoorDistance
                        lastStepCount = indoorSteps
                        lapStartTime = currentTime
                        currentAngle = 0.0
                        totalRotation = 0.0
                        positionHistory.removeAll()
                        lapStatus = "Starting first lap"
                        startLineAlert = "✅ Start line crossed! First lap has begun"
                        print("✅ First start line crossing detected!")
                        print("Initial step count: \(indoorSteps)")
                        print("Initial distance: \(String(format: "%.1f", indoorDistance))m")
                    } else {
                        // Subsequent start line crossings
                        startLineAlert = "🔄 Start line crossed again! Lap \(indoorLaps + 1) in progress"
                        print("🔄 Start line crossed again!")
                        print("Current lap: \(indoorLaps + 1)")
                        print("Total steps: \(indoorSteps)")
                        print("Total distance: \(String(format: "%.1f", indoorDistance))m")
                    }
                } else {
                    print("⚠️ Moving counter-clockwise - crossing not counted")
                }
            } else {
                print("⚠️ Too soon since last crossing: \(String(format: "%.1f", timeSinceLastCrossing))s")
            }
        } else {
            // Update start line alert when approaching
            if normalizedDistance < startLineThreshold * 2 {
                startLineAlert = "⚠️ Approaching start line! \(String(format: "%.1f", normalizedDistance * 180.0 / .pi))° away"
                print("⚠️ Approaching start line: \(String(format: "%.1f", normalizedDistance * 180.0 / .pi))° away")
            } else {
                startLineAlert = ""
            }
        }
        
        // Store last angle for next update
        lastAngle = currentAngle
        
        // Enhanced lap detection
        if hasCrossedStartLine && isLapInProgress {
            // Calculate angle difference with smoothing
            var angleDiff = normalizedAngle - previousAngle
            if angleDiff > .pi {
                angleDiff -= 2.0 * .pi
            } else if angleDiff < -.pi {
                angleDiff += 2.0 * .pi
            }
            
            // Update total rotation with smoothing and bounds checking
            let newRotation = totalRotation + abs(angleDiff) * (1.0 - rotationSmoothingFactor) +
                            (totalRotation * rotationSmoothingFactor)
            totalRotation = min(max(newRotation, 0.0), 2.0 * .pi * 10) // Limit to 10 full circles
            
            // Check for completed lap with pattern validation
            if totalRotation >= 2.0 * .pi * 0.98 && motionPattern > stepPatternThreshold {
                let currentStepCount = indoorSteps
                let stepsThisLap = currentStepCount - lastStepCount
                let distanceThisLap = indoorDistance - lapStartDistance
                
                if stepsThisLap >= minStepsPerLap && distanceThisLap >= minLapDistance {
                    indoorLaps += 1
                    currentIndoorLaps = indoorLaps
                    totalRotation = 0.0 // Reset rotation after lap completion
                    lastStepCount = currentStepCount
                    lapStartDistance = indoorDistance
                    lapStatus = "Lap \(indoorLaps) completed! 🎉"
                    print("✅ Lap \(indoorLaps) completed!")
                }
            }
        }
        
        // Print detailed motion and location information
        print("📍 Position: (\(String(format: "%.2f", positionEstimate.x)), \(String(format: "%.2f", positionEstimate.y)))")
        print("🧭 Angle: \(String(format: "%.1f", currentAngle * 180.0 / .pi))°")
        print("📏 Distance from start: \(String(format: "%.1f", normalizedDistance * 180.0 / .pi))°")
        print("🔄 Total rotation this lap: \(String(format: "%.2f", totalRotation))")
        print("👣 Steps this lap: \(indoorSteps - lastStepCount)")
        print("📈 Motion pattern: \(String(format: "%.2f", motionPattern))")
        print("🚦 Start line crossings: \(startLineCrossingCount)")
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
    
    private func updateLapTracking() {
        guard let currentLocation = locationManager.currentUserLocation else { return }
        
        let currentLocationCL = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        
        // Calculate distance from last location
        if let lastLoc = lastLocation {
            let distanceFromLast = lastLoc.distance(from: currentLocationCL)
            currentIndoorDistance += distanceFromLast
            
            // Update total lap distance if lap has started
            if hasStartedLap {
                totalLapDistance += distanceFromLast
            }
        }
//        guard let context = modelContext else {
//            print("❌ modelContext is nil, can't save Tawaf data")
//            return
//        }
//        saveTawafData(
//            context: context,
//            laps: currentIndoorLaps,
//            distance: currentIndoorDistance,
//            steps: currentIndoorSteps
//            //startTime: startTime
//        )
        // Check if we're near the start line
        let isNearStartLineNow = isNearStartLine(currentLocationCL)
        
        if !hasStartedLap {
            // First time crossing start line
            if isNearStartLineNow {
                hasStartedLap = true
                hasCrossedStartLine = true
                lastStartLineCrossing = currentLocationCL
                lapStatus = "Starting first lap"
                totalLapDistance = 0.0
                startLineAlert = "Start line detected. Begin your Tawaf."
            } else {
                startLineAlert = "Find the start line to begin Tawaf."
            }
        } else if isNearStartLineNow {
            // Check if we've completed a full lap
            if totalLapDistance >= minLapDistance {
                // Valid lap completed
                currentIndoorLaps += 1
                lapStatus = "Lap \(currentIndoorLaps) completed! Distance: \(String(format: "%.1f", totalLapDistance))m"
                
                lastStartLineCrossing = currentLocationCL
                totalLapDistance = 0.0
                
           
                // ✅ Save session
                 guard let context = modelContext else {
                     print("❌ modelContext is nil, can't save Tawaf data")
                     return
                 }
                 print("before call saveTawafData")
                 saveTawafData(
                     context: context,
                     laps: currentIndoorLaps,
                     distance: currentIndoorDistance,
                     steps: currentIndoorSteps
                     //startTime: startTime
                 )
                
                if currentIndoorLaps == maxLaps {
                    lapStatus = "Tawaf Complete! 🎉"
                    isTawafComplete = true
                }
            } else {
                startLineAlert = "Complete the full circle to count as a lap."
            }
        }
        
        lastLocation = currentLocationCL
    }
    
    private func isNearStartLine(_ location: CLLocation) -> Bool {
        let startLineLocation = CLLocation(latitude: startLineLatitude, longitude: startLineLongitude)
        let distanceToStartLine = location.distance(from: startLineLocation)
        return distanceToStartLine <= lapDetectionThreshold
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
    
    func stopIndoorTracking() {
        isIndoorTrackingActive = false
        pedometer.stopUpdates()
        motionManager.stopDeviceMotionUpdates()
        locationManager.stopLocationUpdates()
        
            }
    
    
    func resetIndoorTracking() {
        indoorSteps = 0
        indoorDistance = 0.0
        indoorLaps = 0
        currentIndoorSteps = 0
        currentIndoorDistance = 0.0
        currentIndoorLaps = 0
        trackingError = nil
        hasCrossedStartLine = false
        isLapInProgress = false
        lapStartDistance = 0.0
        lapStatus = "Ready to start"
        lastStepCount = 0
        lastDistance = 0.0
        turnCount = 0
        lastTurnDirection = 0.0
        lastRotationRate = nil
        totalRotation = 0.0
        rotationHistory.removeAll()
        accelerationHistory.removeAll()
        headingHistory.removeAll()
        stepLength = 0.7
        stepConfidence = 0.0
        currentAngle = 0.0
        lastPositionUpdate = nil
        positionHistory.removeAll()
        lastStartLineCrossing = nil
        lastLapRotation = 0.0
        completedRotations = 0
        lastAngle = 0.0
        lastStepTime = nil
        lastAttitude = nil
        startLineCrossingCount = 0
        lastStartLineCrossingTime = nil
        lastStartLineDistance = 0.0
        lastLocation = nil
        currentLocation = nil
        cycleStartAngle = 0.0
        cycleProgress = 0.0
        lastCycleProgress = 0.0
        cycleDirection = 0.0
        cycleStartTime = nil
        cycleStartDistance = 0.0
        cycleStartSteps = 0
        isCycleInProgress = false
        cycleCrossings = 0
        totalLapDistance = 0.0
        hasStartedLap = false
    }
    
    private func normalizeRotation(_ angle: Double) -> Double {
        // First, bring the angle within reasonable bounds
        let boundedAngle = min(max(angle, minRotation), maxRotation)
        
        // Then normalize to 0-2π range
        let normalized = (boundedAngle + 2.0 * .pi).truncatingRemainder(dividingBy: 2.0 * .pi)
        return normalized
    }
    
 
 private func saveTawafData(
    
        context: ModelContext?,
        laps: Int,
        distance: Double,
        steps: Int
        //startTime: Date?
    ) {
        print("📥 In saveTawafData")

        guard let context = context else {
            print("❌ ModelContext is nil.")
            return
        }

//        guard let startTime = startTime else {
//            print("❌ Start time is nil.")
//            return
//        }

        // Create session on main thread
        DispatchQueue.main.async {
            let session = TawafSession(
                laps: laps,
                distance: distance,
                steps: steps
                //startTime: startTime
            )

            context.insert(session)

            do {
                try context.save()
                print("✅ Tawaf session saved successfully.")
            } catch {
                print("❌ Failed to save Tawaf session: \(error)")
            }
        }
    }




}
