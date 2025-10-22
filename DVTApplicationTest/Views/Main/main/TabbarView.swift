//
//  TabbarView.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 18/10/2025.
//
import SwiftUI

/// A container view that presents the app's primary tabs (Home, Favourites, Settings).
///
/// - Injects `WeatherManagerViewModel` and `FavoritesStoreViewModel` into the environment so child
///   views can access shared state.
/// - Applies a toolbar background style to the tab bar.
/// - Adds light haptic and tap sound feedback when a tab's root view appears.
struct TabbarView: View {
    /// Shared weather manager used by views in the hierarchy.
    ///
    /// Initializes with a concrete `APIClient` and a `CLLocationManager` wrapper.
    @StateObject var weatherManagerViewModel = WeatherManagerViewModel(
        weatherManager: .init(apiService: APIClient.shared),
        locationManager: .init()
    )
    /// In-memory store for user's favourite locations/items shared across tabs.
    @StateObject var favoritesStoreViewModel = FavoritesStoreViewModel()
    
    /// Builds the tab bar interface and injects environment objects for downstream views.
    var body: some View {
        TabView {
            // Home tab — shows current weather and overview
            HomeView()
                .tabTapFeedback() 
                .tabItem {
                    Label("Home", systemImage: "house")
                }
               
            // Favourites tab — manage and view saved locations
            FavouriteView()
                .tabTapFeedback()
                .tabItem {
                    Label("Favourites", systemImage: "star")
                }

            // Settings tab — app preferences and configuration
            SettingsView()
                .tabTapFeedback()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        /// Make shared view models available to all tab content.
        .environmentObject(weatherManagerViewModel)
        .environmentObject(favoritesStoreViewModel)
        /// Ensure the tab bar uses a visible, solid background for contrast.
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(Color.black, for: .tabBar)
    }
    
}

/// Preview for design-time rendering of the tab bar.
#Preview {
    TabbarView()
}

/// A view modifier that triggers light haptic feedback and a tap sound when the view appears.
///
/// Applied to each tab's root view so that switching tabs provides tactile and audible confirmation.
/// Note: `onAppear` is invoked when the tab's root view becomes active/visible.
struct TapFeedbackModifier: ViewModifier {
       func body(content: Content) -> some View {
           // Trigger feedback when the tab's root view appears (i.e., when the tab is selected)
           content.onAppear {
               HapticManager.shared.vibrateForSelection()
               SoundManager.shared.playTap()
           }
       }
   }

/// Convenience API to apply `TapFeedbackModifier` to any view.
extension View {
       /// Adds selection haptics and a tap sound when this view appears.
       func tabTapFeedback() -> some View { modifier(TapFeedbackModifier()) }
   }
