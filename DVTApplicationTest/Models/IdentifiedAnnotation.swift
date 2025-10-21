//
//  IdentifiedAnnotation.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 21/10/2025.
//

import UIKit
import CoreLocation



    struct IdentifiedAnnotation: Identifiable {
        let id = UUID()
        let title: String
        let coordinate: CLLocationCoordinate2D
    }
