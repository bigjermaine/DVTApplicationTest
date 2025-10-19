//
//  APIError.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//


import Foundation

enum APIError: Error, LocalizedError {
    case unknown
    case failedRequest
    case invalidResponse
    case unauthorized
    case unreachable
    case expiredSession
    case dynamic(message: String = "")
 
    var errorDescription: String? {
        switch self {
        case .unreachable:
            return "You need a network connection."
        case .unknown, .failedRequest, .invalidResponse:
            return "Oops! An error occured."
        case .unauthorized:
            return "You are unauthorized to access this data."
        case .expiredSession:
            return "Your session is expired. Please login again."
        case .dynamic(let msg):
            return msg
        }
    }
}
