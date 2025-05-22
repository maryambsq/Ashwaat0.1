//
//  TawafMain.swift
//  Ashwaat0.0
//
//  Created by Ruba Meshal Alqahtani on 05/05/2025.
//

import SwiftUI

struct TawafMain: View {
    @AppStorage("startTawaafFromSiri") var startTawaafFromSiri: Bool = false
    @State private var navigateToTawaf = false
    @EnvironmentObject var trackingManager: TrackingManager
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        NavigationStack { // Use NavigationStack instead of NavigationView
            GeometryReader { geometry in
                ZStack {
                    
                    Color("BGColor")
                        .ignoresSafeArea()
                    GeometryReader { geometry in
                        Image("Deco")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150) // Adjust size as needed
                            .position(x: geometry.size.width - 50, y: -15)
                        Image("Deco")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150)
                            .position(x: 50, y: geometry.size.height - 10)
                    }
                    VStack {
                        Text("Tawaf")
                            .font(.title)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundColor(Color("AccentColor"))
                            .padding(.top)

                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color("CardColor"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 450)
                            .overlay(
                                VStack(spacing: 15) {
                                    Spacer()

                                    Image("ayah1")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 355, height: 115)
                                        .padding(.top, -20)
                                    
                                    Spacer()
                                    
                                    Text("Let's begin counting your Ashwaat!")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .fontDesign(.rounded)
                                        .padding(.top, 6)
                                    
                                    Spacer()
                                    
//                                    VStack(spacing: 8) {
//                                        Text("📍 Tawaf Debug Info")
//                                            .font(.headline)
//                                            .foregroundColor(.white)
//                                        Text("Tawaf Region: \(trackingManager.isInTawafZone ? "✅ INSIDE" : "❌ OUTSIDE")")
//                                            .foregroundColor(trackingManager.isInTawafZone ? .green : .red)
//
//                                       
//
//                                        if let location = locationManager.currentUserLocation {
//                                            Text(String(format: "Lat: %.6f", location.coordinate.latitude))
//                                                .font(.caption)
//                                                .foregroundColor(.white)
//                                            Text(String(format: "Lon: %.6f", location.coordinate.longitude))
//                                                .font(.caption)
//                                                .foregroundColor(.white)
//                                        } else {
//                                            Text("Getting location...")
//                                                .font(.caption)
//                                                .foregroundColor(.gray)
//                                        }
//                                    }
//                                    .padding(.top, 8)

                                    Button(action: {
                                        // Start tracking action here
                                        WatchConnectivityManager.shared.sendMessage("startTawaf")
                                        navigateToTawaf = true

                                    }) {
                                        Text("Get Started")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color("ButtonTextColor"))
                                            .frame(width: 185, height: 60)
                                            .background(Color("SecondaryColor"))
                                            .cornerRadius(20)
                                            .fontDesign(.rounded)

                                    }.disabled(!trackingManager.isInTawafZone)
                                        .opacity(trackingManager.isInTawafZone ? 1.0 : 0.5)
                                    .offset(y: 70)
                                    NavigationLink("", destination: tawaf(), isActive: $navigateToTawaf)
                                        .opacity(0)

                                }
                                .padding()
                            )
                            .padding(.horizontal, 40)
                            .padding(.bottom, 55)
                        
                        Spacer()
                    }
                }
            }
            .onChange(of: startTawaafFromSiri) { value in
                if value {
                    navigateToTawaf = true
                    startTawaafFromSiri = false
                }
            }
            .navigationBarBackButtonHidden(true)
        }.onReceive(trackingManager.$isInTawafZone) { isInside in
            print("📡 TawafMain view received isInTawafZone update: \(isInside)")
        }

    }
}

#Preview {
    TawafMain()
}


