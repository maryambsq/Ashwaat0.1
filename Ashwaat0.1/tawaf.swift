//
//  tawaf.swift
//  Ashwaat0.0
//
//  Created by Razan on 01/05/2025.
//

import SwiftUI

struct tawaf: View {
    @State private var lapCount = 0
    @State private var timeElapsed: Int = 0
    @State private var timer: Timer?
    @State private var isTrackingPaused = false
    @State private var showStartButton = true
    @State private var navigateToNext = false
    @State private var backToHome = false // ✅ جديد: متغير الرجوع للصفحة الرئيسية

    @State private var progress: CGFloat = 0
    @State private var circleID = UUID()
    
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var trackingManager: TrackingManager
    

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                
                HStack {
                    Spacer()
                    Spacer()
                    
                    // ✅ NavigationLink مخفي للرجوع إلى الصفحة الرئيسية
                    NavigationLink(destination: TawafMain(), isActive: $backToHome) {
                        EmptyView()
                    }
                    
                    // ✅ زر السهم لتفعيل الرجوع
                    Button(action: {
                        backToHome = true
                    }) {
                        Image(systemName: Locale.characterDirection(forLanguage: Locale.current.language.languageCode?.identifier ?? "") == .rightToLeft ? "chevron.right" : "chevron.left")
                            .font(.system(size: 34, weight: .medium))
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.trailing)
                    }
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Text("Tawaf")
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
                NavigationLink(destination: Summary(), isActive: $navigateToNext) {
                    EmptyView()
                }

                ZStack {
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
                .frame(height: 280)
                
                // Status indicators moved below the circle
                VStack(spacing: 8) {
                    // Status Indicator
                    HStack {
                        Circle()
                            .fill(trackingManager.hasCrossedStartLine ? Color.green : Color.orange)
                            .frame(width: 12, height: 12)
                        Text(trackingManager.hasCrossedStartLine ? "On Track" : "Find Start Line")
                            .font(.subheadline)
                    }
                    
                    // Status Message
                    Text(trackingManager.lapStatus)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Start Line Alert
                    if !trackingManager.startLineAlert.isEmpty {
                        Text(trackingManager.startLineAlert)
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.top, 20)

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
                } else if showStartButton {
                    Button("Start") {
                        if trackingManager.isIndoorTrackingActive {
                            stopIndoorTracking()
                            showStartButton = true
                        } else {
                            startIndoorTracking()
                            showStartButton = false
                        }
                    }
                    .frame(width: 85, height: 40)
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 15)
                    .background(Color.greeno)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    Text(formattedTime)
                        .frame(width: 85, height: 40)
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
            .navigationBarBackButtonHidden(true) // Hide the back button for this view
        }
        
        Button("Insert Test") {
            let test = TawafSession(date: .now, laps: 1, distance: 100, steps: 200)
            modelContext.insert(test)
            try? modelContext.save()
        }
    }

    func startTimer() {
        showStartButton = false
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeElapsed += 1

            if timeElapsed % 2 == 0 && lapCount < 7 {
                progress = 0
                circleID = UUID()

                withAnimation(.easeInOut(duration: 1.0)) {
                    progress = 1
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    lapCount += 1

                    if lapCount == 6 {
                        isTrackingPaused = true
                        timer?.invalidate()
                    }

                    if lapCount == 7 {
                        timer?.invalidate()
                        navigateToNext = true // ✅ الانتقال التلقائي
                    }
                }
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
        //showIndoorAlert = true
    }

    private func stopIndoorTracking() {
        trackingManager.stopIndoorTracking()
    }
}
 





#Preview {
    tawaf()
}

