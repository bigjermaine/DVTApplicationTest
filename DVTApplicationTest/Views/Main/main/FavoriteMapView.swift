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

struct FavoriteMapView: View {
    let favorite: FavoriteLocation

    @State private var region: MKCoordinateRegion
    @State private var annotations: [IdentifiedAnnotation]
    private var placeDescription: String {
        return String(format: "Lat: %.5f, Lon: %.5f", favorite.lat, favorite.log)
    }

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
        Map(coordinateRegion: $region, annotationItems: annotations) { item in
            MapMarker(coordinate: item.coordinate, tint: .blue)
        }
        .navigationTitle(favorite.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
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
