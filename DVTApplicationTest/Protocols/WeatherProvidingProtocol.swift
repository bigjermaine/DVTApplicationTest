//
//  WeatherProviding.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 22/10/2025.
//
import Foundation
import CoreLocation

protocol WeatherProviding {
    func fetchCurrentWeather(lat: Int, log: Int) async throws -> WeatherData
    func fetchForecast(lat: Int, log: Int) async throws -> ForecastResponse
}

protocol LocationProviding {
    var onLocationUpdate: ((CLLocation) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)? { get set }
    
    func requestWhenInUseAuthorization()
    func requestCurrentLocation()
}

protocol ForecastPersisting {
    var dailyForecasts: [DailyForecast] { get set }
    func replaceAllSavedForecasts(with: [DailyForecast])
}

protocol WeatherStateStoring {
    func loadInitialState() -> WeatherData
    func saveWeatherType(_ type: WeatherType)
    func saveCurrentWeather(_ data: WeatherData)
}
