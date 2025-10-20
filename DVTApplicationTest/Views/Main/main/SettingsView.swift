//
//  SettingsView.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 18/10/2025.


import SwiftUI
import UserNotifications
import Combine
import Foundation

struct SettingsView: View {
   
    @AppStorage(SettingsKeys.hapticsEnabled) private var hapticsEnabled: Bool = false
    @AppStorage(SettingsKeys.designStyle) private var designStyle: String = DesignStyle.system.rawValue
    @AppStorage(SettingsKeys.soundEnabled) private var soundEnabled: Bool = false
    @EnvironmentObject var vm: WeatherManagerViewModel
    @State private var notificationsEnabled: Bool = false
    @State private var notificationAuthStatus: UNAuthorizationStatus = .notDetermined
    @State private var isLoadingNotificationStatus = true
    @StateObject private var notificationManager = NotificationManager.shared

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

    private func openAppSettings() {
        notificationManager.openAppSettings()
    }

    @MainActor
    private func handleDesignStyleChange(_ newValue: String) {
     
            vm.objectWillChange.send()
         
        
    }
}




#Preview {
    SettingsView()
}
