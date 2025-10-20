//
//  DesignStyle.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//

import Foundation

enum DesignStyle: String, CaseIterable, Identifiable {
    case system
    case light
   

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "forest"
        case .light: return "sea"
      
        }
    }
}
