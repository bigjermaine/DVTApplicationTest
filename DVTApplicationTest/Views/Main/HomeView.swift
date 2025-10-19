//
//  HomeView.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 18/10/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var weatherManagerViewModel:WeatherManagerViewModel
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear{
                weatherManagerViewModel.requestLocationAndLoadWeatherOrFallback()
            }
    }
}

#Preview {
    HomeView()
}
