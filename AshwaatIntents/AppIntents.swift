//
//  AppIntents.swift
//  Ashwaat0.1
//
//  Created by Maryam Amer Bin Siddique on 18/11/1446 AH.
//

import SwiftUI
import AppIntents

struct StartTawaafIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Tawaaf"
    static var description = IntentDescription("Begin tracking Tawaaf laps if inside the allowed area.")
    static var openAppWhenRun: Bool = true
    
    @AppStorage("isInGeofence") var isInGeofence: Bool = false
    @AppStorage("startTawaafFromSiri") var startTawaafFromSiri: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        print("🔥 StartTawaafIntent triggered!")
        if isInGeofence {
            startTawaafFromSiri = true
            return .result(dialog: IntentDialog(stringLiteral: "You are inside the allowed area. Tawaaf has started in Ashwaat."))
        } else {
            return .result(dialog: IntentDialog(stringLiteral: "You're not currently inside the Tawaaf zone. Please move into the area to begin."))
        }
    }
}

struct CurrentLapCountIntent: AppIntent {
    static var title: LocalizedStringResource = "Current Lap Number"
    static var description = IntentDescription("Tells you how many laps you’ve completed and what lap you’re currently on.")
    static var openAppWhenRun: Bool = true

    @AppStorage("currentIndoorLaps") var currentIndoorLaps: Int = 0
    @AppStorage("indoorLaps") var indoorLaps: Int = 0
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog  {
        return .result(
            dialog: IntentDialog("You’ve completed \(currentIndoorLaps) lap\(currentIndoorLaps == 1 ? "" : "s"). You're currently on lap \(currentIndoorLaps + 1).")
        )
    }
}

struct RemainingLapCountIntent: AppIntent {
    static var title: LocalizedStringResource = "Remaining Laps"
    static var description = IntentDescription("Tells you how many laps are left to complete and what lap you're currently on.")
    static var openAppWhenRun: Bool = true

    @AppStorage("currentIndoorLaps") var currentIndoorLaps: Int = 1
    let totalLaps = 7

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog  {
        let lapsLeft = max(totalLaps - currentIndoorLaps, 0)
        let response = "You have \(lapsLeft) lap\(lapsLeft == 1 ? "" : "s") left. You're currently on lap \(currentIndoorLaps)."
        return .result(dialog: IntentDialog(stringLiteral: response))
    }
}


struct AshwaatAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartTawaafIntent(),
            phrases: [
                "Start Tawaaf in \(.applicationName)",
                "Start Tawaaf",
                "Begin my Tawaaf",
                "Start tracking my Tawaaf",
                "Begin Tawaaf laps"
            ],
            shortTitle: "Start Tawaaf",
            systemImageName: "figure.walk.circle"
        )
        
        AppShortcut(
            intent: CurrentLapCountIntent(),
            phrases: [
                "Which Tawaaf lap am I in?",
                "What number of lap am I doing?",
                "View current lap number",
                "Current number of lap in \(.applicationName)",
                "View current lap number in \(.applicationName)",
            ],
            shortTitle: "Current Lap",
            systemImageName: "checkmark.circle"
        )
        
        AppShortcut(
            intent: RemainingLapCountIntent(),
            phrases: [
                "How many laps are left for my Tawaaf?",
                "How many laps are left to complete?",
                "How many laps are left in \(.applicationName)?",
                "View how many laps are left in \(.applicationName)"
            ],
            shortTitle: "Remaining Laps",
            systemImageName: "clock.badge.questionmark"
        )
    }
}


