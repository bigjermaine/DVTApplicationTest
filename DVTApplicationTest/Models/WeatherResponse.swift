//
//  WeatherResponse.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//


import Foundation


// MARK: - Unified Weather Model
struct WeatherData: Codable {
    let coord: Coord?
    let weather: [Weather]?
    let base: String?
    let main: ForecastMain
    let visibility: Int?
    let wind: Wind?
    let rain: Rain3h?
    let clouds: Clouds?
    let dt: Int
    let sys: Sys?
    let timezone: Int?
    let id: Int?
    let name: String?
    let cod: Int?
    let pop: Double?
    let dtTxt: String?
    let city: City?
   

    enum CodingKeys: String, CodingKey {
        case coord, weather, base, main, visibility, wind, rain, clouds, dt, sys, timezone, id, name, cod, pop, city
        case dtTxt = "dt_txt"
      
    }
}
