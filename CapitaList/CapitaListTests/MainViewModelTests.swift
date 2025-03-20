//
//  MainViewModelTests.swift
//  CapitaList
//
//  Created by Omar Hegazy on 20/03/2025.
//

import Testing
@testable import CapitaList
import Foundation

struct MainViewModelTestsWithMockedProviders {
    let viewModel: MainViewModel
    let networkProvider = MockNetworkProvider()
    let storageProvider = MockStorageProvider()
    let geocodingService = MockGeocodingService()
    let locationService = MockLocationService()
    
    init() {
        let countryRepository = CountryRepository(
            networkService: .init(networkProvider: networkProvider),
            storageService: .init(storageProvider: storageProvider),
            geocodingService: geocodingService
        )
        
        viewModel = MainViewModel(
            countryRepository: countryRepository,
            locationService: locationService
        )
    }
    
    @Test("init should load saved countries when repository has saved countries")
    func initShouldLoadUserCountryBasedOnLocationWhenPermissionGranted() async throws {
        // Given
        locationService.setHasPermission(to: true)
        let userLocation = Location(latitude: 40.7128, longitude: -74.0060)
        locationService.setCurrentLocation(to: userLocation)
        
        let usaCountry = Country(
            name: "United States",
            code: "US",
            capital: "Washington D.C.",
            latlngArray: [38.0, -97.0],
            currenciesArray: [Currency(code: "USD", name: "US Dollar", symbol: "$")]
        )
        
        // Set up the mocked services
        networkProvider.mockData = try Parser().encode([usaCountry]).get()
        geocodingService.mockResult = .success("US")
        
        // When
        await viewModel.loadInitialData()
        
        // Then
        let result = await viewModel.savedCountriesState
        #expect(result == .loaded([usaCountry]))
    }
    
    @Test("init should load default country when location permission denied")
    func initShouldLoadDefaultCountryWhenLocationPermissionDenied() async throws {
        // Given
        locationService.setHasPermission(to: false)
            
        let countryCode = Locale.current.identifier.components(separatedBy: "_").last ?? "US"
        let countryName = Locale.current.localizedString(forRegionCode: countryCode)
        
        let defaultCountry = Country(
            name: countryName ?? "Unknown",
            code: countryCode,
            capital: "Paris",
            latlngArray: [46.0, 2.0],
            currenciesArray: [Currency(code: "EUR", name: "Euro", symbol: "€")]
        )
        
        let data = try Parser().encode([defaultCountry]).get()
        storageProvider.set(data, forKey: "savedCountries")
        
        // When
        await viewModel.loadInitialData()
        
        // Then
        let result = await viewModel.savedCountriesState
        #expect(result == .loaded([defaultCountry]))
    }
    
    @Test("searchCountry should return country when valid name provided")
    func searchCountryShouldReturnCountryWhenValidNameProvided() async throws {
        // Given
        let germanyCountry = Country(
            name: "Germany",
            code: "DE",
            capital: "Berlin",
            latlngArray: [51.0, 9.0],
            currenciesArray: [Currency(code: "EUR", name: "Euro", symbol: "€")]
        )
        
        let data = try Parser().encode([germanyCountry]).get()
        storageProvider.set(data, forKey: "allCountries")
        
        // When
        await viewModel.searchCountry(name: "Germany")
        
        // Then
        let result = await viewModel.searchResultState
        #expect(result == .loaded(germanyCountry))
    }
    
    @Test()
    func saveCountryShouldAddCountryToSavedListWhenLessThan5Countries() async throws {
        // Given
        let germanyCountry = Country(
            name: "Germany",
            code: "DE",
            capital: "Berlin",
            latlngArray: [51.0, 9.0],
            currenciesArray: [Currency(code: "EUR", name: "Euro", symbol: "€")]
        )
        
        networkProvider.mockData = try Parser().encode([germanyCountry]).get()
        
        // When
        let didSaveSucceed = await viewModel.saveCountry(germanyCountry)
        
        // Then
        #expect(didSaveSucceed)
        
        let result = await viewModel.savedCountriesState
        #expect(result == .loaded([germanyCountry]))
    }
    
    @Test("save Country Should Not Add Country When Already 5 Countries Saved")
    func saveCountryShouldNotAddCountryWhenAlready5CountriesSaved() async throws {
        // Given - Add 5 countries to the saved list
        let countries = (1...5).map { i in
            Country(
                name: "Country\(i)",
                code: "C\(i)",
                capital: "Capital\(i)",
                latlngArray: [40.7128, -74.0060],
                currenciesArray: [Currency(code: "CUR\(i)", name: "Currency\(i)", symbol: "$")]
            )
        }
        
        for country in countries {
            try #require(await viewModel.saveCountry(country))
        }
        
        let newCountry = Country(
            name: "NewCountry",
            code: "NC",
            capital: "NewCapital",
            latlngArray: [40.7128, -74.0060],
            currenciesArray: [Currency(code: "NCR", name: "NewCurrency", symbol: "$")]
        )
                
        // When
        let didSaveSucceed = await viewModel.saveCountry(newCountry)
        
        // Then
        #expect(didSaveSucceed == false)
        
        let result = await viewModel.savedCountriesState
        #expect(result == .loaded(countries))
        if case .loaded(let countries) = result {
            #expect(countries.count == 5)
        } else {
            Issue.record("Unexpected result: \(result)")
        }
    }

    @Test("removeCountry Should Remove Country From Saved List")
    func removeCountryShouldRemoveCountryFromSavedList() async throws {
        // Given
        let germanyCountry = Country(
            name: "Germany",
            code: "DE",
            capital: "Berlin",
            latlngArray: [51.0, 9.0],
            currenciesArray: [Currency(code: "EUR", name: "Euro", symbol: "€")]
        )
        
        let data = try Parser().encode([germanyCountry]).get()
        storageProvider.set(data, forKey: "savedCountries")
        
        // Load the saved countries in viewModel
        await viewModel.loadSavedCountries()
        
        // When
        await viewModel.removeCountry(code: "DE")
        
        // Then
        let result = await viewModel.savedCountriesState
        #expect(result == .loaded([]))
    }
}
