//
//  CountriesStorageService.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

import Foundation

actor CountriesStorageService {
    private let allCountriesKey = "allCountries"
    private let savedCountriesKey = "savedCountries"
    
    private let storageProvider: StorageProviderProtocol
    private let parser = Parser()
    
    init(storageProvider: StorageProviderProtocol = UserDefaults.standard) {
        self.storageProvider = storageProvider
    }
        
    func saveAllCountries(_ countries: [Country]) async {
        let result: Result<Data, ParsingError> = parser.encode(countries)
        
        switch result {
        case .success(let data):
            storageProvider.set(data, forKey: allCountriesKey)
        case .failure(let error):
            print("Error saving all countries: \(error)")
        }
    }
    
    func getAllCountries() async -> Result<[Country], CountryError> {
        guard let data = storageProvider.data(forKey: allCountriesKey) else {
            return .failure(.notFound)
        }
        
        let result: Result<[Country], ParsingError> = parser.decode(data)
        
        switch result {
        case .success(let countries):
            return .success(countries)
        case .failure:
            return .failure(.invalidData)
        }
    }
    
    // MARK: - User Selected Countries Storage
    
    func getSavedCountries() async -> Result<[Country], CountryError> {
        guard let data = storageProvider.data(forKey: savedCountriesKey) else {
            return .success([]) // Return empty array if nothing saved yet
        }
        
        let result: Result<[Country], ParsingError> = parser.decode(data)
        
        switch result {
        case .success(let countries):
            return .success(countries)
        case .failure:
            return .failure(.invalidData)
        }
    }
    
    func saveCountry(_ country: Country) async -> Result<Bool, CountryError> {
        let result = await getSavedCountries()
        
        switch result {
        case .success(var countries):
            // Check if country already exists
            guard !countries.contains(where: { $0.code == country.code }) else { return .success(false) }
            // Check if we have reached the max limit
            if countries.count >= 5 {
                return .failure(.maxCountriesReached)
            }
            
            // Add the country and save
            countries.append(country)
            let encodeResult: Result<Data, ParsingError> = parser.encode(countries)
            
            switch encodeResult {
            case .success(let data):
                storageProvider.set(data, forKey: savedCountriesKey)
                return .success(true)
            case .failure:
                return .failure(.invalidData)
            }
            
        case .failure:
            // If there was an error getting saved countries, try to save just this one
            let encodeResult: Result<Data, ParsingError> = parser.encode([country])
            
            switch encodeResult {
            case .success(let data):
                storageProvider.set(data, forKey: savedCountriesKey)
                return .success(true)
            case .failure:
                return .failure(.invalidData)
            }
        }
    }
    
    func removeCountry(countryCode: String) async -> Result<Bool, CountryError> {
        let result = await getSavedCountries()
        
        switch result {
        case .success(var countries):
            let initialCount = countries.count
            countries.removeAll(where: { $0.code == countryCode })
            
            guard countries.count < initialCount else {
                return .success(false) // No country was removed
            }
            
            let encodeResult: Result<Data, ParsingError> = parser.encode(countries)
            
            switch encodeResult {
            case .success(let data):
                storageProvider.set(data, forKey: savedCountriesKey)
                return .success(true)
            case .failure:
                return .failure(.invalidData)
            }
            
        case .failure(let error):
            return .failure(error)
        }
    }
}
