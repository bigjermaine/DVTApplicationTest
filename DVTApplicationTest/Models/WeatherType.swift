//
//  WeatherType.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//

import Foundation
import SwiftUI


enum WeatherType: String, CaseIterable {
    case sunny = "SUNNY"
    case cloudy = "CLOUDY"
    case rainy = "RAINY"
    case none = "None"
    
    /// SF Symbol for each weather type
    var systemImage: String {
        switch self {
        case .sunny:
            return "sun.max.fill"
        case .cloudy:
            return "cloud.fill"
        case .rainy:
            return "cloud.rain.fill"
        case .none:
            return "questionmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .sunny:
            return  UserDefaults().designStyle != "system"  ?  Color.color5B8EDC : Color.color47AB2F
        case .cloudy:
            return Color.color54717A
        case .rainy:
            return Color.color57575D
        case .none:
            return Color.secondary
        }
    }
     var backgroundImage: String {
         switch self {
         case .sunny:
             return   UserDefaults().designStyle != "system"  ? "sea_sunnypng" : "forest_sunny"
         case .cloudy:
             return  UserDefaults().designStyle != "system"  ? "sea_cloudy" :"forest_cloudy"
         case .rainy:
             return UserDefaults().designStyle != "system"  ? "sea_rainy" : "forest_rainy"
         case .none:
             return ""
         }
        
    }
}
