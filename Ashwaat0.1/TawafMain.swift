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
    @Environment(\.dismiss) var dismiss // ✅ استخدام الديسميس


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
                                        
                                        Text("Let's begin counting your Ashwaat!")
                                            .font(.largeTitle)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .fontDesign(.rounded)
                                            .padding(.top, 6)
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
                                    .padding(.bottom, 60) // leaves space above button

//                                    Button(action: {
//                                        navigateToTawaf = true
//                                    }) {
//                                        Text("Get Started")
//                                            .font(.headline)
//                                            .fontWeight(.semibold)
//                                            .foregroundColor(Color("ButtonTextColor"))
//                                            .frame(height: 60)
//                                            .frame(minWidth: 185)
//                                            .background(Color("SecondaryColor"))
//                                            .cornerRadius(20)
//                                            .fontDesign(.rounded)
//                                    }
//                                    .disabled(!trackingManager.isInTawafZone)
//                                    .opacity(trackingManager.isInTawafZone ? 1.0 : 0.5)
//                                    .padding(.bottom, -50)
//
//                                    NavigationLink("", destination: tawaf(), isActive: $navigateToTawaf)
//                                        .opacity(0)
                                }
                            )
                            .padding(.horizontal, 40)
                            .padding(.bottom, 55)
                            .overlay(
                                VStack {
                                    
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            navigateToTawaf = true
                                        }) {
                                            Text("Start Tawaaf")
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color("GetStartedButtonTextColor"))
                                                .frame(height: 60)
                                                .padding(.horizontal, 35)
                                                .background(Color("GetStartedButton"))
                                                .cornerRadius(20)
                                                .fontDesign(.rounded)
                                                .lineLimit(nil)
                                                .minimumScaleFactor(0.5)
                                                .allowsTightening(true)
                                        }
//                                        .disabled(!trackingManager.isInTawafZone)
//                                        .opacity(trackingManager.isInTawafZone ? 1.0 : 0.5)
                                        .padding(.bottom, 10)
                                        Spacer()
                                    }
                                    

                                    NavigationLink("", destination: tawaf(), isActive: $navigateToTawaf)
                                        .opacity(0)
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


