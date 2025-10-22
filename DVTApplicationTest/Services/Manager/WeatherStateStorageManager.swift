//
//  WeatherStateStorage.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 20/10/2025.
//
//  Lightweight persistence for weather state (type + current snapshot) via UserDefaults.
//

import Foundation

/// Provides lightweight, key-value persistence for weather-related UI state
/// using `UserDefaults`. Stores a derived `WeatherType` and a `WeatherData`
/// snapshot to quickly restore the app's last-known state.
struct WeatherStateStorage {
    /// UserDefaults key for the stored `WeatherType` raw value.
    private let weatherTypeKey = "weatherType"
    /// UserDefaults key for the encoded `WeatherData` snapshot.
    private let currentWeatherKey = "currentWeather"

    /// Persists the provided `WeatherType` to `UserDefaults`.
    /// - Parameter type: The weather classification to store.
    func saveWeatherType(_ type: WeatherType) {
        UserDefaults.standard.set(type.rawValue, forKey: weatherTypeKey)
    }

    /// Loads the previously stored `WeatherType` from `UserDefaults`.
    /// - Returns: The stored `WeatherType`, or `nil` if absent or invalid.
    func loadWeatherType() -> WeatherType? {
        guard let rawValue = UserDefaults.standard.string(forKey: weatherTypeKey) else {
            return nil
        }
        return WeatherType(rawValue: rawValue)
    }

    /// Persists a `WeatherData` snapshot to `UserDefaults` using JSON encoding.
    /// - Parameter weather: The current weather snapshot to store.
    func saveCurrentWeather(_ weather: WeatherData) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(weather) {
            UserDefaults.standard.set(encoded, forKey: currentWeatherKey)
        }
    }

    /// Loads a previously stored `WeatherData` snapshot from `UserDefaults` using JSON decoding.
    /// - Returns: The decoded `WeatherData`, or `nil` if decoding fails or no data exists.
    func loadCurrentWeather() -> WeatherData? {
        guard let data = UserDefaults.standard.data(forKey: currentWeatherKey) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(WeatherData.self, from: data)
    }
   
    /// Convenience method that loads both `weatherType` and `currentWeather` in one call.
    /// - Returns: A tuple containing the optional `WeatherType` and optional `WeatherData`.
    func loadInitialState() -> (weatherType: WeatherType?, currentWeather: WeatherData?) {
        let type = loadWeatherType()
        let current = loadCurrentWeather()
        return (type, current)
    }
}
