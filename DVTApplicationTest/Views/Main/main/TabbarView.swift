//
//  TabbarView.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 18/10/2025.
//

import SwiftUI

struct TabbarView: View {
    @StateObject var weatherManagerViewModel = WeatherManagerViewModel(
        weatherManager: .init(apiService: APIClient.shared),
        locationManager: .init()
    )
    var body: some View {
        TabView {
            HomeView()
                .tabTapFeedback() 
                .tabItem {
                    Label("Home", systemImage: "house")
                }
               
            FavouriteView()
                .tabTapFeedback()
                .tabItem {
                    Label("Favourites", systemImage: "star")
                }

            SettingsView()
                .tabTapFeedback()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .environmentObject(weatherManagerViewModel)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(Color.black, for: .tabBar)  
    }
    
}

#Preview {
    TabbarView()
}

struct TapFeedbackModifier: ViewModifier {
       func body(content: Content) -> some View {
           content.onAppear {
               HapticManager.shared.vibrateForSelection()
               SoundManager.shared.playTap()
           }
       }
   }

   extension View {
       func tabTapFeedback() -> some View { modifier(TapFeedbackModifier()) }
   }
