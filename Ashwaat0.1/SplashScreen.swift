//
//  SplashScreen.swift
//  Ashwaat0.1
//
//  Created by Maryam Amer Bin Siddique on 13/11/1446 AH.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var fadeInLogo = false

    var body: some View {
        Group {
            if isActive {
                VerifyLocation()
            } else {
                ZStack {
                    Image("SplashBG")
                        .resizable()
                        .ignoresSafeArea()
                    Image("Logo")
                        .resizable()
                        .frame(width: 90, height: 90)
                        .opacity(fadeInLogo ? 0.75 : 0)
                        .animation(.easeIn(duration: 0.5), value: fadeInLogo)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                fadeInLogo = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
}
