//
//  GeocodingService.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

import Foundation
import CoreLocation

/// Protocol for geocoding services
protocol GeocodingServiceProtocol {
    /// Gets a country code from geographic coordinates
    /// - Parameter location: The location to get the country code for
    /// - Returns: A Result containing either the country code or an error
    func getCountryCode(from location: Location) async -> Result<String, CountryError>
}

/// Implementation of GeocodingServiceProtocol using CLGeocoder
final class GeocodingService: GeocodingServiceProtocol {
    
    // MARK: - Properties
    
    private let geocoder = CLGeocoder()
    
    // MARK: - GeocodingServiceProtocol Methods
    
    /// Gets a country code from geographic coordinates
    /// - Parameter location: The location to get the country code for
    /// - Returns: A Result containing either the country code or an error
    func getCountryCode(from location: Location) async -> Result<String, CountryError> {
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        do {
            // Reverse geocode the location to get placemark information
            let placemarks = try await geocoder.reverseGeocodeLocation(clLocation)
            
            // Extract the country code from the first placemark
            if let countryCode = placemarks.first?.isoCountryCode {
                return .success(countryCode)
            } else {
                return .failure(.notFound)
            }
        } catch {
            return .failure(.locationDenied)
        }
    }
} 