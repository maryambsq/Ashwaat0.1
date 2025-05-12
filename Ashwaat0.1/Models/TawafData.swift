import Foundation
import SwiftData

//@Model
//final class TawafData {
//    var date: Date
//    var laps: Int
//    var distance: Double
//    var steps: Int
//    var duration: TimeInterval
//    
//    init(date: Date = Date(), laps: Int = 0, distance: Double = 0.0, steps: Int = 0, duration: TimeInterval = 0.0) {
//        self.date = date
//        self.laps = laps
//        self.distance = distance
//        self.steps = steps
//        self.duration = duration
//    }
//} 
//
//
//import SwiftData

@Model
class TawafData {
    var date: Date
    var laps: Int
    var distance: Double
    var steps: Int
    var duration: Double
    
    init(date: Date, laps: Int, distance: Double, steps: Int, duration: Double) {
        self.date = date
        self.laps = laps
        self.distance = distance
        self.steps = steps
        self.duration = duration
    }
}
