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

//    @MainActor
    func perform() async throws -> some IntentResult {
        print("🔥 StartTawaafIntent triggered!")
        if isInGeofence {
            startTawaafFromSiri = true
            return .result(dialog: "You are inside the allowed area. Tawaaf has started in Ashwaat.")
        } else {
            return .result(dialog: "You're not currently inside the Tawaaf zone. Please move into the area to begin.")
        }
        
    }
}

class AshwaatAppShortcuts: AppShortcutsProvider {
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
            systemImageName: "figure.walk.circle.fill"
        )
    }
}
