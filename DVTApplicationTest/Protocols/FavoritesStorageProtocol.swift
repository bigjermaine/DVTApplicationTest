//
//  FavoritesStorage.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 22/10/2025.
//
import Foundation


// MARK: - Persistence protocol (for dependency injection)
protocol FavoritesStorage {
    func data(forKey key: String) -> Data?
    func set(_ data: Data?, forKey key: String)
    func removeObject(forKey key: String)
}

