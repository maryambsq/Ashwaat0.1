//
//  SaiMainWatchView.swift
//  Ashwaat
//
//  Created by Aliah Alhameed on 23/11/1446 AH.
//
import SwiftUI

struct SaiMainWatchView: View {
    @State private var navigateToSaee = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BG")
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    Text("Sa’i")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("TC"))
                        .padding(.top, -10)

                    ZStack {
                        Image("greenBox")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .frame(height: 125)
                            .padding(.top, -30)

                        Text("Let’s begin counting your Ashwaat for Sa’i!")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(height: 150)

                    // ✅ زر متابعة
                    NavigationLink(destination: SaeeWatchView(), isActive: $navigateToSaee) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("SecondaryColor"))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 25)
                    .padding(.top, -30)
                }
                .padding()
            }
        }
    }
}

