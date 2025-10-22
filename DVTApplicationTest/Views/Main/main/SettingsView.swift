//
//  SettingsView.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 18/10/2025.

import SwiftUI
import UserNotifications
import Combine
import Foundation

/// A settings screen for managing notification permissions, haptics, sound effects,
/// and the app's design style. Persists preferences using `@AppStorage` and reacts
/// to system notification authorization changes.
struct SettingsView: View {
   
    /// Whether haptic feedback is enabled throughout the app. Stored in AppStorage.
    @AppStorage(SettingsKeys.hapticsEnabled) private var hapticsEnabled: Bool = false
    /// The selected design/appearance style (system, light, dark), persisted via AppStorage.
    @AppStorage(SettingsKeys.designStyle) private var designStyle: String = DesignStyle.system.rawValue
    /// Whether sound effects are enabled in the app. Stored in AppStorage.
    @AppStorage(SettingsKeys.soundEnabled) private var soundEnabled: Bool = false
    /// Environment view model used to broadcast UI updates when design style changes.
    @EnvironmentObject var vm: WeatherManagerViewModel
    /// Convenience flag indicating if notifications are currently authorized in any allowed mode.
    @State private var notificationsEnabled: Bool = false
    /// Cached notification authorization status from UNUserNotificationCenter settings.
    @State private var notificationAuthStatus: UNAuthorizationStatus = .notDetermined
    /// True while the app is fetching the latest notification settings.
    @State private var isLoadingNotificationStatus = true
    /// Shared notification manager responsible for querying settings and scheduling reminders.
    @StateObject private var notificationManager = NotificationManager.shared

    /// Builds the settings UI, including sections for notifications, haptics, sound, and design.
    /// Also wires up lifecycle tasks to refresh notification status and handle design changes.
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Notifications")) {
                    HStack {
                        Label("Notifications", systemImage: "bell.badge")
                        Spacer()
                        if isLoadingNotificationStatus {
                            ProgressView()
                        } else {
                            Text(notificationStatusText)
                                .foregroundStyle(notificationStatusColor)
                                .font(.callout)
                        }
                    }
                    Button("Open System Settings") {
                        openAppSettings()
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.tint)
                    .disabled(isLoadingNotificationStatus)
                    .accessibilityHint("Opens the app's page in Settings to change notification permissions")
                }

                Section(header: Text("Haptics"), footer: Text("Turn on to feel haptic feedback in the app.")) {
                    Toggle(isOn: $hapticsEnabled) {
                        Label("Haptic Effects", systemImage: "waveform")
                    }
                }

                Section(header: Text("Sound"), footer: Text("Turn off to mute app sound effects.")) {
                    Toggle(isOn: $soundEnabled) {
                        Label("Sound Effects", systemImage: "speaker.wave.2.fill")
                    }
                }

                Section(header: Text("Design")) {
                    Picker(selection: $designStyle) {
                        ForEach(DesignStyle.allCases, id: \.self) { style in
                            Text(style.displayName).tag(style.rawValue)
                        }
                    } label: {
                        Label("Appearance", systemImage: "paintbrush")
                    }
                }
            }
            .navigationTitle("Settings")
            .onChange(of: designStyle) { newValue in
                handleDesignStyleChange(newValue)
            }
            .task {
                await refreshNotificationStatus()
            }
            .refreshable {
                await refreshNotificationStatus()
            }
        }
    }

    /// Human-readable text describing the current notification authorization state.
    private var notificationStatusText: String {
        switch notificationAuthStatus {
        case .authorized, .provisional, .ephemeral:
            return "On"
        case .denied:
            return "Off"
        case .notDetermined:
            return "Not Determined"
        @unknown default:
            return "Unknown"
        }
    }

    /// Color used to visually indicate the notification authorization state.
    private var notificationStatusColor: Color {
        switch notificationAuthStatus {
        case .authorized, .provisional, .ephemeral:
            return .green
        case .denied:
            return .red
        case .notDetermined:
            return .secondary
        @unknown default:
            return .secondary
        }
    }

    /// Refreshes the current notification authorization status.
    /// - Important: Runs on the main actor to keep UI state consistent.
    /// - Updates `notificationAuthStatus`, `notificationsEnabled`, and loading state.
    /// - If notifications are enabled, attempts to schedule a daily weather reminder.
    @MainActor
    private func refreshNotificationStatus() async {
        isLoadingNotificationStatus = true
        let settings = await notificationManager.currentSettings()
        notificationAuthStatus = settings.authorizationStatus
        notificationsEnabled = (settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional || settings.authorizationStatus == .ephemeral)
        if notificationsEnabled {
           
        try? await NotificationManager.shared.scheduleDailyWeatherReminder()
             
        }
        isLoadingNotificationStatus = false
    }

    /// Opens the app's page in the system Settings app so the user can adjust permissions.
    private func openAppSettings() {
        notificationManager.openAppSettings()
    }

    /// Notifies dependent views that the design style has changed so they can update.
    /// - Parameter newValue: The newly selected design style raw value.
    @MainActor
    private func handleDesignStyleChange(_ newValue: String) {
     
            vm.objectWillChange.send()
         
        
    }
}




#Preview {
    SettingsView()
}

