//
//  Sa'iMain.swift
//  Ashwaat0.0
//
//  Created by Ruba Meshal Alqahtani on 05/05/2025.
//

import SwiftUI

struct SaiMain: View {
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
                    VStack(spacing: 20) {
                       
                        Text("Sa'i")
                            .font(.title)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundColor(Color("AccentColor"))
                            .padding(.top, 5)

                        Spacer()

                        ZStack {
                            
                            Image("SaiBox1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300)
                                .offset(y: -30)

                            
                            VStack(spacing: 5) {
                                Text("Let’s begin counting your Ashwaat!")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 60)
                                    .padding(.top, 10)
                            }
                            .offset(y: -8)
                        }
                        .overlay(
                            NavigationLink(destination: Saee()) {
                                Text("Get Started")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .foregroundColor(Color("ButtonTextColor"))
                                    .frame(width: 130, height: 45)
                                    .padding(.horizontal, 25)
                                    .padding(.vertical, 10)
                                    .background(Color("SecondaryColor"))
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            .disabled(true)
                            .padding(.bottom, 2),
                            alignment: .bottom
                        )
                        .padding(.bottom)
                        Spacer()
                    }
                    .frame(width: geometry.size.width)
                }
            }
            .navigationBarBackButtonHidden(true) // Hide back button for this view
        }
    }
}

#Preview {
    SaiMain()
}





