//
//  FavoritesStore.swift
//  DVTApplicationTest
//
//  Created by Assistant on 20/10/2025.
//

import Foundation
import MapKit
import Combine
import SwiftUI


@MainActor
final class FavoritesStoreViewModel: ObservableObject {
  
    
    @Published private(set) var favorites: [FavoriteLocation] = []
    @Published private(set) var currentFavorite: FavoriteLocation? = nil
    
    private let defaults: UserDefaults
    private let favoritesKey = "favorites_list_key"
    private let currentFavoriteKey = "current_favorite_key"
    
     init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
        loadFromDefaults()
    }
    

    func setCurrentFavorite(_ favorite: FavoriteLocation?) {
        currentFavorite = favorite
        saveCurrentFavorite()
    }
    
    
    func isFavorite(lat: Double, log: Double, tolerance: Double = 0.0) -> Bool {
        guard let current = currentFavorite else { return false }
        if tolerance == 0 {
            return current.lat == lat && current.log == log
        } else {
            return abs(current.lat - lat) <= tolerance && abs(current.log - log) <= tolerance
        }
    }
    
    func addFavorite(_ favorite: FavoriteLocation) {
        if !favorites.contains(favorite) {
            favorites.append(favorite)
            saveFavorites()
        }
    }
    
    func removeFavorite(lat: Double, long:Double) {
        if let idx = favorites.firstIndex(where: { $0.lat == lat && $0.log == long}) {
            favorites.remove(at: idx)
            saveFavorites()
            if currentFavorite?.lat == lat && currentFavorite?.log == long {
                setCurrentFavorite(nil)
            }
        }
    }
    
    func moveFavorite(fromOffsets: IndexSet, toOffset: Int) {
        favorites.move(fromOffsets: fromOffsets, toOffset: toOffset)
        saveFavorites()
    }
    
     func loadFromDefaults() {
        if let data = defaults.data(forKey: favoritesKey) {
            if let decoded = try? JSONDecoder().decode([FavoriteLocation].self, from: data) {
                self.favorites = decoded
            }
        }
        if let data = defaults.data(forKey: currentFavoriteKey) {
            if let decoded = try? JSONDecoder().decode(FavoriteLocation.self, from: data) {
                self.currentFavorite = decoded
            }
        }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favorites) {
            defaults.set(data, forKey: favoritesKey)
        }
    }
    
    private func saveCurrentFavorite() {
        if let favorite = currentFavorite, let data = try? JSONEncoder().encode(favorite) {
            defaults.set(data, forKey: currentFavoriteKey)
        } else {
            defaults.removeObject(forKey: currentFavoriteKey)
        }
    }
}

