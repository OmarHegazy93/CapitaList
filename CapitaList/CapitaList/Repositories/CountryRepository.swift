//
//  CountryRepository.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

enum CountryError: Error {
    case networkError(String)
    case notFound
    case invalidData
    case locationDenied
    case maxCountriesReached
    case unknown
}

protocol CountryRepositoryProtocol {
    func getAllCountries() async -> Result<[Country], CountryError>
    func getCountryByCode(code: String) async -> Result<Country, CountryError>
    func getCountryByName(name: String) async -> Result<Country, CountryError>
    func getCountryByLocation(latitude: Double, longitude: Double) async -> Result<Country, CountryError>
    func getSavedCountries() async -> Result<[Country], CountryError>
    func saveCountry(country: Country) async -> Result<Bool, CountryError>
    func removeCountry(countryCode: String) async -> Result<Bool, CountryError>
}