//
//  SearchViewModel.swift
//  CapitaList
//
//  Created by Omar Hegazy on 20/03/2025.
//

import Foundation
import Combine

@Observable
final class SearchViewModel {
    private let countryRepository: CountryListsProviderProtocol
    private let coordinator: SearchCountryCoordinator
    
    // States
    @MainActor
    var searchState: ViewState<Country> = .idle
    private var countriesState: ViewState<[Country]> = .idle
    @MainActor
    var isSearching = false
    @MainActor
    var searchText = ""
    @MainActor
    var displayableCountries: [Country] = []
    
    // Selected countries limit
    private let maxSelectedCountries = 5
    
    // Callback for when a country is selected
    var onCountrySelected: ((Country) -> Void)?
    var currentlySelectedCountries: [Country] = []
    
    init(countryRepository: CountryListsProviderProtocol, coordinator: SearchCountryCoordinator) {
        self.countryRepository = countryRepository
        self.coordinator = coordinator
    }
    
    @MainActor
    func loadAllCountries() async {
        countriesState = .loading
        
        let result = await countryRepository.getAllCountries()
        
        switch result {
        case .success(let countries):
            countriesState = .loaded(countries)
            // Initialize filtered countries with all countries
            displayableCountries = countries
        case .failure(let error):
            countriesState = .error("Failed to load countries: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func searchCountry(name: String) async {
        guard !name.isEmpty else {
            // If search is empty, show all countries
            if case .loaded(let allCountries) = countriesState {
                displayableCountries = allCountries
            }
            searchState = .idle
            return
        }
        
        searchState = .loading
        isSearching = true
        
        // Filter the already loaded countries
        if case .loaded(let allCountries) = countriesState {
            let filtered = allCountries.filter {
                $0.name.lowercased().contains(name.lowercased())
            }
            
            displayableCountries = filtered
            
            if let firstMatch = filtered.first {
                searchState = .loaded(firstMatch)
            } else {
                searchState = .error("No country found matching '\(name)'")
            }
        } else {
            // If countries aren't loaded yet, load them first
            await loadAllCountries()
            await searchCountry(name: name)
        }
        
        isSearching = false
    }
    
    @MainActor
    func isSelectionValid(for country: Country) -> Bool {
        // Check if we've already selected 5 countries and this isn't one of them
        if currentlySelectedCountries.count >= maxSelectedCountries &&
           !currentlySelectedCountries.contains(where: { $0.code == country.code }) {
            return false
        }
        
        // Check if this country is already selected
        if currentlySelectedCountries.contains(where: { $0.code == country.code }) {
            return false
        }
        
        return true
    }
    
    @MainActor
    func loadCurrentlySelectedCountries() async {
        let result = await countryRepository.getSavedCountries()
        
        switch result {
        case .success(let countries):
            currentlySelectedCountries = countries
        case .failure:
            currentlySelectedCountries = []
        }
    }
    
    func dismiss() {
        coordinator.dismissSheet()
    }
}
