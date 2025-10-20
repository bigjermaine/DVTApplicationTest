//
//  APIEnvironment.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//

import Foundation

enum APIEnvironment {}

extension APIEnvironment {
    // Base host for the general API requests
    static var baseAPIHost: String {
        "api.openweathermap.org"
    }
    
    
}
extension APIEnvironment {
    
    // MARK: - Authentication Endpoints
    
    static var  getWeatherData: String {
       return "/data/2.5/weather"
    }
    
    static var getWeatherDatas: String {
        "/data/2.5/forecast"
    }
    
    
}
