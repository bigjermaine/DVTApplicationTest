//
//  Untitled.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 18/10/2025.
//

import Foundation


enum ApiEndpoint {
 case getWeatherForcastData(lat:Int,log:Int)
 case getWeatherForcastDatas(lat:Int,log:Int)
    
}



extension ApiEndpoint {
    func request(accessToken: String? = nil) throws -> URLRequest {
        guard let url = url else {
            throw APIError.dynamic(message: "Invalid URL in ApiEndpoint. Check host, port, or path configuration.")
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 600.0
        request.addHeaders(headers)
        request.httpMethod = httpMethod.rawValue
        if requiresAuthorization {
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            } else {
                throw APIError.expiredSession
            }
        }
        request.httpBody = httpBody
        return request
    }
}

// MARK: - URL Components
extension ApiEndpoint {
    private var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        // Ensure path starts with a leading slash to build a valid URL
        let normalizedPath = path.hasPrefix("/") ? path : "/" + path
        components.path = normalizedPath
        
        if let queryParameters = queryParameters {
            components.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        return components.url
    }
    private var httpBody: Data? {
        switch self {
        default:
            return nil
        }
        
    }
        private var queryParameters: [String: String]? {
            switch self {
            case .getWeatherForcastData(lat: let lat, log: let log):
                return [
                    "lat": String(lat),
                    "lon": String(log),
                    "appid": APIkeys.main
                ]
            case .getWeatherForcastDatas(lat: let lat, log: let log):
                return [
                    "lat": String(lat),
                    "lon": String(log),
                    "appid": APIkeys.main
                ]
            }
            
        }
        
    private var path: String {
        switch self {
        case .getWeatherForcastData:
            APIEnvironment.getWeatherData
        case .getWeatherForcastDatas:
            APIEnvironment.getWeatherDatas
        }
        }
    
    
    private var hostType: APIHostType {
        switch self {
        default:
            return .generalAPI
        }
    }
    
    
    private var host: String {
            switch hostType {
            default:
                return APIEnvironment.baseAPIHost
            }
        }
}


// MARK: - Authorization and Headers
extension ApiEndpoint {
    
    var requiresAuthorization: Bool {
        switch self {
        case .getWeatherForcastData,.getWeatherForcastDatas:
            return false
            
        }
    }
    private var contentType: String {
        switch self {
        case .getWeatherForcastData,.getWeatherForcastDatas:
            return "application/x-www-form-urlencoded"
     
        }
    }
    
    private var headers: [String: String] {
        [
            "Content-Type": contentType
        ]
    }
    
}

extension ApiEndpoint {
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getWeatherForcastData,.getWeatherForcastDatas:
            
        return .GET
        }
    }
}
