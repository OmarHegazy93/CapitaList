//
//  MockGeocodingService.swift
//  CapitaList
//
//  Created by Omar Hegazy on 20/03/2025.
//

import Foundation
@testable import CapitaList

final class MockGeocodingService: GeocodingServiceProtocol {
    var mockResult: Result<String, CountryError> = .success("EGY")
    
    func getCountryCode(from location: Location) async -> Result<String, CountryError> {
        mockResult
    }
}
