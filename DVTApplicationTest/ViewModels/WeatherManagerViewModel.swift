//
//  WeatherManagerViewModel.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//
//  View model that orchestrates weather loading, location handling, and local caching/persistence.

import Foundation
import SwiftUI
import Combine
import CoreLocation
import CoreData

/// A main-actor isolated view model that coordinates:
/// - requesting user location and handling authorization
/// - fetching current weather and multi-day forecasts
/// - caching/restoring state via Core Data and lightweight persistence
/// - deriving a high-level `WeatherType` for UI
///
/// Designed to be injected with `WeatherManager` (network layer) and `LocationManager` (location layer).
@MainActor
class WeatherManagerViewModel: ObservableObject {
    /// Indicates whether a network operation currently in progress.
    @Published var isLoading: Bool = false
    
    /// User-presentable error message for the last failed operation, if any.
    @Published var errorMessage: String? = nil
    
    /// The most recently loaded current weather conditions for the active coordinates.
    @Published var currentWeather: WeatherData? = nil
    
    /// Next five days of daily forecasts derived from the forecast API and/or cache.
    @Published var dailyForecasts: [DailyForecast] = []
    
    /// Derived, high-level weather classification used to drive UI themes and icons.
    @Published var weatherType:WeatherType = .none
    
    /// The active latitude (integer truncated from actual coordinate) used for requests and favorites.
    @Published var latitude:Int = 0
    
    /// The active longitude (integer truncated from actual coordinate) used for requests and favorites.
    @Published var longitude:Int = 0
    
    // MARK: - Dependencies
    
    /// Network service responsible for fetching weather data.
    private let weatherManager: WeatherManager
    
    /// Location service wrapper responsible for authorization and current location updates.
    private let locationManager: LocationManager
    
    /// Core Data view model used to persist and observe saved forecasts.
    private let coreDataVM: CoreDataWeatherViewModel =  CoreDataWeatherViewModel()
    
    /// Combine cancellables for managing subscriptions.
    private var cancellables = Set<AnyCancellable>()
    
    /// Lightweight key-value persistence for quick restore of `weatherType` and `currentWeather`.
    let persistence = WeatherStateStorage()
    
    /// Creates a new instance injecting required services.
    /// - Parameters:
    ///   - weatherManager: The network layer used to fetch weather data.
    ///   - locationManager: The location layer used to request authorization and current location.
    ///
    /// Side effects:
    /// - Seeds `dailyForecasts` from Core Data cache
    /// - Subscribes to Core Data publisher and loads persisted state
    /// - Triggers the location + loading flow via `getCache()`
    init(weatherManager: WeatherManager, locationManager: LocationManager) {
        self.weatherManager = weatherManager
        self.locationManager = locationManager
        self.dailyForecasts = coreDataVM.dailyForecasts
        getCache()
      
    }
    /// Subscribes to cached forecasts, restores persisted state, and begins the location-driven loading flow.
    ///
    /// - Wires `coreDataVM.$dailyForecasts` to keep `dailyForecasts` in sync on the main thread.
    /// - Restores `weatherType` and `currentWeather` from lightweight persistence.
    /// - Requests authorization and, if possible, loads weather; otherwise falls back to defaults.
    func getCache() {
        coreDataVM.$dailyForecasts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.dailyForecasts = $0 }
            .store(in: &cancellables)
        
        let initial = persistence.loadInitialState()
        self.weatherType = initial.weatherType ?? .none
        if let savedCurrent = initial.currentWeather {
            self.currentWeather = savedCurrent
        }
        requestLocationAndLoadWeatherOrFallback()
    }
    
    /// Builds a `FavoriteLocation` snapshot from current state.
    /// Uses `feelsLikeCelsius` when available, otherwise `maxCelsius` as the temperature.
    /// Coordinates are truncated integers converted to `Double`.
    func getFavourite() -> FavoriteLocation {
        return FavoriteLocation(temp: (currentWeather?.feelsLikeCelsius ?? currentWeather?.maxCelsius) ?? 0 , lat:Double(latitude) ,log: Double(longitude), weatherType: weatherType)
    }
    
    /// Requests location authorization and wires callbacks for updates, errors, and authorization changes.
    /// On success, attempts to fetch weather for the current location; otherwise falls back to defaults.
    func requestLocationAndLoadWeatherOrFallback() {
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.onLocationUpdate = { [weak self] location in
            self?.handleLocationUpdate(location)
        }
        
        locationManager.onError = { [weak self] message in
            self?.handleLocationError(nil)
        }
        locationManager.onAuthorizationChange = { [weak self] status in
            self?.handleAuthorization(status)
        }
    }
    
    /// Handles authorization changes by requesting a one-shot location on approval or falling back to defaults when denied/restricted.
    func handleAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestCurrentLocation()
        case .denied, .restricted:
            
            fallbackToUSADefaults()
        case .notDetermined:
            break
        @unknown default:
            fallbackToUSADefaults()
        }
    }
    
    /// Receives a location update, truncates to integer coordinates, updates state, and kicks off an async load.
    /// - Parameter location: The most recent `CLLocation` from the system.
    func handleLocationUpdate(_ location: CLLocation) {
        let lat = Int(location.coordinate.latitude)
        let log = Int(location.coordinate.longitude)
        latitude = lat
        longitude = log
        Task { await self.load(lat: lat, log: log) }
    }
    
    /// Maps an optional error to a user-presentable message and falls back to default coordinates.
    func handleLocationError(_ error: Error?) {
        if let error = error {
            self.errorMessage = Self.humanReadable(error)
        }
        fallbackToUSADefaults()
    }
    
    /// Falls back to default coordinates (approx. New York City: 40, -74) when location is unavailable.
    private func fallbackToUSADefaults() {
        let defaultLat = 40
        let defaultLog = -74
        Task { await self.load(lat: defaultLat, log: defaultLog) }
    }
    
    /// Loads current weather and forecast concurrently for the provided coordinates.
    /// Updates loading/error state, derives `weatherType`, persists results, and refreshes cached forecasts.
    /// - Parameters:
    ///   - lat: Latitude (integer truncated).
    ///   - log: Longitude (integer truncated).
    /// - Note: Runs on the main actor for state updates; network calls execute concurrently via `async let`.
    func load(lat: Int, log: Int) async {
      
        errorMessage = nil
        isLoading = true
        
        async let currentTask: WeatherData = fetchCurrent(lat: lat, log: log)
        async let forecastTask: ForecastResponse = fetchForecast(lat: lat, log: log)
        
        do {
            let (x, y) = try await (currentTask, forecastTask)
            currentWeather = x
            determineWeatherType(from: x)
            print(y)
            let nextFive = y.list.nextFiveDays(timezoneOffsetSeconds: y.city?.timezone ?? 0)
            dailyForecasts = nextFive
            print(dailyForecasts)
            coreDataVM.replaceAllSavedForecasts(with: nextFive)
            
        } catch {
            errorMessage = Self.humanReadable(error)
    
        }
        
        isLoading = false
    }
    
    /// Refreshes only the current weather for the given coordinates without updating forecasts.
    func refreshCurrent(lat: Int, log: Int) async {
        errorMessage = nil
        isLoading = true
        do {
            let data = try await weatherManager.fetchCurrentWeather(lat: lat, log: log)
            currentWeather = data
        } catch {
            errorMessage = Self.humanReadable(error)
        }
        isLoading = false
    }
    
    
    /// Derives a coarse `WeatherType` from conditions using a simple heuristic:
    /// - Rain if condition mentions rain, recent rain amount > 0, or POP >= 0.5
    /// - Cloudy if condition mentions clouds or cloudiness > 50%
    /// - Sunny otherwise
    /// Persists both the derived `weatherType` and the current weather snapshot for quick restore.
    @MainActor
    func determineWeatherType(from item: WeatherData)  {
        let mainCondition = item.weather?.first?.main.lowercased() ?? ""
        let cloudiness = item.clouds?.all ?? 0
        let pop = item.pop ?? 0
        let rainAmount3h = item.rain?.threeHour ?? 0
        
        if mainCondition.contains("rain")
            || rainAmount3h > 0
            || pop >= 0.5 {
            weatherType = .rainy
        }else if mainCondition.contains("cloud") || cloudiness > 50 {
            weatherType =  .cloudy
        }else {
            weatherType =  .sunny
        }
        persistence.saveWeatherType(weatherType)
        if let currentWeather = currentWeather {
            persistence.saveCurrentWeather(currentWeather)
        }
      
    }
    
    /// Delegates to `weatherManager` to fetch current weather. Throws on failure.
    private func fetchCurrent(lat: Int, log: Int) async throws -> WeatherData {
        try await weatherManager.fetchCurrentWeather(lat: lat, log: log)
    }
    
    /// Delegates to `weatherManager` to fetch multi-day forecast. Throws on failure.
    private func fetchForecast(lat: Int, log: Int) async throws -> ForecastResponse {
        try await weatherManager.fetchForecast(lat: lat, log: log)
    }
    
    /// Produces a user-facing message from an error, preferring `LocalizedError` descriptions when available.
    private static func humanReadable(_ error: Error) -> String {
        // Provide a simple mapping for now; this can be expanded to inspect domain-specific errors
        if let localized = error as? LocalizedError, let desc = localized.errorDescription {
            return desc
        }
        return error.localizedDescription.isEmpty ? "Something went wrong. Please try again." : error.localizedDescription
    }
}

