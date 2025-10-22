//
//  FavoritesStore.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 20/10/2025.
//

import Foundation
import MapKit
import Combine
import SwiftUI


/// A main-actor isolated view model that manages a list of favorited locations
/// and the currently selected favorite. Persists state using an abstract
/// `FavoritesStorage` (defaulting to `UserDefaults`).
@MainActor
 class FavoritesStoreViewModel: ObservableObject {
    /// All saved favorite locations. Exposed as read-only to views; mutations go through API methods.
    @Published private(set) var favorites: [FavoriteLocation] = []
    /// The currently selected favorite, if any. Exposed as read-only to views.
    @Published private(set) var currentFavorite: FavoriteLocation? = nil
    
    /// Key-value storage used to persist favorites and the current selection.
    private let storage: FavoritesStorage
    /// Storage key for the encoded favorites array.
    private let favoritesKey = "favorites_list_key"
    /// Storage key for the encoded current favorite.
    private let currentFavoriteKey = "current_favorite_key"
    /// JSON encoder for serializing favorites to storage.
    private let encoder = JSONEncoder()
    /// JSON decoder for deserializing favorites from storage.
    private let decoder = JSONDecoder()
    
    /// Creates a new instance with the provided storage implementation.
    /// - Parameter storage: A `FavoritesStorage` conformer (defaults to `UserDefaults.standard`).
    /// Calls `loadFromStorage()` to hydrate state.
    init(storage: FavoritesStorage = UserDefaults.standard) {
        self.storage = storage
        loadFromStorage()
    }
    
    // MARK: - Public methods
    /// Sets the current favorite and persists the change.
    /// - Parameter favorite: The favorite to set as current, or `nil` to clear.
    func setCurrentFavorite(_ favorite: FavoriteLocation?) {
        currentFavorite = favorite
        saveCurrentFavorite()
    }
    
    /// Determines whether the provided coordinates match the current favorite.
    /// - Parameters:
    ///   - lat: Latitude to compare.
    ///   - log: Longitude to compare.
    ///   - tolerance: Optional absolute tolerance for both lat/log comparisons. Defaults to exact match.
    /// - Returns: `true` if within tolerance of the current favorite; otherwise `false`.
    func isFavorite(lat: Double, log: Double, tolerance: Double = 0.0) -> Bool {
        guard let current = currentFavorite else { return false }
        if tolerance == 0 {
            return current.lat == lat && current.log == log
        } else {
            return abs(current.lat - lat) <= tolerance && abs(current.log - log) <= tolerance
        }
    }
    
    /// Adds a favorite if it is not already present and persists the updated list.
    /// - Parameter favorite: The favorite to add.
    func addFavorite(_ favorite: FavoriteLocation) {
        guard !favorites.contains(favorite) else { return }
        favorites.append(favorite)
        saveFavorites()
    }
    
    /// Removes a favorite matching the given coordinates and persists changes.
    /// If the removed favorite is the current favorite, clears the current selection.
    /// - Parameters:
    ///   - lat: Latitude of the favorite to remove.
    ///   - long: Longitude of the favorite to remove.
    func removeFavorite(lat: Double, long: Double) {
        if let idx = favorites.firstIndex(where: { $0.lat == lat && $0.log == long }) {
            favorites.remove(at: idx)
            saveFavorites()
            if currentFavorite?.lat == lat && currentFavorite?.log == long {
                setCurrentFavorite(nil)
            }
        }
    }
    
    /// Reorders favorites and persists the new order.
    /// - Parameters:
    ///   - fromOffsets: Source indices to move.
    ///   - toOffset: Destination index.
    func moveFavorite(fromOffsets: IndexSet, toOffset: Int) {
        favorites.move(fromOffsets: fromOffsets, toOffset: toOffset)
        saveFavorites()
    }
    
    // MARK: - Persistence
    /// Loads favorites and current favorite from storage using best-effort decoding.
    /// Silently ignores decoding errors, leaving defaults when data is unavailable or invalid.
    func loadFromStorage() {
        if let data = storage.data(forKey: favoritesKey),
           let decoded = try? decoder.decode([FavoriteLocation].self, from: data) {
            favorites = decoded
        }
        
        if let data = storage.data(forKey: currentFavoriteKey),
           let decoded = try? decoder.decode(FavoriteLocation.self, from: data) {
            currentFavorite = decoded
        }
    }
    
    /// Persists the favorites array to storage using JSON encoding.
    /// Uses best-effort encoding; failures are silently ignored.
    private func saveFavorites() {
        if let data = try? encoder.encode(favorites) {
            storage.set(data, forKey: favoritesKey)
        }
    }
    
    /// Persists the current favorite to storage, or removes the key when `nil`.
    /// Uses best-effort encoding; failures are silently ignored.
    private func saveCurrentFavorite() {
        if let favorite = currentFavorite,
           let data = try? encoder.encode(favorite) {
            storage.set(data, forKey: currentFavoriteKey)
        } else {
            storage.removeObject(forKey: currentFavoriteKey)
        }
    }
}

