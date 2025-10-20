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

    func scheduleDailyWeatherReminder(hour: Int = 8, minute: Int = 0) async throws {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()

        // Prevent duplicates
        if pending.contains(where: { $0.identifier == "daily_weather_reminder" }) {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = " Daily Weather Update"
        content.body = "Check your app for today's weather forecast."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily_weather_reminder",
            content: content,
            trigger: trigger
        )

        try await center.add(request)
        print("✅ Daily weather reminder scheduled at \(hour):\(String(format: "%02d", minute))")
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
