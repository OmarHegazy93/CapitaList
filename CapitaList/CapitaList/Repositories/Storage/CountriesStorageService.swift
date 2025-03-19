//
//  CountriesStorageService.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

import Foundation

extension UserDefaults: StorageProviderProtocol {}

actor CountriesStorageService {
    private let allCountriesKey = "allCountries"
    private let savedCountriesKey = "savedCountries"
    
    private let storageProvider: StorageProviderProtocol
    
    init(storageProvider: StorageProviderProtocol = UserDefaults.standard) {
        self.storageProvider = storageProvider
    }
        
    func saveAllCountries(_ countries: [Country]) async {
        do {
            let data = try JSONEncoder().encode(countries)
            storageProvider.set(data, forKey: allCountriesKey)
        } catch {
            print("Error saving all countries: \(error)")
        }
    }
    
    func getAllCountries() async -> Result<[Country], CountryError> {
        guard let data = storageProvider.data(forKey: allCountriesKey) else {
            return .failure(.notFound)
        }
        
        do {
            let countries = try JSONDecoder().decode([Country].self, from: data)
            return .success(countries)
        } catch {
            return .failure(.invalidData)
        }
    }
    
    // MARK: - User Selected Countries Storage
    
    func getSavedCountries() async -> Result<[Country], CountryError> {
        guard let data = storageProvider.data(forKey: savedCountriesKey) else {
            return .success([]) // Return empty array if nothing saved yet
        }
        
        do {
            let countries = try JSONDecoder().decode([Country].self, from: data)
            return .success(countries)
        } catch {
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
            do {
                let data = try JSONEncoder().encode(countries)
                storageProvider.set(data, forKey: savedCountriesKey)
                return .success(true)
            } catch {
                return .failure(.invalidData)
            }
            
        case .failure:
            // If there was an error getting saved countries, try to save just this one
            do {
                let data = try JSONEncoder().encode([country])
                storageProvider.set(data, forKey: savedCountriesKey)
                return .success(true)
            } catch {
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
            
            do {
                let data = try JSONEncoder().encode(countries)
                storageProvider.set(data, forKey: savedCountriesKey)
                return .success(true)
            } catch {
                return .failure(.invalidData)
            }
            
        case .failure(let error):
            return .failure(error)
        }
    }
}
