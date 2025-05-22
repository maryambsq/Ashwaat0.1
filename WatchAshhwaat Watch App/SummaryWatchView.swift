//
//  SummaryWatchView.swift
//  Ashwaat
//
//  Created by Aliah Alhameed on 23/11/1446 AH.
//
import SwiftUI

struct SummaryWatchView: View {
    @ObservedObject var wcManager = WatchConnectivityManager.shared
    @State private var navigateToSai = false
    @State private var showSummary = false

    var body: some View {
        VStack(spacing: 10) {
            Spacer()

            // ✨ دعاء وقبول
            Text("May God accept your good deeds.")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color("AccentColor"))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // ✅ البطاقات الثلاث مثل iOS
            VStack(alignment: .leading, spacing: 8) {

                SummaryCardWatch(
                    icon: "timer",
                    text: "You spent \(formattedTime(wcManager.totalDuration))."
                )

                SummaryCardWatch(
                    icon: "figure.walk",
                    text: "You took \(wcManager.totalSteps) steps."
                )

                SummaryCardWatch(
                    icon: "checkmark.seal",
                    text: "You completed Tawaaf!"
                )
            }
            .padding(.top)

            Spacer()

            // ✅ زر "Done"
            Button(action: {
                navigateToSai = true
            }) {
                Text("Done")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 100, height: 35)
                    .background(Color("SecondaryColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            NavigationLink(destination: SaiMainWatchView(), isActive: $navigateToSai) {
                EmptyView()
            }

            Spacer()
        }
        .padding(.top, 10)
        .padding(.horizontal, 12)
        .background(Color("BG"))
        .ignoresSafeArea()
        
        // ✅ إذا وصلت رسالة "showSummary" من الآيفون، نعرض الصفحة تلقائيًا
                .onChange(of: wcManager.messages) { newMessages in
                    if newMessages.last == "showSummary" {
                        showSummary = true
                    }
                }
    }

    func formattedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return "\(minutes) min, \(secs) sec"
    }
}

struct SummaryCardWatch: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.system(size: 16))

            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)

            Spacer()
        }
        .padding(8)
        .background(Color("GREEN"))
        .cornerRadius(10)
    }
}

