//
//  TrackerLVLiveActivity.swift
//  TrackerLV
//
//  Created by Ashwaq on 27/11/1446 AH.
//

import ActivityKit
import WidgetKit
import SwiftUI

//struct TrackerLVAttributes: ActivityAttributes {
//    public struct ContentState: Codable, Hashable {
//        // Dynamic stateful properties about your activity go here!
//        var emoji: String
//    }
//
//    // Fixed non-changing properties about your activity go here!
//    var name: String
//}
//
//struct TrackerLVLiveActivity: Widget {
//    var body: some WidgetConfiguration {
//        ActivityConfiguration(for: TrackerLVAttributes.self) { context in
//            // Lock screen/banner UI goes here
//            VStack {
//                Text("Hello \(context.state.emoji)")
//            }
//            .activityBackgroundTint(Color.cyan)
//            .activitySystemActionForegroundColor(Color.black)
//
//        } dynamicIsland: { context in
//            DynamicIsland {
//                // Expanded UI goes here.  Compose the expanded UI through
//                // various regions, like leading/trailing/center/bottom
//                DynamicIslandExpandedRegion(.leading) {
//                    Text("Leading")
//                }
//                DynamicIslandExpandedRegion(.trailing) {
//                    Text("Trailing")
//                }
//                DynamicIslandExpandedRegion(.bottom) {
//                    Text("Bottom \(context.state.emoji)")
//                    // more content
//                }
//            } compactLeading: {
//                Text("L")
//            } compactTrailing: {
//                Text("T \(context.state.emoji)")
//            } minimal: {
//                Text(context.state.emoji)
//            }
//            .widgetURL(URL(string: "http://www.apple.com"))
//            .keylineTint(Color.red)
//        }
//    }
//}
//
//extension TrackerLVAttributes {
//    fileprivate static var preview: TrackerLVAttributes {
//        TrackerLVAttributes(name: "World")
//    }
//}
//
//extension TrackerLVAttributes.ContentState {
//    fileprivate static var smiley: TrackerLVAttributes.ContentState {
//        TrackerLVAttributes.ContentState(emoji: "😀")
//     }
//     
//     fileprivate static var starEyes: TrackerLVAttributes.ContentState {
//         TrackerLVAttributes.ContentState(emoji: "🤩")
//     }
//}
//
//#Preview("Notification", as: .content, using: TrackerLVAttributes.preview) {
//   TrackerLVLiveActivity()
//} contentStates: {
//    TrackerLVAttributes.ContentState.smiley
//    TrackerLVAttributes.ContentState.starEyes
//}
//struct TrackerLVLiveActivity: Widget {
//    var body: some WidgetConfiguration {
//        ActivityConfiguration(for: TrackerAttributes.self) { context in
//            // Lock Screen View
//            VStack(spacing: 12) {
//                // Header
//                HStack {
//                    Text("Tawaaf Tracker")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                    Spacer()
//                    Text(formatTime(context.state.elapsedTime))
//                        .font(.subheadline)
//                        .foregroundColor(.white)
//                }
//                
//                // Progress
//                HStack {
//                    Text("Lap \(context.state.currentLap) of \(context.attributes.totalLaps)")
//                        .font(.title2)
//                        .foregroundColor(.white)
//                    Spacer()
//                    // Progress circle or bar
//                    ProgressView(value: Double(context.state.currentLap), total: Double(context.attributes.totalLaps))
//                        .progressViewStyle(.circular)
//                        .tint(.white)
//                }
//                
//                // Status
//                HStack {
//                    Image(systemName: context.state.isActive ? "figure.walk" : "pause.circle")
//                        .foregroundColor(.white)
//                    Text(context.state.isActive ? "In Progress" : "Paused")
//                        .foregroundColor(.white)
//                }
//                .font(.caption)
//            }
//            .padding()
//            .background(Color.black.opacity(0.8))
//        } dynamicIsland: { context in
//            DynamicIsland {
//                // Expanded View
//                DynamicIslandExpandedRegion(.leading) {
//                    HStack {
//                        Text("Lap")
//                            .foregroundColor(.white)
//                        Text("\(context.state.currentLap)")
//                            .foregroundColor(.white)
//                    }
//                }
//                
//                DynamicIslandExpandedRegion(.trailing) {
//                    HStack {
//                        Text("Time")
//                            .foregroundColor(.white)
//                        Text(formatTime(context.state.elapsedTime))
//                            .foregroundColor(.white)
//                    }
//                }
//                
//                DynamicIslandExpandedRegion(.center) {
//                    HStack {
//                        Text("Progress")
//                            .foregroundColor(.white)
//                        Text("\(context.state.currentLap)/\(context.attributes.totalLaps)")
//                            .foregroundColor(.white)
//                    }
//                }
//                
//                DynamicIslandExpandedRegion(.bottom) {
//                    HStack {
//                        Image(systemName: context.state.isActive ? "figure.walk" : "pause.circle")
//                            .foregroundColor(.white)
//                        Text(context.state.isActive ? "In Progress" : "Paused")
//                            .foregroundColor(.white)
//                    }
//                }
//            } compactLeading: {
//                Text("Lap \(context.state.currentLap)")
//                    .foregroundColor(.white)
//            } compactTrailing: {
//                Text(formatTime(context.state.elapsedTime))
//                    .foregroundColor(.white)
//            } minimal: {
//                Image(systemName: "figure.walk")
//                    .foregroundColor(.white)
//            }
//        }
//    }
//    
//    private func formatTime(_ timeInterval: TimeInterval) -> String {
//        let hours = Int(timeInterval) / 3600
//        let minutes = Int(timeInterval) / 60 % 60
//        let seconds = Int(timeInterval) % 60
//        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
//    }
//}
struct TrackerLVLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TrackerAttributes.self) { context in
            // Lock Screen View
            HStack(spacing: 16) {
                // Left: Circular Progress with Lap Number
              ZStack {
                    // Base circle (beige/pagie)
                    Circle()

                        .stroke(Color("BaseCircle"), lineWidth: 10)
                        .frame(width: 50, height: 50)

                    // Progress arc (green) only if started
                    if context.state.currentLap > 0 {
                        Circle()
                            .trim(from: 0, to: (context.state.lapProgress) / 100)
                            .stroke(Color.greeno, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .frame(width: 50, height: 50)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1.0), value: (context.state.lapProgress))          /*                  .animation(.easeInOut(duration: 1.0), value: context.state.currentLap)*/
                    }
                  
//                  Circle()
//                      .trim(from: 0, to: context.state.lapProgress / 100)
//                      .stroke(Color.greeno, style: StrokeStyle(lineWidth: 20, lineCap: .round))
//                      .frame(width: 50, height: 50)
//                      .rotationEffect(.degrees(-90))
//                      .animation(.easeInOut(duration: 1.0), value: context.state.lapProgress)

                    // Lap number
                    Text("\(context.state.currentLap)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.greeno)
                }
                
                // Middle: Timer
                VStack(alignment: .leading, spacing: 2) {
                    Text("Time")
                        .font(.caption)
                        .foregroundColor(Color("lightgreeno"))
                    Text(formatTime(context.state.elapsedTime))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("lightgreeno"))
                }
                
                Spacer()
                
                // Right: Status Icon
                Image("AshwaatIconD")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
//                Image(systemName: "star.fill")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 24, height: 24)
            }
            .padding()
            .background(Color("BGColor"))
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded View
                DynamicIslandExpandedRegion(.leading) {
                    // Left: Circular Progress with Lap Number
                    ZStack {
                        Circle()
                            .stroke(Color("circlecolor"), lineWidth: 20)
                            .frame(width: 50, height: 50)
                        
                        if context.state.currentLap > 0 && context.state.currentLap < context.attributes.totalLaps {
                            Circle()
                                .trim(from: 0, to: CGFloat(context.state.currentLap) / CGFloat(context.attributes.totalLaps))
                                .stroke(Color.greeno, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.0), value: context.state.currentLap)
                        }

                        Text("\(context.state.currentLap)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.greeno)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
//                    // Right: Timer
//                    VStack(alignment: .trailing, spacing: 2) {
//                        Text("Time")
//                            .font(.caption)
//                            .foregroundColor(Color("lightgreeno"))
//                        Text(formatTime(context.state.elapsedTime))
//                            .font(.system(size: 18, weight: .semibold))
//                            .foregroundColor(Color("lightgreeno"))
//                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
//                    // Center: Status Icon
//                    Image(systemName: context.state.isActive ? "figure.walk" : "pause.circle")
//                        .font(.system(size: 24))
//                        .foregroundColor(.white)
                }
            } compactLeading: {
//                // Compact Leading: Lap Number
//                Text("\(context.state.currentLap)")
//                    .font(.system(size: 16, weight: .bold))
//                    .foregroundColor(Color.greeno)
            } compactTrailing: {
//                // Compact Trailing: Timer
//                Text(formatTime(context.state.elapsedTime))
//                    .font(.system(size: 14, weight: .semibold))
                    //.foregroundColor(Color.greeno)
            } minimal: {
//                // Minimal: Status Icon
//                Image(systemName: "figure.walk")
//                    .foregroundColor(.white)
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        //let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


