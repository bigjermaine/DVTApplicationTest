//
//  Weather.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//
import Foundation

// MARK: - Weather
struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

