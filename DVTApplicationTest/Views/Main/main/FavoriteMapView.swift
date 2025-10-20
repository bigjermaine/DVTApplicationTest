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

    @State private var cameraPosition: MapCameraPosition

    private var placeDescription: String {
        return String(format: "Lat: %.5f, Lon: %.5f", favorite.lat, favorite.log)
    }

    init(favorite: FavoriteLocation) {
        self.favorite = favorite
        let coordinate = CLLocationCoordinate2D(latitude: favorite.lat, longitude: favorite.log)
        let mapCamera = MapCamera(centerCoordinate: coordinate, distance: 500, heading:100, pitch: 100)
        _cameraPosition = State(initialValue: .camera(mapCamera))
    }

    var body: some View {
        Map(position: $cameraPosition) {
            Annotation(favorite.name ?? "", coordinate: CLLocationCoordinate2D(latitude: favorite.lat, longitude: favorite.log), anchor: .center) {
                ZStack {
                    Circle().fill(.blue).frame(width: 14, height: 14)
                    Circle().stroke(.white, lineWidth: 2).frame(width: 14, height: 14)
                }
                .shadow(radius: 2)
            }
        }
        .mapStyle(.standard)
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

