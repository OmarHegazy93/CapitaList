//
//  ViewModelFactory.swift
//  CapitaList
//
//  Created by Omar Hegazy on 20/03/2025.
//

import Foundation

struct ViewModelFactory {
    private let networkService = CountriesNetworkService()
    private let storageService = CountriesStorageService()
    private let locationService = CoreLocationService()
    private let geocodingService = GeocodingService()
    private let countryRepository: CountryRepository
    
    init() {
        countryRepository = CountryRepository(
            networkService: networkService,
            storageService: storageService,
            geocodingService: geocodingService
        )
    }

    func makeMainViewModel(coordinator: AppCoordinator) -> MainViewModel {

        let viewModel = MainViewModel(
            countryRepository: countryRepository,
            locationService: locationService,
            coordinator: coordinator
        )

        return viewModel
    }

    func makeCountrySearchViewModel(coordinator: AppCoordinator) -> SearchViewModel {
        SearchViewModel(countryRepository: countryRepository, coordinator: coordinator)
    }
}
