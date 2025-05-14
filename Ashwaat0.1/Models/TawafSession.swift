// TawafSession.swift



import Foundation
import SwiftData

@Model
final class TawafSession {
    var date: Date
    var laps: Int
    var distance: Double
    var steps: Int
   // var startTime: Date?
   // init(date: Date = .now, laps: Int, distance: Double, steps: Int, startTime: Date?) {

    init(date: Date = .now, laps: Int, distance: Double, steps: Int) {
        self.date = date
        self.laps = laps
        self.distance = distance
        self.steps = steps
      //  self.startTime = startTime
    }
}
