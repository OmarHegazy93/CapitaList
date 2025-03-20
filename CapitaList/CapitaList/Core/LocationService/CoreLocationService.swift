//
//  CoreLocationService.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

import Foundation
import CoreLocation

/// Implementation of the LocationServiceProtocol using CoreLocation framework
final class CoreLocationService: NSObject, LocationServiceProtocol {
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<Result<Location, CountryError>, Never>?
    private var authorizationContinuation: CheckedContinuation<Bool, Never>?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer // No need for high accuracy
    }
    
    // MARK: - LocationServiceProtocol Methods
    
    /// Gets the current location of the device
    /// - Returns: A Result containing either the device location or a location error
    func getCurrentLocation() async -> Result<Location, CountryError> {
        // Check if location services are enabled
        guard CLLocationManager.locationServicesEnabled() else {
            return .failure(.locationDenied)
        }
        
        // Check if we have permission
        let authStatus = locationManager.authorizationStatus
        
        if authStatus == .denied || authStatus == .restricted {
            return .failure(.locationDenied)
        }
        
        // If we're not yet authorized, request permission first
        if authStatus == .notDetermined {
            let hasPermission = await requestLocationPermission()
            if !hasPermission {
                return .failure(.locationDenied)
            }
        }
        
        // If we have a recent location, use that
        if let location = locationManager.location {
            return .success(Location(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            ))
        }
        
        // Start updating location and wait for the result
        return await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.startUpdatingLocation()
        }
    }
    
    /// Checks if the app has location permission
    /// - Returns: True if the app has permission to access location
    func hasLocationPermission() -> Bool {
        let status = locationManager.authorizationStatus
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }
    
    /// Requests permission to access the device location
    /// - Returns: A boolean indicating whether permission was granted
    func requestLocationPermission() async -> Bool {
        let status = locationManager.authorizationStatus
        
        // If we already have permission, return true
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            return true
        }
        
        // If permission was already denied, return false
        if status == .denied || status == .restricted {
            return false
        }
        
        // Request permission and wait for the result
        return await withCheckedContinuation { continuation in
            self.authorizationContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension CoreLocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Stop updating location to conserve battery
        locationManager.stopUpdatingLocation()
        
        if let location = locations.first {
            let userLocation = Location(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            locationContinuation?.resume(returning: .success(userLocation))
            locationContinuation = nil
        } else {
            locationContinuation?.resume(returning: .failure(.locationDenied))
            locationContinuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        locationContinuation?.resume(returning: .failure(.locationDenied))
        locationContinuation = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            authorizationContinuation?.resume(returning: true)
        case .denied, .restricted:
            authorizationContinuation?.resume(returning: false)
        case .notDetermined:
            // Still waiting for user input - do nothing
            break
        @unknown default:
            authorizationContinuation?.resume(returning: false)
        }
        
        // Reset continuation only if it was resolved
        if status != .notDetermined {
            authorizationContinuation = nil
        }
    }
} 
