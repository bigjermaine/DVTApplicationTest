//
//  FavouriteView.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 18/10/2025.

import SwiftUI
import MapKit

/// - Navigates to a map view (`FavoriteMapView`) for a selected favorite.
struct FavouriteView: View {
    /// Backing store/view model that manages loading, ordering, and deleting favorites.
    @StateObject private var viewModel = FavoritesStoreViewModel()
    
    var body: some View {
        // Root navigation for listing and drilling into favorite locations.
        NavigationStack {
            Group {
                // Show placeholder when there are no saved favorites.
                if viewModel.favorites.isEmpty {
                    Text("No Favourites")
                } else {
                    // List of saved favorites with navigation and swipe-to-delete.
                    List {
                        ForEach(viewModel.favorites) { fav in
                            NavigationLink(value: fav) {
                                // Basic display of coordinates for the favorite.
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("lat: \(fav.lat), lon: \(fav.log)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) { // Enable swipe-to-delete
                                Button(role: .destructive) { // Remove from favorites
                                    viewModel.removeFavorite(lat: fav.lat, long: fav.log)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onMove(perform: viewModel.moveFavorite) // Support reordering in Edit mode
                    }
                }
            }
            .navigationTitle("Favorites")
            .toolbar { EditButton() } // Toggle Edit mode for reordering
            .task { // Load persisted favorites when the view appears
                // One-time load of favorites from storage.
                viewModel.loadFromStorage()
            }
            .navigationDestination(for: FavoriteLocation.self) { fav in // Navigate to detail map for the selected favorite
                FavoriteMapView(favorite: fav)
                    .onAppear { viewModel.setCurrentFavorite(fav) } // Provide context to the view model for downstream consumers
            }
        }
    }
    
    
}
