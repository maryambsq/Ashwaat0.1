//
//  VerifyLocation.swift
//  Ashwaat0.1
//
//  Created by Maryam Amer Bin Siddique on 09/11/1446 AH.
//

import SwiftUI
import CoreLocation

//class GeofenceManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    private let locationManager = CLLocationManager()
//    
//    // Example coordinates: Kaaba
//    private let region = CLCircularRegion(
//        center: CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262),
//        radius: 50,
//        identifier: "KaabaRegion"
//    )
//    
//    @Published var isInsideGeofence = false
//
//    override init() {
//        super.init()
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//        
//        region.notifyOnEntry = true
//        region.notifyOnExit = true
//        locationManager.startMonitoring(for: region)
//    }
//
//    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        if region.identifier == self.region.identifier {
//            isInsideGeofence = true
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
//        if region.identifier == self.region.identifier {
//            isInsideGeofence = false
//        }
//    }
//}


struct VerifyLocation: View {
   // @StateObject private var geoManager = GeofenceManager()
//    @State private var goToTawafMain = false
//    @EnvironmentObject var trackingManager: TrackingManager
    @EnvironmentObject var trackingManager: TrackingManager
    @EnvironmentObject var locationManager: LocationManager
    @State private var goToTawafMain = false
    var body: some View {
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
                            
                            Text("Laps tracked,\nFocus Intact")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .fontDesign(.rounded)
                            
                            Text("Make sure you are in the intended location for performing the ritual to initiate tracking.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.top)
                                .padding(.bottom, 5)
                                .fontDesign(.rounded)
                            VStack(spacing: 8) {
                                Text("📍 Location Debug")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Text("Haram Region: \(trackingManager.isInHaramRegion ? "✅ INSIDE" : "❌ OUTSIDE")")
                                    .foregroundColor(trackingManager.isInHaramRegion ? .green : .red)

                                if let location = locationManager.currentUserLocation {
                                    Text(String(format: "Lat: %.6f", location.coordinate.latitude))
                                        .font(.caption)
                                        .foregroundColor(.white)
                                    Text(String(format: "Lon: %.6f", location.coordinate.longitude))
                                        .font(.caption)
                                        .foregroundColor(.white)
                                } else {
                                    Text("Getting location...")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.bottom, 10)

                            Button(action: {
                                // Start tracking action here
                            }) {
                                Text("Get Started")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
//                                    .opacity(geoManager.isInsideGeofence ? 1.0 : 0.6)
                                    .opacity(trackingManager.isInHaramRegion ? 1.0 : 0.6)

                                    .frame(width: 185, height: 60)
                                    .background(Color("DisabledButton"))
                                    .cornerRadius(20)
                                    .fontDesign(.rounded)

                            }
                            .disabled(!trackingManager.isInHaramRegion)
                           // .disabled(!geoManager.isInsideGeofence)
                            .offset(y: 40)
                        }
                        .padding()
                    )
                    .padding(.horizontal, 40)
                
                Spacer()
            }
            NavigationLink(destination: TawafMain(), isActive: $goToTawafMain) {
                EmptyView()
            }
            .hidden()

        }
        .navigationBarBackButtonHidden(true)
        .task {
            if trackingManager.isInHaramRegion {
                goToTawafMain = true
            }
        }

    }
}

#Preview {
    VerifyLocation()
}
