//
//  Coordinate.swift
//  RunTracker
//
//  Created by Wilson Chan on 2/3/24.
//
//

import Foundation
import SwiftData
import MapKit

//Coordinates data model is based off of CLLocation:



// Additional improvements may consider the accuracy of the altitude/longidude/latitude data points. 

@Model
class Coordinates: Identifiable {
    @Attribute(.unique) var id: String
    var walk: Walk?
    
    var time = Date()
    
//    var coordinate: [CLLocationCoordinate2D] = []
    //At first the plan was to only use an array of CLLocationCordinates, however, when running into issues with SwiftData and saving values with "persisted object" error, decided to use separate lat/long variables/properties instead
    
    var latitude: Double?
    var longitude: Double?
    
    //Upon further inspection in documentation, additional CoreLocation variables can be considered such as altitude and speed found in CLLocation.
    //Altitude is a CLLocationDistance --> Which is a double.
    var altitude: Double?
    
    var speed: Double?
    
    init() {
        id = UUID().uuidString
    }
}

