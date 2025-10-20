//
//  WeatherManager.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//

import Foundation
import SwiftUI
import Combine
import CoreLocation
import CoreData


@MainActor
class WeatherManagerViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentWeather: WeatherData? = nil
    @Published var dailyForecasts: [DailyForecast] = []
    @Published var weatherType:WeatherType = .none
    
    // MARK: - Dependencies
    private let weatherManager: WeatherManager
    private let locationManager: LocationManager
    private let coreDataVM: CoreDataWeatherViewModel =  CoreDataWeatherViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    init(weatherManager: WeatherManager, locationManager: LocationManager) {
        self.weatherManager = weatherManager
        self.locationManager = locationManager
        self.dailyForecasts = coreDataVM.dailyForecasts
        coreDataVM.$dailyForecasts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.dailyForecasts = $0 }
            .store(in: &cancellables)
        requestLocationAndLoadWeatherOrFallback()
    }
    
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
    
    func handleLocationUpdate(_ location: CLLocation) {
        let lat = Int(location.coordinate.latitude)
        let log = Int(location.coordinate.longitude)
        Task { await self.load(lat: lat, log: log) }
    }
    
    
    func handleLocationError(_ error: Error?) {
        if let error = error {
            self.errorMessage = Self.humanReadable(error)
        }
        fallbackToUSADefaults()
    }
    
    private func fallbackToUSADefaults() {
        let defaultLat = 40
        let defaultLog = -74
        Task { await self.load(lat: defaultLat, log: defaultLog) }
    }
    
    func load(lat: Int, log: Int) async {
        errorMessage = nil
        isLoading = true
        
        async let currentTask: WeatherData = fetchCurrent(lat: lat, log: log)
        async let forecastTask: ForecastResponse = fetchForecast(lat: lat, log: log)
        
        do {
            let (x, y) = try await (currentTask, forecastTask)
            currentWeather = x
            determineWeatherType(from: x)
            let nextFive = y.list.nextFiveDays(timezoneOffsetSeconds: y.city?.timezone ?? 0)
            dailyForecasts = nextFive
            coreDataVM.replaceAllSavedForecasts(with: nextFive)
            
        } catch {
            errorMessage = Self.humanReadable(error)
            currentWeather = nil
    
        }
        
        isLoading = false
    }
    
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
    
    func refreshForecast(lat: Int, log: Int) async {
        errorMessage = nil
        isLoading = true
        do {
            let data = try await weatherManager.fetchForecast(lat: lat, log: log)
            
        } catch {
            errorMessage = Self.humanReadable(error)
        }
        isLoading = false
    }
    
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
    }
    
    
    private func fetchCurrent(lat: Int, log: Int) async throws -> WeatherData {
        try await weatherManager.fetchCurrentWeather(lat: lat, log: log)
    }
    
    private func fetchForecast(lat: Int, log: Int) async throws -> ForecastResponse {
        try await weatherManager.fetchForecast(lat: lat, log: log)
    }
    
    private static func humanReadable(_ error: Error) -> String {
        // Provide a simple mapping for now; this can be expanded to inspect domain-specific errors
        if let localized = error as? LocalizedError, let desc = localized.errorDescription {
            return desc
        }
        return error.localizedDescription.isEmpty ? "Something went wrong. Please try again." : error.localizedDescription
    }
}

