import Foundation
import UserNotifications
import SwiftUI
import Combine

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private init() {
        Task {
            await requestAuthorization()
        }
    }
     
   
    func requestAuthorization(options: UNAuthorizationOptions = [.alert, .badge, .sound]) async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: options)
            let settings = await center.notificationSettings()
            authorizationStatus = settings.authorizationStatus
            return granted
        } catch {
           
            return false
        }
    }

    
    func currentSettings() async -> UNNotificationSettings {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        return settings
    }

  
    func scheduleLocalNotification(
        identifier: String = UUID().uuidString,
        title: String,
        body: String,
        timeInterval: TimeInterval,
        repeats: Bool = false
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, timeInterval), repeats: repeats)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        try await UNUserNotificationCenter.current().add(request)
    }

  
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

   
    func cancelAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

  
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
