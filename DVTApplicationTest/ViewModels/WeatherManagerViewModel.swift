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

 @MainActor
 class WeatherManagerViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentWeather: WeatherData? = nil
    @Published var forecast: ForecastResponse? = nil

    // MARK: - Dependencies
     private let weatherManager: WeatherManager
     private let locationManager: LocationManager
     let apiService: APIService =  APIClient()

     
     
     init(weatherManager: WeatherManager, locationManager: LocationManager) {
         self.weatherManager = weatherManager
         self.locationManager = locationManager
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
         let defaultLat = 40  // NYC approx latitude
         let defaultLog = -74 // NYC approx longitude
         Task { await self.load(lat: defaultLat, log: defaultLog) }
     }

    func load(lat: Int, log: Int) async {
        // Reset state
        errorMessage = nil
        isLoading = true

        // Launch concurrent tasks for current weather and forecast
        async let currentTask: WeatherData = fetchCurrent(lat: lat, log: log)
        async let forecastTask: ForecastResponse = fetchForecast(lat: lat, log: log)

        do {
            let (current, forecast) = try await (currentTask, forecastTask)
            self.currentWeather = current
            self.forecast = forecast
        } catch {
            self.errorMessage = Self.humanReadable(error)
            // Clear any partial data on error to keep UI consistent
            self.currentWeather = nil
            self.forecast = nil
        }

        isLoading = false
    }

    func refreshCurrent(lat: Int, log: Int) async {
        errorMessage = nil
        isLoading = true
        do {
            let data = try await weatherManager.fetchCurrentWeather(lat: lat, log: log)
            self.currentWeather = data
        } catch {
            self.errorMessage = Self.humanReadable(error)
        }
        isLoading = false
    }

    func refreshForecast(lat: Int, log: Int) async {
        errorMessage = nil
        isLoading = true
        do {
            let data = try await weatherManager.fetchForecast(lat: lat, log: log)
            self.forecast = data
        } catch {
            self.errorMessage = Self.humanReadable(error)
        }
        isLoading = false
    }

    // MARK: - Helpers
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
