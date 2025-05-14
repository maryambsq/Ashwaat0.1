////
////  AccessLocation.swift
////  Ashwaat0.1
////
////  Created by Maryam Amer Bin Siddique on 09/11/1446 AH.
////
//
//import SwiftUI
//import CoreLocation
//
//class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    private let manager = CLLocationManager()
//    
//    @Published var authorizationStatus: CLAuthorizationStatus?
//    
//    override init() {
//        super.init()
//        manager.delegate = self
//        manager.desiredAccuracy = kCLLocationAccuracyBest
//        checkAuthorization()
//    }
//    
//    func checkAuthorization() {
//        authorizationStatus = manager.authorizationStatus
//    }
//    
//    func requestPermission() {
//        manager.requestWhenInUseAuthorization()
//    }
//    
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        self.authorizationStatus = manager.authorizationStatus
//    }
//}
//
//struct AccessLocation: View {
//    @StateObject private var locationManager = LocationManager()
//    @State private var shouldNavigate = false
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color("BGColor").ignoresSafeArea()
//                
//                VStack {
//                    Image("Location")
//                        .resizable()
//                        .frame(width: 300, height: 180)
//                        .foregroundColor(Color("AccentColor"))
//                        .padding(.bottom, 50)
//                        .padding(.leading, 10)
//                    
//                    Text("Allow Location Access")
//                        .font(.title)
//                        .fontWeight(.semibold)
//                        .foregroundColor(Color("AccentColor"))
//                        .padding(.bottom)
//                        .fontDesign(.rounded)
//                    
//                    Text("To accurately track your Tawaf and Sa'i, please allow location access while using the app.")
//                        .font(.subheadline)
//                        .foregroundColor(Color("SecondaryColor"))
//                        .multilineTextAlignment(.center)
//                        .padding(.bottom, 100)
//                        .fontDesign(.rounded)
//                    
//                    Button(action: {
//                        handleLocationAuthorization()
//                    }) {
//                        Text("Allow Access")
//                            .font(.title3)
//                            .fontWeight(.semibold)
//                            .foregroundColor(Color("ButtonTextColor"))
//                            .frame(width: 290, height: 60)
//                            .background(Color("SecondaryColor"))
//                            .cornerRadius(20)
//                            .fontDesign(.rounded)
//                    }
//                }
//                .padding(20)
//            }
//            .onChange(of: locationManager.authorizationStatus) { newStatus in
//                if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
//                    shouldNavigate = true
//                }
//            }
//            .navigationDestination(isPresented: $shouldNavigate) {
//                VerifyLocation()
//            }
//        }
//    }
//    
//    private func handleLocationAuthorization() {
//        guard let status = locationManager.authorizationStatus else {
//            locationManager.requestPermission()
//            return
//        }
//        
//        switch status {
//        case .notDetermined:
//            locationManager.requestPermission()
//        case .denied, .restricted:
//            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(appSettings)
//            }
//        default:
//            break
//        }
//    }
//}
//
//#Preview {
//    AccessLocation()
//}
//
//  AccessLocation.swift
//  Ashwaat0.1
//
//  Created by Maryam Amer Bin Siddique on 09/11/1446 AH.
//

//
//  AccessLocation.swift
//  Ashwaat0.1
//
//  Created by Maryam Amer Bin Siddique on 09/11/1446 AH.
//

import SwiftUI
import CoreLocation

struct AccessLocation: View {
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.openURL) private var openURL
    @State private var shouldNavigate = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BGColor").ignoresSafeArea()

                VStack {
                    Image("Location")
                        .resizable()
                        .frame(width: 300, height: 180)
                        .foregroundColor(Color("AccentColor"))
                        .padding(.bottom, 50)
                        .padding(.leading, 10)

                    Text("Allow Location Access")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("AccentColor"))
                        .padding(.bottom)
                        .fontDesign(.rounded)

                    Text("To accurately track your Tawaf and Sa'i, please allow location access while using the app.")
                        .font(.subheadline)
                        .foregroundColor(Color("SecondaryColor"))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 100)
                        .fontDesign(.rounded)

                    Button(action: {
                        locationManager.handleLocationAuthorization()
                    }) {
                        Text("Allow Access")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("ButtonTextColor"))
                            .frame(width: 290, height: 60)
                            .background(Color("SecondaryColor"))
                            .cornerRadius(20)
                            .fontDesign(.rounded)
                    }
                }
                .padding(20)
            }
            .onAppear {
                // Auto-skip if permission already granted
                let status = locationManager.authorizationStatus
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    shouldNavigate = true
                }
            }
            .onChange(of: locationManager.authorizationStatus) { newStatus in
                if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
                    shouldNavigate = true
                }
            }
            .onChange(of: locationManager.shouldOpenSettings) { shouldOpen in
                if shouldOpen {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        openURL(settingsUrl)
                    }
                    locationManager.shouldOpenSettings = false
                }
            }
            .navigationDestination(isPresented: $shouldNavigate) {
                VerifyLocation()
            }
        }
    }
}

#Preview {
    AccessLocation()
        .environmentObject(LocationManager()) // Needed for preview
}
