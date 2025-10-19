//
//  Double.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//

import Foundation

extension Double {
    var asTemp: String {
        "\(Int(self.rounded()))°"
    }
}
