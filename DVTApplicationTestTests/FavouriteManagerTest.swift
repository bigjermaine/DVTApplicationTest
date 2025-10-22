//
//  Untitled.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 22/10/2025.
//

import XCTest
@testable import DVTApplicationTest


final class MockFavoritesStorage: FavoritesStorage {
    private var storage: [String: Data] = [:]
    func data(forKey key: String) -> Data? { storage[key] }
    func set(_ data: Data?, forKey key: String) { storage[key] = data }
    func removeObject(forKey key: String) { storage.removeValue(forKey: key) }
}

@MainActor
final class FavoritesStoreViewModelTests: XCTestCase {

    func makeSample(_ lat: Double = 10.0, _ log: Double = 20.0) -> FavoriteLocation {
        FavoriteLocation(temp: 25, name: "City", lat: lat, log: log, weatherType: .sunny)
    }

    // MARK: -  Add and Remove Favorite
    func testAddAndRemoveFavorite() async {
        await MainActor.run {
            let vm = FavoritesStoreViewModel(storage: MockFavoritesStorage())
            let sample = makeSample()
            
            vm.addFavorite(sample)
            XCTAssertEqual(vm.favorites.count, 1)
            
            vm.removeFavorite(lat: 10.0, long: 20.0)
            XCTAssertTrue(vm.favorites.isEmpty)
        }
    }

    // MARK: -  Avoid Duplicates
    func testAddDuplicateFavoriteDoesNotDuplicateList() async {
        await MainActor.run {
            let vm = FavoritesStoreViewModel(storage: MockFavoritesStorage())
            let sample = makeSample()
            
            vm.addFavorite(sample)
            vm.addFavorite(sample) // Duplicate
            
            XCTAssertEqual(vm.favorites.count, 1, "Should not add duplicate favorites")
        }
    }

    // MARK: -  Move Favorite
    func testMoveFavoriteChangesOrder() async {
        await MainActor.run {
            let vm = FavoritesStoreViewModel(storage: MockFavoritesStorage())
            let a = makeSample(10, 10)
            let b = makeSample(20, 20)
            
            vm.addFavorite(a)
            vm.addFavorite(b)
            
            vm.moveFavorite(fromOffsets: IndexSet(integer: 0), toOffset: 2)
            
            XCTAssertEqual(vm.favorites.first?.lat, 20, "Move should reorder favorites")
        }
    }

    // MARK: -  Current Favorite Persistence
    func testSetAndClearCurrentFavorite() async {
        await MainActor.run {
            let mockStorage = MockFavoritesStorage()
            let vm = FavoritesStoreViewModel(storage: mockStorage)
            let fav = makeSample(5, 6)
            
            vm.setCurrentFavorite(fav)
            XCTAssertNotNil(vm.currentFavorite)
            
            // Simulate app relaunch (reload from same mock storage)
            let newVM = FavoritesStoreViewModel(storage: mockStorage)
            XCTAssertEqual(newVM.currentFavorite?.lat, 5)
            
            vm.setCurrentFavorite(nil)
            XCTAssertNil(vm.currentFavorite)
        }
    }

    // MARK: -  Reload from Storage
    func testLoadFromStorageRestoresFavorites() async {
        await MainActor.run {
            let mockStorage = MockFavoritesStorage()
            let vm = FavoritesStoreViewModel(storage: mockStorage)
            vm.addFavorite(makeSample(1, 2))
            
            // Simulate app relaunch (new instance with same mock storage)
            let reloaded = FavoritesStoreViewModel(storage: mockStorage)
            XCTAssertEqual(reloaded.favorites.count, 1, "Favorites should persist in storage")
        }
    }

    // MARK: -  isFavorite Tolerance
    func testIsFavoriteWithTolerance() async {
        await MainActor.run {
            let vm = FavoritesStoreViewModel(storage: MockFavoritesStorage())
            let fav = makeSample(10, 10)
            vm.setCurrentFavorite(fav)
            
            XCTAssertTrue(vm.isFavorite(lat: 10.1, log: 10.1, tolerance: 0.2))
            XCTAssertFalse(vm.isFavorite(lat: 10.5, log: 10.5, tolerance: 0.2))
        }
    }
}
