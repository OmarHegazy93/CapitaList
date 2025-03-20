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
}

protocol CountryListsProviderProtocol {
    func getAllCountries() async -> Result<[Country], CountryError>
    func getSavedCountries() async -> Result<[Country], CountryError>
}

protocol CountryRepositoryProtocol: CountryListsProviderProtocol {
    func getCountryByCode(code: String) async -> Result<Country, CountryError>
    func getCountryByName(name: String) async -> Result<Country, CountryError>
    func getCountryByLocation(latitude: Double, longitude: Double) async -> Result<Country, CountryError>
    func saveCountry(country: Country) async -> Result<Bool, CountryError>
    func removeCountry(countryCode: String) async -> Result<Bool, CountryError>
}

/// Implementation of CountryRepositoryProtocol that coordinates between network, storage, and location services
final class CountryRepository: CountryRepositoryProtocol {
    
    // MARK: - Properties
    
    private let networkService: CountriesNetworkService
    private let storageService: CountriesStorageService
    private let geocodingService: GeocodingServiceProtocol
    
    // MARK: - Initialization
    
    init(
        networkService: CountriesNetworkService = CountriesNetworkService(),
        storageService: CountriesStorageService = CountriesStorageService(),
        geocodingService: GeocodingServiceProtocol = GeocodingService()
    ) {
        self.networkService = networkService
        self.storageService = storageService
        self.geocodingService = geocodingService
    }
    
    // MARK: - CountryRepositoryProtocol Implementation
    
    func getAllCountries() async -> Result<[Country], CountryError> {
        // First try to get from storage
        let storageResult = await storageService.getAllCountries()
        
        switch storageResult {
        case .success(let countries) where !countries.isEmpty:
            return .success(countries)
        default:
            // If storage is empty or fails, fetch from network
            return await fetchAllCountries()
        }
    }
    
    func getCountryByCode(code: String) async -> Result<Country, CountryError> {
        let result = await getAllCountries()
        
        switch result {
        case .success(let countries):
            if let country = countries.first(where: { $0.code == code }) {
                return .success(country)
            }
            return .failure(.notFound)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getCountryByName(name: String) async -> Result<Country, CountryError> {
        let result = await getAllCountries()
        
        switch result {
        case .success(let countries):
            // Case-insensitive search
            if let country = countries.first(where: {
                $0.name.lowercased().contains(name.lowercased())
            }) {
                return .success(country)
            }
            return .failure(.notFound)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getCountryByLocation(latitude: Double, longitude: Double) async -> Result<Country, CountryError> {
        // Convert coordinates to a location
        let location = Location(latitude: latitude, longitude: longitude)
        
        // Get the country code from the geocoding service
        let geocodeResult = await geocodingService.getCountryCode(from: location)
        
        switch geocodeResult {
        case .success(let countryCode):
            // Use the country code to fetch the country
            return await getCountryByCode(code: countryCode)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getSavedCountries() async -> Result<[Country], CountryError> {
        await storageService.getSavedCountries()
    }
    
    func saveCountry(country: Country) async -> Result<Bool, CountryError> {
        let savedResult = await getSavedCountries()
        
        switch savedResult {
        case .success(let savedCountries):
            if savedCountries.count >= 5 && !savedCountries.contains(where: { $0.code == country.code }) {
                return .failure(.maxCountriesReached)
            }
            return await storageService.saveCountry(country)
        case .failure:
            // If there's an error getting saved countries, try to save anyway
            return await storageService.saveCountry(country)
        }
    }
    
    func removeCountry(countryCode: String) async -> Result<Bool, CountryError> {
        await storageService.removeCountry(countryCode: countryCode)
    }
    
    // MARK: - Private Methods
    
    private func fetchAllCountries() async -> Result<[Country], CountryError> {
        let networkResult = await networkService.fetchAllCountries()
        
        switch networkResult {
        case .success(let countries):
            // Cache the countries for offline use
            await storageService.saveAllCountries(countries)
            return .success(countries)
        case .failure(let error):
            return .failure(error)
        }
    }
}
