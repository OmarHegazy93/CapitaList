//
//  AppCoordinator.swift
//  CapitaList
//
//  Created by Omar Hegazy on 20/03/2025.
//

import SwiftUI
import Combine

/// Main navigation destinations in the app
enum AppDestination: Hashable, Identifiable {
    case main
    case countrySearch
    case countryDetail(Country)
    
    var id: String {
        switch self {
        case .main:
            return "main"
        case .countrySearch:
            return "countrySearch"
        case .countryDetail(let country):
            return "countryDetail-\(country.code)"
        }
    }
}

protocol MainCoordinator: AnyObject {
    func showCountrySearch()
    func showCountryDetail(_ country: Country)
}

protocol SearchCountryCoordinator: AnyObject {
    func dismissSheet()
}

protocol CountryDetailCoordinator: AnyObject {
    func navigateBack()
}

/// Coordinator responsible for app navigation
final class AppCoordinator: ObservableObject, MainCoordinator, SearchCountryCoordinator, CountryDetailCoordinator {
    // MARK: - Properties
    
    private let factory = ViewModelFactory()
    private lazy var mainViewModel: MainViewModel = {
        factory.makeMainViewModel(coordinator: self)
    }()
    
    // Navigation state
    @Published var path = NavigationPath()
    @Published var presentedSheet: AppDestination?
    
    // MARK: - Navigation Methods
    
    func navigateTo(_ destination: AppDestination) {
        path.append(destination)
    }
    
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func navigateToRoot() {
        path.removeLast(path.count)
    }
    
    func presentSheet(_ destination: AppDestination) {
        presentedSheet = destination
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    func view(for destination: AppDestination) -> some View {
        switch destination {
        case .main:
            MainView(viewModel: mainViewModel)
        case .countrySearch:
            let vm = factory.makeCountrySearchViewModel(coordinator: self)
            CountrySearchView(viewModel: vm) {[weak self] selectedCountry in
                Task { await self?.mainViewModel.saveCountry(selectedCountry) }
            }
        case .countryDetail(let country):
            CountryDetailView(country: country, coordinator: self)
        }
    }
    
    func showCountrySearch() {
        presentSheet(.countrySearch)
    }
    
    func showCountryDetail(_ country: Country) {
        navigateTo(.countryDetail(country))
    }
}

struct CoordinatorView: View {
    @StateObject var coordinator = AppCoordinator()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.view(for: .main)
                .navigationDestination(for: AppDestination.self) { destination in
                    coordinator.view(for: destination)
                }
        }
        .sheet(item: $coordinator.presentedSheet) { destination in
            coordinator.view(for: destination)
        }
    }
}
