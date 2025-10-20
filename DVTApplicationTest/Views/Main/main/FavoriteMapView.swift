//
//  FavoriteMapView.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 20/10/2025.
//

import SwiftUI
import UIKit
import MapKit


 struct FavoriteMapView: View {
        let favorite: FavoriteLocation
        @State private var region: MKCoordinateRegion
        
        init(favorite: FavoriteLocation) {
            self.favorite = favorite
            let coordinate = CLLocationCoordinate2D(latitude: favorite.lat, longitude: favorite.log)
            _region = State(initialValue: MKCoordinateRegion(center: coordinate,
                                                             span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
        }
        
        var body: some View {
            Map(position: .constant(.region(region))) {
                Annotation(favorite.name ?? "", coordinate: CLLocationCoordinate2D(latitude: favorite.lat, longitude: favorite.log)) {
                    ZStack {
                        Circle().fill(.blue).frame(width: 12, height: 12)
                        Circle().stroke(.white, lineWidth: 2).frame(width: 12, height: 12)
                    }
                }
            }
            .navigationTitle(favorite.name ?? "")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

