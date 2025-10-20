//
//  FavouriteView.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 18/10/2025.

import SwiftUI
import MapKit

struct FavouriteView: View {
    @StateObject private var viewModel = FavoritesStoreViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favorites.isEmpty {
                    Text("No Favourites")
                } else {
                    List {
                        ForEach(viewModel.favorites) { fav in
                            NavigationLink(value: fav) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("lat: \(fav.lat), lon: \(fav.log)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.removeFavorite(lat: fav.lat, long: fav.log)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onMove(perform: viewModel.moveFavorite)
                    }
                }
            }
            .navigationTitle("Favorites")
            .toolbar { EditButton() }
            .task {
                viewModel.loadFromDefaults()
            }
            .navigationDestination(for: FavoriteLocation.self) { fav in
                FavoriteMapView(favorite: fav)
                    .onAppear { viewModel.setCurrentFavorite(fav) }
            }
        }
    }
    
    
}
