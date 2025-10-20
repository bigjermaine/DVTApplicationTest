//
//  Rain.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//



struct Rain: Codable {
    let oneHour: Double?
    let threeHour: Double?
    
    enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
        case threeHour = "3h"
    }
}
