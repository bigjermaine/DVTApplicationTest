//
//  WeatherStateStorage.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 20/10/2025.
//


import Foundation

struct WeatherStateStorage {
    private let weatherTypeKey = "weatherType"
    private let currentWeatherKey = "currentWeather"

    func saveWeatherType(_ type: WeatherType) {
        UserDefaults.standard.set(type.rawValue, forKey: weatherTypeKey)
    }

    func loadWeatherType() -> WeatherType? {
        guard let rawValue = UserDefaults.standard.string(forKey: weatherTypeKey) else {
            return nil
        }
        return WeatherType(rawValue: rawValue)
    }

    func saveCurrentWeather(_ weather: WeatherData) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(weather) {
            UserDefaults.standard.set(encoded, forKey: currentWeatherKey)
        }
    }

    func loadCurrentWeather() -> WeatherData? {
        guard let data = UserDefaults.standard.data(forKey: currentWeatherKey) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(WeatherData.self, from: data)
    }
   
    func loadInitialState() -> (weatherType: WeatherType?, currentWeather: WeatherData?) {
        let type = loadWeatherType()
        let current = loadCurrentWeather()
        return (type, current)
    }
}
