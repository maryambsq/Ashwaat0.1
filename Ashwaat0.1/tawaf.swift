//
//  tawaf.swift
//  Ashwaat0.0
//
//  Created by Razan on 01/05/2025.
//

import SwiftUI
import CoreLocation

struct tawaf: View {
    @AppStorage("finalLapDuration") var finalLapDuration: Int = 0
    @Environment(\.dismiss) var dismiss // ✅ استخدام الديسميس


    @State private var lapCount = 0
    @State private var hasStartedTimer = false
    @State private var timeElapsed: Int = 0
    @State private var timer: Timer?
    @State private var isTrackingPaused = false
    @State private var showStartButton = true
    @State private var navigateToNext = false
    @State private var backToHome = false

//    @State private var progress: CGFloat = 0
    @State private var circleID = UUID()

    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var trackingManager: TrackingManager
    @State private var showSummary = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer(minLength: 30)
                
                HStack {
                    Spacer()
                    Spacer()

                    // ✅ زر الرجوع باستخدام dismiss
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: Locale.characterDirection(forLanguage: Locale.current.language.languageCode?.identifier ?? "") == .rightToLeft ? "chevron.right" : "chevron.left")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.trailing)
                    }

                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    Text("Tawaaf")
                        .font(.title)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundColor(.greeno)
                        .padding(.trailing, 20)
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                }

                Spacer()

                // ✅ NavigationLink عند نهاية الطواف
                NavigationLink(destination: Summary(steps: trackingManager.indoorSteps, distance: trackingManager.indoorDistance, laps: trackingManager.indoorLaps), isActive: $navigateToNext) {
                    EmptyView()
                }

                ZStack {
                    let progress = trackingManager.lapProgress / 100 // Normalize to 0–1

                    Circle()
                        .stroke(Color.circlecolor, lineWidth: 40)
                        .frame(width: 280, height: 280)

                    Circle()
//                        .trim(from: 0, to: CGFloat(trackingManager.currentIndoorLaps))
                        .trim(from: 0, to: trackingManager.lapProgress / 100)
                        .stroke(isTrackingPaused ? Color.stopgreeno : Color.greeno, style: StrokeStyle(lineWidth: 40, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 280, height: 280)
                        .id(circleID)
//                        .animation(.easeInOut(duration: 1.0), value: progress)
                        .animation(.easeInOut(duration: 1.0), value: trackingManager.lapProgress)


                    Text(formattedEnglishNumber(trackingManager.currentIndoorLaps))
                        .font(.system(size: 80, weight: .bold ,design: .rounded))
                        .foregroundColor(isTrackingPaused ? Color.stopgreeno : Color.greeno)
                }
                .environment(\.layoutDirection, .leftToRight)
                
                VStack {
                    HStack {
                        Circle()
                            .fill(trackingManager.hasCrossedStartLine ? Color.green : Color.orange)
                            .frame(width: 12, height: 12)
                            Text(trackingManager.hasCrossedStartLine ? "On Track" : "Find Start Line")
                            .font(.subheadline)
                    }
                }

//                VStack(spacing: 12) {
//                    HStack {
//                        Circle()
//                            .fill(trackingManager.hasCrossedStartLine ? Color.green : Color.orange)
//                            .frame(width: 12, height: 12)
//                        Text(trackingManager.hasCrossedStartLine ? "On Track" : "Find Start Line")
//                            .font(.subheadline)
//                    }
//
//                    Text(trackingManager.lapStatus)
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal)
//
//                    if !trackingManager.startLineAlert.isEmpty {
//                        Text(trackingManager.startLineAlert)
//                            .font(.caption)
//                            .foregroundColor(.orange)
//                    }
//
//                    VStack {
//                        Text("\(trackingManager.currentIndoorSteps)")
//                            .font(.system(size: 20, weight: .bold))
//                        Text("Steps")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    }
//
//                    VStack {
//                        Text(String(format: "%.1f", trackingManager.currentIndoorDistance))
//                            .font(.system(size: 20, weight: .bold))
//                        Text("Meters")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    }
//                    Text("\(Int(trackingManager.lapProgress))%")
//                        .font(.title)
//                        .bold()
//                    Text("Mode: \(trackingManager.useMotionFallback ? "Indoor (Motion)" : "Outdoor (GPS)")")
//                        .font(.caption)
//                        .foregroundColor(trackingManager.useMotionFallback ? .orange : .green)
//                    if trackingManager.isPausedDueToExit {
//                        Text("⚠️ You left the Tawaf zone. Tracking paused.")
//                            .foregroundColor(.orange)
//                    }
//                }
//                .padding(.top, 20)

                Spacer()

                if isTrackingPaused {
                    Button("Resume") {
                        resumeAfterPause()
                    }
                    .frame(width: 150, height: 40)
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 15)
                    .background(Color.greeno)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                } /*else if showStartButton {*/
//                    Button("Start") {
//                        if trackingManager.isIndoorTrackingActive {
//                            stopIndoorTracking()
//                            showStartButton = true
//                        } else {
//                            startIndoorTracking()
//                            showStartButton = false
//                        }
//                    }
//                    .frame(width: 85, height: 40)
//                    .font(.title.bold())
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 50)
//                    .padding(.vertical, 15)
//                    .background(Color.greeno)
//                    .clipShape(RoundedRectangle(cornerRadius: 20))
                /*}*/ else {
                    Text(formattedTime)
                        .frame(height: 40)
                        .frame(minWidth: 85)
                        .font(.title.bold())
                        .padding(.horizontal, 50)
                        .padding(.vertical, 15)
                        .background(Color.circlecolor)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .foregroundColor(Color.lightgreeno)
                }

                Spacer()
                Spacer()
            }
            .background(Color.BG)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .onDisappear {
                timer?.invalidate()
            }
            .onChange(of: trackingManager.isTawafComplete) { completed in
                if completed {
                    showSummary = true
                }
            }
            .navigationDestination(isPresented: $showSummary) {
                Summary(
                    steps: trackingManager.indoorSteps,
                    distance: trackingManager.indoorDistance,
                    laps: trackingManager.indoorLaps
                )
            }
            .onChange(of: trackingManager.hasCrossedStartLine) { crossed in
                if crossed && !hasStartedTimer {
                    hasStartedTimer = true
                    startTimer()
                }
            }
            .onChange(of: trackingManager.currentIndoorLaps) { laps in
                if laps > 7 {
                    finalLapDuration = timeElapsed
                    timer?.invalidate()
                    timer = nil
                    navigateToNext = true
                }
            }
            .navigationBarBackButtonHidden(true)
            .task {
                let actualStatus = CLLocationManager.authorizationStatus()
                if actualStatus == .notDetermined {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        locationManager.requestLocationPermission()
                    }
                }
            }        }
    }
    func startTimer() {
            showStartButton = false
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                timeElapsed += 1

                if timeElapsed % 2 == 0 && lapCount < 7 {
//                    progress = 0
                    circleID = UUID()

//                    withAnimation(.easeInOut(duration: 1.0)) {
//                        progress = 1
//                    }

    //                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
    //                    lapCount += 1
    //
    //                    if lapCount == 6 {
    //                        isTrackingPaused = true
    //                        timer?.invalidate()
    //                    }
    //
    //                    if lapCount == 7 {
    //                        timer?.invalidate()
    //                        navigateToNext = true // ✅ الانتقال التلقائي
    //                    }
    //                }
                }
            }
        }

    func resumeAfterPause() {
        isTrackingPaused = false
        startTimer()
    }

    func formattedEnglishNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    var formattedTime: String {
        let minutes = timeElapsed / 60
        let seconds = timeElapsed % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func startIndoorTracking() {
        print("startIndoorTracking at tawaf")
        trackingManager.startIndoorTracking()
    }

    private func stopIndoorTracking() {
        // trackingManager.stopIndoorTracking()
    }
}

#Preview {
    tawaf()
}
