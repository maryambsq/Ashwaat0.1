//
//  AppIntents.swi  ft
//  Ashwaat0.1
//
//  Created by Maryam Amer Bin Siddique on 17/11/1446 AH.
//

import SwiftUI
import AppIntents

struct StartTawaafIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Tawaaf"
    static var description = IntentDescription("Begin tracking Tawaaf laps if inside the allowed area.")
    static var openAppWhenRun: Bool = true

    @AppStorage("isInGeofence") var isInGeofence: Bool = false
    @AppStorage("startTawaafFromSiri") var startTawaafFromSiri: Bool = false

    func perform() async throws -> some IntentResult {
        if isInGeofence {
            startTawaafFromSiri = true
            return .result(dialog: "📍 You are inside the allowed area. Tawaaf has started in Ashwaat.")
        } else {
            return .result(dialog: "🚫 You're not currently inside the Tawaaf zone. Please move into the area to begin.")
        }
    }
}

//struct StartTawaafResult: IntentResult {
//    var value: Never?
//    
//    let dialog: IntentDialog
//
//    // Optional: You can add other properties here if needed in the future
//}

struct AshwaatAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartTawaafIntent(),
            phrases: [
                "Start Tawaaf in Ashwaat",
                "Begin my Tawaaf",
                "Start tracking my Tawaaf",
                "Begin Tawaaf laps"
            ],
            shortTitle: "Start Tawaaf",
            systemImageName: "figure.walk.circle.fill"
        )
    }
}

//import SwiftUI
//import AppIntents
//
//struct StartTawaafIntent: AppIntent {
//    static var title: LocalizedStringResource = "Start Tawaaf"
//    static var description = IntentDescription("Begin tracking Tawaaf laps if inside the allowed area.")
//    static var openAppWhenRun: Bool = true
//
//    @AppStorage("isInGeofence") var isInGeofence: Bool = false
//    @AppStorage("startTawaafFromSiri") var startTawaafFromSiri: Bool = false
//
//    func perform() async throws -> StartTawaafResult {
//        if isInGeofence {
//            startTawaafFromSiri = true
//            return StartTawaafResult(message: "📍 You are inside the allowed area. Tawaaf has started in Ashwaat.")
//        } else {
//            return StartTawaafResult(message: "🚫 You're not currently inside the Tawaaf zone. Please move into the area to begin.")
//        }
//    }
//}
//
//struct StartTawaafResult: ProvidesDialog {
//    var message: String
//
//    var dialog: IntentDialog {
//        IntentDialog(message)
//    }
//}

//import AppIntents
//import SwiftUI
//
//struct StartTawaafIntent: AppIntent {
//    static var title: LocalizedStringResource = "Start Tawaaf"
//    static var description = IntentDescription("Begin tracking Tawaaf laps if inside the allowed area.")
//    static var openAppWhenRun: Bool = true
//
//    @AppStorage("isInGeofence") var isInGeofence: Bool = false
//    @AppStorage("startTawaafFromSiri") var startTawaafFromSiri: Bool = false
//
//    func perform() async throws -> some IntentResult {
//        if isInGeofence {
//            startTawaafFromSiri = true
//            return .result(
//                dialog: "📍 You are inside the allowed area. Tawaaf has started in Ashwaat."
//            )
//        } else {
//            return .result(
//                dialog: "🚫 You're not currently inside the Tawaaf zone. Please move into the area to begin."
//            )
//        }
//    }
//}
//
//
//struct AshwaatAppShortcuts: AppShortcutsProvider {
//    static var appShortcuts: [AppShortcut] {
//        AppShortcut(
//            intent: StartTawaafIntent(),
//            phrases: [
//                "Start Tawaaf in Ashwaat",
//                "Begin my Tawaaf",
//                "Start tracking my Tawaaf",
//                "Begin Tawaaf laps"
//            ],
//            shortTitle: "Start Tawaaf",
//            systemImageName: "figure.walk.circle.fill"
//        )
//    }
//}
//
//import AppIntents // <--- THIS IS CRUCIAL
//
//struct StartTawaafResult: AppIntentResult {
//    var message: String
//
//    var dialog: IntentDialog {
//        IntentDialog(message)
//    }
//}
