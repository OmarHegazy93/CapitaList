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

/// Coordinator responsible for app navigation
final class AppCoordinator: ObservableObject {
    // MARK: - Properties
    
    // Dependency container
    private let dependencies: DependencyContainer
    
    // Navigation state
    @Published var path = NavigationPath()
    @Published var presentedSheet: AppDestination?
    
    // MARK: - Initialization
    
    init(dependencies: DependencyContainer) {
        self.dependencies = dependencies
    }
    
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
            MainView(viewModel: dependencies.mainViewModel)
        case .countrySearch:
            CountrySearchView(viewModel: dependencies.mainViewModel)
        case .countryDetail(let country):
            CountryDetailView(country: country, coordinator: self)
        }
    }
} 

struct CoordinatorView: View {
    @StateObject var coordinator = AppCoordinator(dependencies: DependencyContainer())
    
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
        .environmentObject(coordinator)
    }
}
