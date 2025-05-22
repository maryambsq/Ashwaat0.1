import Foundation
import WatchConnectivity
import SwiftUI
import Combine

class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    // MARK: - Published Properties
    @Published var messages: [String] = []        // الرسائل النصية البسيطة (مثل: "startTawaf")
    @Published var lapsData: [LapModel] = []      // بيانات الأشواط المستقبَلة
    @Published var isTrackingActive: Bool = false // لتحديد إن كان التتبع بدأ من iOS
    @Published var totalDuration: Int = 0         // الوقت الكلي للطواف بعد الانتهاء
    @Published var totalSteps: Int = 0            // عدد الخطوات بعد الانتهاء

    private var session: WCSession

    // MARK: - Init
    override init() {
        self.session = WCSession.default
        super.init()

        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    // MARK: - إرسال رسالة نصية بسيطة (مثل: "startTawaf" أو "showSummary")
    func sendMessage(_ text: String) {
        guard session.activationState == .activated else {
            print("📭 Session not activated.")
            return
        }

        if session.isReachable {
            session.sendMessage(["message": text], replyHandler: nil) { error in
                print("❌ Error sending message: \(error.localizedDescription)")
            }
        } else {
            print("📡 Device not reachable.")
        }
    }

    // MARK: - إرسال بيانات شوط واحد
    func sendLapModel(_ lap: LapModel) {
        guard session.activationState == .activated else { return }

        do {
            let data = try JSONEncoder().encode(lap)
            let message: [String: Any] = ["lapData": data]

            session.sendMessage(message, replyHandler: nil) { error in
                print("❌ Error sending lap data: \(error.localizedDescription)")
            }
        } catch {
            print("❌ Failed to encode LapModel: \(error)")
        }
    }

    // MARK: - إرسال بيانات الملخص (المدة + الخطوات)
    func sendSummary(duration: Int, steps: Int) {
        guard session.activationState == .activated else { return }

        let message: [String: Any] = [
            "duration": duration,
            "steps": steps
        ]

        session.sendMessage(message, replyHandler: nil) { error in
            print("❌ Error sending summary data: \(error.localizedDescription)")
        }
    }

    // MARK: - WCSessionDelegate Methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("⚠️ Activation error: \(error.localizedDescription)")
        } else {
            print("✅ Session activated: \(activationState.rawValue)")
        }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("📴 Session became inactive.")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        print("⌚️ Watch state changed: installed=\(session.isWatchAppInstalled), reachable=\(session.isReachable)")
    }
    #endif

    // MARK: - استقبال الرسائل من الطرف الآخر
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            // ✅ استقبال رسالة نصية
            if let text = message["message"] as? String {
                print("📩 Received message: \(text)")
                self.messages.append(text)

                if text == "startTawaf" {
                    self.isTrackingActive = true
                }
            }

            // ✅ استقبال بيانات الشوط
            if let data = message["lapData"] as? Data {
                do {
                    let lap = try JSONDecoder().decode(LapModel.self, from: data)
                    self.lapsData.append(lap)
                    print("✅ Received lap: \(lap)")
                } catch {
                    print("❌ Failed to decode LapModel: \(error)")
                }
            }

            // ✅ استقبال بيانات الملخص
            if let duration = message["duration"] as? Int {
                self.totalDuration = duration
                print("⏱️ Received duration: \(duration)")
            }

            if let steps = message["steps"] as? Int {
                self.totalSteps = steps
                print("👣 Received steps: \(steps)")
            }
        }
    }
}
