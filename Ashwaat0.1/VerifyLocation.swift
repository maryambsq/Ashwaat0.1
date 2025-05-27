//
//  VerifyLocation.swift
//  Ashwaat0.1
//
//  Created by Maryam Amer Bin Siddique on 09/11/1446 AH.
//

import SwiftUI
import CoreLocation

struct VerifyLocation: View {
   // @StateObject private var geoManager = GeofenceManager()
//    @State private var goToTawafMain = false
//    @EnvironmentObject var trackingManager: TrackingManager
    @EnvironmentObject var trackingManager: TrackingManager
    @EnvironmentObject var locationManager: LocationManager
    @State private var goToTawafMain = false
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BGColor").ignoresSafeArea()
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
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color("CardColor"))
                        .frame(width: .infinity, height: .infinity)
                        .overlay(
                            ZStack(alignment: .bottom) {
                                VStack(spacing: 12) {
                                    Image("ayah1")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 355, height: 115)
                                        .padding(.top, -20)
                                    
                                    Text("Laps tracked,\nfocus intact")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .fontDesign(.rounded)
                                        .padding(.vertical, 5)
                                        .lineLimit(nil)
                                        .minimumScaleFactor(0.5)
                                        .allowsTightening(true)
                                    
                                    Text("Make sure you are in the intended location for performing the ritual to initiate tracking.")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                        .padding(.top)
                                    //                                .padding(.bottom, 5)
                                        .fontDesign(.rounded)
                                        .lineLimit(nil)
                                        .minimumScaleFactor(0.5)
                                        .allowsTightening(true)
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 55) // leaves space above button
                            }
                        )
                        .padding(.horizontal, 40)
                        .padding(.bottom, 55)
                        .overlay(
                            VStack {
                                
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        goToTawafMain = true
                                    }) {
                                        Text("Get Started")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color("ButtonTextColor"))
                                            .frame(height: 60)
                                            .padding(.horizontal, 35)
                                            .background(Color("SecondaryColor"))
                                            .cornerRadius(20)
                                            .fontDesign(.rounded)
                                            .lineLimit(nil)
                                            .minimumScaleFactor(0.5)
                                            .allowsTightening(true)
                                    }
                                    //                                .disabled(!trackingManager.isInTawafZone)
                                    //                                .opacity(trackingManager.isInTawafZone ? 1.0 : 0.5)
                                    .padding(.bottom, 10)
                                    Spacer()
                                }
                                
                                NavigationLink("", destination: TawafMain(), isActive: $goToTawafMain)
                                    .opacity(0)
                                
                                //                            NavigationLink(destination: TawafMain(), isActive: $goToTawafMain) {
                                //                                EmptyView()
                                //                            }
                                //                            .hidden()
                            },
                            alignment: .bottom
                        )
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                }
                
            }
            .navigationBarBackButtonHidden(true)
        }
//        .task {
//            if trackingManager.isInHaramRegion {
//                goToTawafMain = true
//            }
//        }

    }
}

#Preview {
    VerifyLocation()
}
