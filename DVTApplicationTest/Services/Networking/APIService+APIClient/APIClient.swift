//
//  APICLIENT.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//

import Foundation
import SwiftUI


final class APIClient: APIService {
    static let shared = APIClient()

    init() {
        
    }
    
    func getWeatherData(lat: Int, log: Int) async throws -> Result < WeatherData , ErrorResponse>{
        try await request(.getWeatherForcastData(lat: lat, log:log))
    }
    
    func getWeatherDatas(lat: Int, log: Int) async throws  -> Result < ForecastResponse , ErrorResponse>{
        try await  request(.getWeatherForcastDatas(lat: lat, log: log))
    }
    

}

private struct APIServiceKey: EnvironmentKey {
    static let defaultValue: APIService = APIClient()
}

extension EnvironmentValues {
    var apiService: APIService {
        get { self[APIServiceKey.self] }
        set { self[APIServiceKey.self] = newValue }
    }
}
extension APIClient {
    func request<T: Decodable, U: Decodable>(
        _ endpoint: ApiEndpoint
    ) async throws -> Result<T, U> {
   
        let request = try endpoint.request()
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.failedRequest
        }
        
        let statusCode = httpResponse.statusCode
        let decoder = JSONDecoder()
        
        // MARK: - 2. Debug logging
        #if DEBUG
      
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
          
        } else {
          
        }
        #endif
        
        // MARK: - 3. Handle non-success responses
        guard (200..<300).contains(statusCode) else {
            switch statusCode {
            default:
                do {
                    let errorResponse = try decoder.decode(U.self, from: data)
                    return .failure(errorResponse)
                } catch {
                    throw APIError.invalidResponse
                }
            }
        }
        // MARK: - 4. Decode success response
        do {
            let success = try decoder.decode(T.self, from: data)
            return .success(success)
        } catch let error as DecodingError {
            throw APIError.invalidResponse
        } catch {
          
            throw APIError.invalidResponse
        }
    }

}

