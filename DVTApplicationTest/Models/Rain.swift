//
//  Rain.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//


// MARK: - Rain
struct Rain: Codable {
    let oneHour: Double?

    enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
    }
}
