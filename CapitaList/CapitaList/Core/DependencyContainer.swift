//
//  DependencyContainer.swift
//  CapitaList
//
//  Created by Omar Hegazy on 20/03/2025.
//

import Foundation

/// Container for all app dependencies to enable dependency injection
struct DependencyContainer {
    let networkService = CountriesNetworkService()
    let storageService = CountriesStorageService()
    let parser = Parser()
    let locationService = CoreLocationService()
    let geocodingService = GeocodingService()
    let countryRepository: CountryRepositoryProtocol
    let mainViewModel: MainViewModel

    init() {
        countryRepository = CountryRepository(
            networkService: networkService,
            storageService: storageService,
            geocodingService: geocodingService
        )
        
        mainViewModel = MainViewModel(
            countryRepository: countryRepository,
            locationService: locationService
        )
    }
}
