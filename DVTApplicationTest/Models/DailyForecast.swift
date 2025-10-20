//
//  DailyForecast.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//

import Foundation


struct DailyForecast: Identifiable {
    let id = UUID()
    let day: String
    let minTemp: Int
    let maxTemp: Int
    let icon: String
}
