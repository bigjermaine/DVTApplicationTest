//
//  FavoriteLocation.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 20/10/2025.
//

import Foundation
import CoreLocation

struct FavoriteLocation: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String?
    var lat: Double
    var log: Double
    var temp:Int
    var weatherTypeRaw: String
    
    init(id: UUID = UUID(),temp:Int, name: String? = nil, lat: Double, log: Double, weatherType: WeatherType) {
        self.id = id
        self.name = name
        self.lat = lat
        self.log = log
        self.temp = temp
        self.weatherTypeRaw = weatherType.rawValue
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: log)
    }
   
    
    var weatherType: WeatherType {
        WeatherType(rawValue: weatherTypeRaw) ?? .none
    }
}
