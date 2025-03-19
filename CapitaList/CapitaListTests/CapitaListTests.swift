//
//  CapitaListTests.swift
//  CapitaListTests
//
//  Created by Omar Hegazy on 19/03/2025.
//

import Testing
@testable import CapitaList

// TODO: To discuss the difference between this test suite and MainViewModelTestsWithMockedProviders
struct MainViewModelTestsWithMockedRepository {
    let viewModel: MainViewModel
    let countryRepository = MockCountryRepository()
    let locationService = MockLocationService()
    
    init() {
        viewModel = MainViewModel(
            countryRepository: countryRepository,
            locationService: locationService
        )
    }
    
    @Test("init should load saved countries when repository has saved countries")
    func initShouldLoadUserCountryBasedOnLocationWhenPermissionGranted() async {
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
        
        countryRepository.addCountry(usaCountry)
        countryRepository.setLocation(for: usaCountry, as: userLocation)
        
        // When
        await viewModel.loadInitialData()
        
        // Then
        let result = await viewModel.savedCountriesState
        #expect(result == .loaded([usaCountry]))
    }
    
    @Test("init should load default country when location permission denied")
    func initShouldLoadDefaultCountryWhenLocationPermissionDenied() async {
            // Given
        locationService.setHasPermission(to: false)
            
            let defaultCountry = Country(
                name: "France",
                code: "FR",
                capital: "Paris",
                latlngArray: [46.0, 2.0],
                currenciesArray: [Currency(code: "EUR", name: "Euro", symbol: "€")]
            )
            
            countryRepository.addCountry(defaultCountry)
            countryRepository.setDefaultCountry(defaultCountry)
            
            // When
            await viewModel.loadInitialData()
            
            // Then
            let result = await viewModel.savedCountriesState
            #expect(result == .loaded([defaultCountry]))
        }
        
        @Test("searchCountry should return country when valid name provided")
        func searchCountryShouldReturnCountryWhenValidNameProvided() async {
            // Given
            let germanyCountry = Country(
                name: "Germany",
                code: "DE",
                capital: "Berlin",
                latlngArray: [51.0, 9.0],
                currenciesArray: [Currency(code: "EUR", name: "Euro", symbol: "€")]
            )
            
            countryRepository.addCountry(germanyCountry)
            
            // When
            await viewModel.searchCountry(name: "Germany")
            
            // Then
            let result = await viewModel.searchResultState
            #expect(result == .loaded(germanyCountry))
        }
        
        @Test()
        func saveCountryShouldAddCountryToSavedListWhenLessThan5Countries() async {
            // Given
            let germanyCountry = Country(
                name: "Germany",
                code: "DE",
                capital: "Berlin",
                latlngArray: [51.0, 9.0],
                currenciesArray: [Currency(code: "EUR", name: "Euro", symbol: "€")]
            )
            
            countryRepository.addCountry(germanyCountry)
            
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
            countryRepository.addCountry(country)
            try #require(await viewModel.saveCountry(country))
        }
            
            let newCountry = Country(
                name: "NewCountry",
                code: "NC",
                capital: "NewCapital",
                latlngArray: [40.7128, -74.0060],
                currenciesArray: [Currency(code: "NCR", name: "NewCurrency", symbol: "$")]
            )
            
            countryRepository.addCountry(newCountry)
            
            // When
            let didSaveSucceed = await viewModel.saveCountry(newCountry)
            
            // Then
            #expect(didSaveSucceed == false)
            
            let result = await viewModel.savedCountriesState
             #expect(result == .loaded(countries))
        }
        
        @Test("removeCountry Should Remove Country From Saved List")
        func removeCountryShouldRemoveCountryFromSavedList() async {
            // Given
            let germanyCountry = Country(
                name: "Germany",
                code: "DE",
                capital: "Berlin",
                latlngArray: [51.0, 9.0],
                currenciesArray: [Currency(code: "EUR", name: "Euro", symbol: "€")]
            )
            
            countryRepository.addCountry(germanyCountry)
            _ = await viewModel.saveCountry(germanyCountry)
            
            // When
            await viewModel.removeCountry(code: "DE")
            
            // Then
            let result = await viewModel.savedCountriesState
            #expect(result == .loaded([]))
        }
}
