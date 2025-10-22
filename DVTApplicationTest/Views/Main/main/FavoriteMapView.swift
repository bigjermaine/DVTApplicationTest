//
//  FavoriteMapView.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 20/10/2025.
//

import SwiftUI
import UIKit
import MapKit
import CoreGraphics
import CoreLocation
import Foundation

/// A SwiftUI view that displays a map centered on a user's favorite location.
///
/// The view initializes a small region around the favorite's coordinates and
/// shows a single marker annotation. A bottom inset presents the place name
/// and a short coordinate description.
struct FavoriteMapView: View {
    /// The persisted favorite location used to configure the map and labels.
    let favorite: FavoriteLocation

    /// The visible region of the map, centered on the favorite's coordinate.
    @State private var region: MKCoordinateRegion
    /// A single-item collection providing a marker for the favorite on the map.
    @State private var annotations: [IdentifiedAnnotation]
    /// A short, formatted description of the favorite's coordinates.
    /// - Returns: A string containing latitude and longitude to five decimal places.
    private var placeDescription: String {
        return String(format: "Lat: %.5f, Lon: %.5f", favorite.lat, favorite.log)
    }

    /// Creates a new map view centered on the provided favorite location.
    /// - Parameter favorite: The favorite to display on the map.
    init(favorite: FavoriteLocation) {
        self.favorite = favorite
        let coordinate = CLLocationCoordinate2D(latitude: favorite.lat, longitude: favorite.log)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        _region = State(initialValue: region)
        _annotations = State(initialValue: [
            IdentifiedAnnotation(title: favorite.name ?? "", coordinate: coordinate)
        ])
    }

    var body: some View {
        // Show the map centered on the region with a single marker for the favorite.
        Map(coordinateRegion: $region, annotationItems: annotations) { item in
            MapMarker(coordinate: item.coordinate, tint: .blue)
        }
        .navigationTitle(favorite.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            // Bottom sheet showing the favorite's name and coordinate summary.
            VStack(alignment: .leading, spacing: 6) {
                Text(favorite.name ?? "")
                    .font(.headline)
                Text(placeDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding([.horizontal, .bottom])
        }
    }
}
