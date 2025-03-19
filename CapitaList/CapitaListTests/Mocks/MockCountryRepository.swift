//
//  MockCountryRepository.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

@testable import CapitaList

final class MockCountryRepository: CountryRepositoryProtocol {
    var countries: [Country] = []
    var savedCountries: [Country] = []
    var defaultCountry: Country?
    var locationCountryMap: [Location: Country] = [:]
    
    func addCountry(_ country: Country) {
        countries.append(country)
    }
    
    func setDefaultCountry(_ country: Country) {
        defaultCountry = country
    }
    
    func setCountryForLocation(_ location: Location, country: Country) {
        locationCountryMap[location] = country
    }
    
    func getAllCountries() async -> Result<[Country], CountryError> {
        return .success(countries)
    }
    
    func getCountryByCode(code: String) async -> Result<Country, CountryError> {
        if let country = countries.first(where: { $0.code == code }) {
            return .success(country)
        }
        return .failure(.notFound)
    }
    
    func getCountryByName(name: String) async -> Result<Country, CountryError> {
        if let country = countries.first(where: { $0.name == name }) {
            return .success(country)
        }
        return .failure(.notFound)
    }
    
    func getCountryByLocation(latitude: Double, longitude: Double) async -> Result<Country, CountryError> {
        let location = Location(latitude: latitude, longitude: longitude)
        if let country = locationCountryMap[location] ?? defaultCountry {
            return .success(country)
        }
        return .failure(.notFound)
    }
    
    func getSavedCountries() async -> Result<[Country], CountryError> {
        return .success(savedCountries)
    }
    
    func saveCountry(country: Country) async -> Result<Bool, CountryError> {
        if !savedCountries.contains(where: { $0.code == country.code }) {
            savedCountries.append(country)
            return .success(true)
        }
        return .success(false)
    }
    
    func removeCountry(countryCode: String) async -> Result<Bool, CountryError> {
        let initialCount = savedCountries.count
        savedCountries.removeAll(where: { $0.code == countryCode })
        return .success(savedCountries.count < initialCount)
    }
}
