//
//  Summary.swift
//  Ashwaat0.0
//
//  Created by Ruba Meshal Alqahtani on 05/05/2025.
//

import SwiftUI

struct Summary: View {
    @AppStorage("finalLapDuration") var finalLapDuration: Int = 0
    @State private var navigateToSai = false
    let steps: Int
    let distance: Double
    let laps: Int
    //let duration :
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color("BGColor")
                        .ignoresSafeArea()
                    GeometryReader { geometry in
                        Image("Deco2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250) // Adjust size as needed
                            .position(x: geometry.size.width - 80, y: 20)
                        Image("Deco")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150)
                            .position(x: 50, y: geometry.size.height - 10)
                    }
                    VStack(spacing: 20) {
                        Spacer()

                        ZStack {
                            
                            Image("Sparkles")
                                .resizable()
                                .scaledToFit()
                                .padding(.top, -400)
                                .padding(.trailing, 50)
                            

                            Image("Summ")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 320)
                                .offset(y: 40)

                            Text("May God accept your good deeds.")
                                .padding(.top)
                                .font(.title)
                                .fontDesign(.rounded)
                                .fontWeight(.bold)
                                .foregroundColor(Color("AccentColor"))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.top, -120)
                                .alignmentGuide(.top) { d in d[.top] }
                                .padding(.horizontal, 60)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                
                                HStack {
                                    Image("TimerL")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                        .padding(.leading, 4)

                                    Text("You spent \(formattedFinalDuration).")
                                        .foregroundColor(Color("AccentColor"))
                                        .font(.body)
                                        .fontWeight(.bold)
                                        .fontDesign(.rounded)
                                        .padding(.leading, 10)
                                }
                                .padding(.top, 30)

                                HStack {
                                    Image("StaircaseL")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)

                                    Text("You took \(steps) steps.")
                                        .foregroundColor(Color("AccentColor"))
                                        .font(.body)
                                        .fontWeight(.bold)
                                        .fontDesign(.rounded)
                                        .padding(.leading, 6)
                                }

                                HStack {
                                    Image("QuranL")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 30)

                                    Text("You completed Tawaaf!")
                                        .foregroundColor(Color("AccentColor"))
                                        .font(.body)
                                        .fontWeight(.bold)
                                        .fontDesign(.rounded)
                                        .padding(.leading, 6)
                                }
                            }
                            .offset(x: -20, y: 80)
                        }

                        Button(action: {
                            navigateToSai = true

                        }) {
                            Text("Done")
                                .font(.headline)
                                .foregroundColor(Color("ButtonTextColor"))
                                .fontDesign(.rounded)
                                .frame(width: 125, height: 40)
                                .padding(.horizontal, 25)
                                .padding(.vertical, 10)
                                .background(Color("SecondaryColor"))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        .offset(y: -10)

                        // Hidden navigation trigger
                        NavigationLink("", destination: SaiMain(), isActive: $navigateToSai)
                            .opacity(0)

                        Spacer()
                    }
                    .frame(width: geometry.size.width)
                }
            }
            .navigationBarBackButtonHidden(true) 
        }
    }
    var formattedFinalDuration: String {
        let minutes = finalLapDuration / 60
        let seconds = finalLapDuration % 60
        return "\(minutes) min, \(seconds) sec"
    }
}

#Preview {
    Summary(steps: 0, distance: 0.0, laps: 0)
}

