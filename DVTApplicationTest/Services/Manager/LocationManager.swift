//
//  LocationManager.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//

import Foundation
import CoreLocation
import Combine
import UIKit

@MainActor

final class LocationManager: NSObject, ObservableObject {
    // MARK: - Published State
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastKnownLocation: CLLocation? = nil
    @Published var errorMessage: String? = nil
    @Published var isRequestInFlight: Bool = false
    @Published var allowsBackgroundUpdates: Bool = true

    // MARK: - Callbacks
    var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)?
    var onLocationUpdate: ((CLLocation) -> Void)?
    var onError: ((String) -> Void)?

    private let manager: CLLocationManager  = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        authorizationStatus = manager.authorizationStatus
        manager.distanceFilter = kCLDistanceFilterNone
        manager.desiredAccuracy = kCLLocationAccuracyBest
      
    }

    // MARK: - Callback configuration
    func configureCallbacks(
        onAuthorizationChange: ((CLAuthorizationStatus) -> Void)? = nil,
        onLocationUpdate: ((CLLocation) -> Void)? = nil,
        onError: ((String) -> Void)? = nil
    ) {
        self.onAuthorizationChange = onAuthorizationChange
        self.onLocationUpdate = onLocationUpdate
        self.onError = onError
    }

    func requestWhenInUseAuthorization() {
        errorMessage = nil
        manager.requestWhenInUseAuthorization()
        
    }

    func requestAlwaysAuthorization() {
        errorMessage = nil
        // Must have When-In-Use first before requesting Always
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorized:
            manager.requestAlwaysAuthorization()
        case .authorizedAlways:
            // Already granted
            break
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            errorMessage = "Location access denied. Please enable it in Settings."
            if let errorMessage { onError?(errorMessage) }
        @unknown default:
            errorMessage = "Unknown authorization status."
            if let errorMessage { onError?(errorMessage) }
        }
    }

    func requestCurrentLocation(background: Bool = false) {
        errorMessage = nil
        isRequestInFlight = true
        allowsBackgroundUpdates = background

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            errorMessage = "Location access denied. Please enable it in Settings."
            isRequestInFlight = false
            if let errorMessage { onError?(errorMessage) }
        case .authorizedAlways:
            manager.allowsBackgroundLocationUpdates = background
            manager.requestLocation()
        case .authorizedWhenInUse, .authorized:
            if background {
                // Attempt to escalate to Always
                manager.requestAlwaysAuthorization()
            } else {
                manager.requestLocation()
            }
        @unknown default:
            errorMessage = "Unknown authorization status."
            isRequestInFlight = false
            if let errorMessage { onError?(errorMessage) }
        }
    }

   

    // MARK: - Standard (continuous) location updates
    func startUpdatingLocation(background: Bool = false) {
        errorMessage = nil
        allowsBackgroundUpdates = background
        switch manager.authorizationStatus {
        case .authorizedAlways:
            manager.allowsBackgroundLocationUpdates = background
            manager.startUpdatingLocation()
        case .authorizedWhenInUse, .authorized:
            if background {
                manager.requestAlwaysAuthorization()
            } else {
                manager.allowsBackgroundLocationUpdates = false
                manager.startUpdatingLocation()
            }
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            errorMessage = "Location access denied. Please enable it in Settings."
            if let errorMessage { onError?(errorMessage) }
        @unknown default:
            errorMessage = "Unknown authorization status."
            if let errorMessage { onError?(errorMessage) }
        }
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
        manager.allowsBackgroundLocationUpdates = false
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
       onAuthorizationChange?(authorizationStatus)
        switch authorizationStatus {
        case .authorizedAlways:
            manager.allowsBackgroundLocationUpdates = allowsBackgroundUpdates
            if isRequestInFlight { manager.requestLocation() }
            startUpdatingLocation(background: true)
        case .authorizedWhenInUse, .authorized:
            manager.startUpdatingLocation()
            if isRequestInFlight { manager.requestLocation() }
            startUpdatingLocation(background: true)
        case .restricted, .denied:
            if isRequestInFlight {
                errorMessage = "Location access denied. Please enable it in Settings."
                isRequestInFlight = false
                if let errorMessage { onError?(errorMessage) }
            }
        case .notDetermined:
            break
        @unknown default:
            if isRequestInFlight {
                errorMessage = "Unknown authorization status."
                isRequestInFlight = false
                if let errorMessage { onError?(errorMessage) }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            lastKnownLocation = location
            onLocationUpdate?(location)
        }
        isRequestInFlight = false
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let message = (error as NSError).localizedDescription
        errorMessage = message
        onError?(message)
        isRequestInFlight = false
    }
}

