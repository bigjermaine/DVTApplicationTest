//
//  WeatherManager.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//

import SwiftUI



final class WeatherManager {
    
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    @discardableResult
    func fetchCurrentWeather(lat: Int, log: Int) async throws -> WeatherData {
        let response = try await apiService.getWeatherData(lat: lat, log: log)
        switch response {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }

    @discardableResult
    func fetchForecast(lat: Int, log: Int) async throws -> ForecastResponse {
        let response = try await apiService.getWeatherDatas(lat: lat, log: log)
        switch response {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
    
}
