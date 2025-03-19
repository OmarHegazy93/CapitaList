//
//  MainViewModel.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//


import Foundation
import Combine

enum ViewState<T>: Equatable where T: Equatable {
    case idle
    case loading
    case loaded(T)
    case error(String)
}

@Observable
final class MainViewModel {
    private let countryRepository: CountryRepositoryProtocol
    private let locationService: LocationServiceProtocol
    
    @MainActor
    var savedCountriesState: ViewState<[Country]> = .idle
    @MainActor
    var searchResultState: ViewState<Country> = .idle
    
    init(
        countryRepository: CountryRepositoryProtocol,
        locationService: LocationServiceProtocol
    ) {
        self.countryRepository = countryRepository
        self.locationService = locationService
    }
    
    func loadInitialData() async {
        await loadSavedCountries()
        
        if case .loaded(let countries) = await savedCountriesState,
           countries.isEmpty {
            await loadInitialCountry()
        }
    }
    
    private func loadInitialCountry() async {
        if locationService.hasLocationPermission() {
            let locationResult = await locationService.getCurrentLocation()
            
            switch locationResult {
            case .success(let location):
                await loadCountryByLocation(latitude: location.latitude, longitude: location.longitude)
            case .failure:
                await loadDefaultCountry()
            }
        } else {
            await loadDefaultCountry()
        }
    }
    
    private func loadCountryByLocation(latitude: Double, longitude: Double) async {
        let result = await countryRepository.getCountryByLocation(latitude: latitude, longitude: longitude)
        
        switch result {
        case .success(let country):
            _ = await saveCountry(country)
        case .failure:
            await loadDefaultCountry()
        }
    }
    
    private func loadDefaultCountry() async {
        // Using France as the default country
        let result = await countryRepository.getCountryByCode(code: "FR")
        
        switch result {
        case .success(let country):
            _ = await saveCountry(country)
        case .failure:
            await MainActor.run { savedCountriesState = .error("Failed to load default country") }
        }
    }
    
    func loadSavedCountries() async {
        await MainActor.run { savedCountriesState = .loading }
        
        let result = await countryRepository.getSavedCountries()
        
        await MainActor.run {
            switch result {
            case .success(let countries):
                savedCountriesState = .loaded(countries)
            case .failure(let error):
                savedCountriesState = .error("Failed to load saved countries: \(error.localizedDescription)")
            }
        }
    }
    
    func searchCountry(name: String) async {
        await MainActor.run { searchResultState = .loading }
        
        let result = await countryRepository.getCountryByName(name: name)
        
        await MainActor.run {
            switch result {
            case .success(let country):
                searchResultState = .loaded(country)
            case .failure(let error):
                searchResultState = .error("Country not found: \(error.localizedDescription)")
            }
        }
    }
    
    func saveCountry(_ country: Country) async -> Bool {
        if case .loaded(let countries) = await savedCountriesState, countries.count >= 5 {
            return false
        }
        
        if case .loaded(let countries) = await savedCountriesState, countries.contains(where: { $0.code == country.code }) {
            return false
        }
        
        let result = await countryRepository.saveCountry(country: country)
        
        switch result {
        case .success(let success):
            if success {
                await loadSavedCountries()
                return true
            }
            return false
        case .failure:
            await MainActor.run { savedCountriesState = .error("Failed to save country") }
            return false
        }
    }
    
    func removeCountry(code: String) async {
        let result = await countryRepository.removeCountry(countryCode: code)
        
        switch result {
        case .success:
            await loadSavedCountries()
        case .failure:
            await MainActor.run { savedCountriesState = .error("Failed to remove country") }
        }
    }
}
