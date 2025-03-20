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
    
    // Content state
    @MainActor
    var searchState: ViewState<Country> = .idle
    @MainActor
    var isSearching = false
    
    // Callback for when a country is selected
    var onCountrySelected: ((Country) -> Void)?
    
    init(countryRepository: CountryListsProviderProtocol) {
        self.countryRepository = countryRepository
    }
    
    @MainActor
    func searchCountry(name: String) async {
        guard !name.isEmpty else { return }
        
        searchState = .loading
        isSearching = true
        
        // Get all countries and filter
        let result = await countryRepository.getAllCountries()
        
        switch result {
        case .success(let countries):
            // Filter countries by name match
            let filteredCountries = countries.filter { 
                $0.name.lowercased().contains(name.lowercased()) 
            }
            
            if let country = filteredCountries.first {
                searchState = .loaded(country)
            } else {
                searchState = .error("No country found matching '\(name)'")
            }
        case .failure(let error):
            searchState = .error("Failed to search countries: \(error.localizedDescription)")
        }
        
        isSearching = false
    }
    
    func selectCountry(_ country: Country) {
        onCountrySelected?(country)
    }
}