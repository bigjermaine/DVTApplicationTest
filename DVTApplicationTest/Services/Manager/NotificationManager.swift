import Foundation
import UserNotifications
import SwiftUI
import Combine

/// A main-actor isolated notification manager that wraps `UNUserNotificationCenter`.
/// Exposes authorization status, requests permissions, schedules/cancels reminders,
/// and provides a single shared instance for app-wide use.
@MainActor
final class NotificationManager: ObservableObject {
    /// Shared singleton instance for use across the app.
    static let shared = NotificationManager()

    /// Current notification authorization status, updated after permission requests or settings refresh.
    /// Exposed as read-only to observers.
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    /// Initializes the manager and immediately attempts to request authorization on a background task.
    /// Use `NotificationManager.shared` to access the singleton.
    private init() {
        Task {
            await requestAuthorization()
        }
    }

    /// Requests user authorization for notifications with the given options.
    /// - Parameter options: Authorization options (defaults to alerts, badges, and sounds).
    /// - Returns: `true` if permissions were granted; otherwise `false`.
    /// Also updates `authorizationStatus` with the most recent settings.
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

    /// Retrieves the current notification settings and updates `authorizationStatus`.
    /// - Returns: The current `UNNotificationSettings`.
    func currentSettings() async -> UNNotificationSettings {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        return settings
    }

    /// Schedules a repeating daily notification reminding the user to check the weather.
    /// Prevents duplicates by checking pending requests for the same identifier.
    /// - Parameters:
    ///   - hour: The hour component for the reminder (24h clock). Defaults to 8.
    ///   - minute: The minute component for the reminder. Defaults to 0.
    /// - Throws: Propagates errors thrown by `UNUserNotificationCenter.add(_:)`.
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
       
    }

    /// Cancels a pending notification with the specified identifier.
    /// - Parameter identifier: The identifier of the scheduled request to remove.
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    /// Cancels all pending notification requests for the app.
    func cancelAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    /// Opens the app's settings page in the Settings app to allow the user to adjust notification permissions.
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
