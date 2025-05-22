//
//  TawafWatchView.swift
//  Ashwaat
//
//  Created by Aliah Alhameed on 23/11/1446 AH.
//
import SwiftUI

struct TawafWatchView: View {
    @ObservedObject var wcManager = WatchConnectivityManager.shared
    @State private var navigateToSummary = false
    @State private var circleID = UUID() // لإجبار إعادة رسم الدائرة

    var body: some View {
        VStack(spacing: 10) {
            Spacer()

            HStack {
                Spacer()
                Text("Tawaf")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("ReqColor"))
                Spacer()
            }
            .padding(.bottom, 10)

            // ✅ استخدم totalDuration بدلاً من elapsedTime
                        let currentLap = wcManager.lapsData.last?.lapNumber ?? 0
                        let progress = CGFloat(currentLap) / 7.0
                        let time = formattedTime(from: wcManager.totalDuration)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color("ReqColor"), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 100, height: 100)
                    .id(circleID)
                    .animation(.easeInOut(duration: 1.0), value: progress)

                Text("\(currentLap)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color("ReqColor"))
            }

            Spacer()

            Text(time)
                .font(.caption)
                .foregroundColor(.gray)

            // ✅ الانتقال التلقائي لواجهة الملخص بعد الشوط السابع
            NavigationLink(destination: SummaryWatchView(), isActive: $navigateToSummary) {
                EmptyView()
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding()
        .background(Color.black)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onReceive(wcManager.$lapsData) { newValue in
                    let latestLap = newValue.last?.lapNumber ?? 0
                    if latestLap >= 7 {
                        navigateToSummary = true
                    }
                }
    }

    func formattedTime(from seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

