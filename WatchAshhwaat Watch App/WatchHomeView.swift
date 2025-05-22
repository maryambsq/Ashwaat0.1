//
//  WatchHomeView.swift
//  Ashwaat
//
//  Created by Aliah Alhameed on 23/11/1446 AH.
//
import SwiftUI

struct WatchHomeView: View {
    @ObservedObject var wcManager = WatchConnectivityManager.shared
    @State private var navigateToTawaf = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BG")
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    Text("Tawaf")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("TC"))
                        .padding(.top, -10)

                    ZStack {
                        Image("greenBox")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .frame(height: 130)
                            .padding(.top, -30)

                        // ✅ الرسالة تتغير بناءً على حالة التتبع
                        Text(wcManager.isTrackingActive ? "🕋 Tawaf in progress..." : "Please open the iPhone app to start Tawaf")

                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(.white)
                                                    .multilineTextAlignment(.center)
                                                    .padding()

                    }
                    
                    .frame(height: 150)

                    NavigationLink(destination: TawafWatchView(), isActive: $navigateToTawaf) {
                        EmptyView()
                    }
                }
                .padding()
            }.buttonStyle(PlainButtonStyle())
        }
        .onAppear {
            if wcManager.isTrackingActive {
                navigateToTawaf = true
            }
        }
        // ✅ في حال وصل أمر "startTawaf" من التطبيق → ابدأ الطواف
                    .onChange(of: wcManager.isTrackingActive) { active in
                        if active {
                            navigateToTawaf = true
                        }
                    }
        // ✅ إذا الصفحة ظهرت وسبق أن التتبع مفعل
                    .onAppear {
                        if wcManager.isTrackingActive {
                            navigateToTawaf = true
                        }
                    }
    }

    var statusMessage: String {
        if wcManager.isTrackingActive {
            return "📡 Tawaf Started!"
        } else {
            return "Waiting for iPhone to start Tawaf..."
        }
    }
}

#Preview {
    WatchHomeView()
}
