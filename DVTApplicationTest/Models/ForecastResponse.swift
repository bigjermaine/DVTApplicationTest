//
//  ForecastResponse.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//


import Foundation

// MARK: - ForecastResponse
struct ForecastResponse: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [WeatherData]
    let city: City
}



// MARK: - Rain3h
struct Rain3h: Codable {
    let threeHour: Double?

    enum CodingKeys: String, CodingKey {
        case threeHour = "3h"
    }
}

// MARK: - ForecastSys
struct ForecastSys: Codable {
    let pod: String
}

