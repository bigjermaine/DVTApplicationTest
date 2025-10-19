//
//  Untitled.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//


protocol APIService {
    
    func getWeatherData(lat:Int,log:Int)  async throws -> Result < WeatherData , ErrorResponse>
    func getWeatherDatas(lat:Int,log:Int)   async throws  -> Result < ForecastResponse , ErrorResponse>
    
    
}
