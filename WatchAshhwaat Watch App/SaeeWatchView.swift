//
//  SaeeWatchView.swift
//  Ashwaat
//
//  Created by Aliah Alhameed on 23/11/1446 AH.
//
import SwiftUI

struct SaeeWatchView: View {
    @ObservedObject var wcManager = WatchConnectivityManager.shared
    @State private var lapCount = 0
    @State private var timeElapsed = 0
    @State private var timer: Timer?
    @State private var isTrackingPaused = false
    @State private var navigateToSummary = false
    @State private var circleID = UUID()

    var body: some View {
        VStack(spacing: 10) {
            Spacer()

            HStack {
                Spacer()
                Text("Sa’i")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.TC)
                Spacer()
            }
            .padding(.top, 4)

            let progress = CGFloat(lapCount) / 7.0

            ZStack {
                Circle()
                    .stroke(Color.GREEN, lineWidth: 12)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(isTrackingPaused ? Color.stopgreeno : Color.circlecolor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 100, height: 100)
                    .id(circleID)
                    .animation(.easeInOut(duration: 1.0), value: progress)

                Text("\(lapCount)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(isTrackingPaused ? Color.stopgreeno : Color.circlecolor)
            }

            Spacer()

            Text(formattedTime)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 70, height: 30)
                .padding(6)
                .background(Color.circlecolor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundColor(Color.lightgreeno)

            NavigationLink(destination: SummaryWatchView(), isActive: $navigateToSummary) {
                EmptyView()
            }
        }
        .padding()
        .background(Color.BG)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeElapsed += 1

            if timeElapsed % 2 == 0 && lapCount < 7 {
                lapCount += 1
                circleID = UUID()

                if lapCount == 7 {
                    timer?.invalidate()
                    navigateToSummary = true
                }
            }
        }
    }

    var formattedTime: String {
        let minutes = timeElapsed / 60
        let seconds = timeElapsed % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

