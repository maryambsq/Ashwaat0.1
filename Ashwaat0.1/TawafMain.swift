//
//  TawafMain.swift
//  Ashwaat0.0
//
//  Created by Ruba Meshal Alqahtani on 05/05/2025.
//

import SwiftUI

struct TawafMain: View {
    @State private var navigateToTawaf = false

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
                                    
                                    Button(action: {
                                        // Start tracking action here
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

                                    }
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
            .navigationBarBackButtonHidden(true) 
        }
    }
}

#Preview {
    TawafMain()
}


