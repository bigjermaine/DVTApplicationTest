//
//  TabbarView.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 18/10/2025.
//

import SwiftUI

struct TabbarView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

          
            FavouriteView()
                .tabItem {
                    Label("Favourites", systemImage: "star")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    TabbarView()
}
