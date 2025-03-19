//
//  LocationService.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//


protocol LocationServiceProtocol {
    func getCurrentLocation() async -> Result<Location, CountryError>
    func hasLocationPermission() -> Bool
    func requestLocationPermission() async
}
