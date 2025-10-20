//
//  TripletItem.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//

import Foundation
import SwiftUI

 struct TripletItem: View {
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundStyle(.white)
            Text(label.capitalized)
                .foregroundStyle(.white)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
       
    }
}

