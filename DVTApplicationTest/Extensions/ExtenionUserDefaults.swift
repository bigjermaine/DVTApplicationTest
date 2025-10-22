//
//  ExtenionUserDefaults.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 22/10/2025.
//

import Foundation

// MARK: - Default implementation for production
extension UserDefaults: FavoritesStorage {
    func set(_ data: Data?, forKey key: String) {
        if let data = data {
            setValue(data, forKey: key)
        } else {
            removeObject(forKey: key)
        }
    }
}
