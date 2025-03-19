//
//  MockLocationService.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

@testable import CapitaList

final class MockLocationService: LocationServiceProtocol {
    private var hasPermission = false
    private var currentLocation: Location?
    
    func setHasPermission(to hasPermission: Bool) {
        self.hasPermission = hasPermission
    }
    
    func setCurrentLocation(to location: Location) {
        self.currentLocation = location
    }
    
    func getCurrentLocation() async -> Result<Location, CountryError> {
        if let location = currentLocation,
           hasPermission {
            return .success(location)
        }
        return .failure(.locationDenied)
    }
    
    func hasLocationPermission() -> Bool { hasPermission }
    
    func requestLocationPermission() async -> Bool { hasPermission }
}
