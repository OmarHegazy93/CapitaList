//
//  MainView.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

import SwiftUI

struct MainView: View {
    @State private var viewModel: MainViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var errorMessage: String?
    @State private var isShowingError = false
    
    init(viewModel: MainViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            countriesListView
                .navigationTitle("My Countries")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            coordinator.presentSheet(.countrySearch)
                        }) {
                            Image(systemName: "plus")
                                .fontWeight(.semibold)
                        }
                        .disabled(isMaxCountriesReached)
                    }
                }
                .alert("Error", isPresented: $isShowingError) {
                    Button("OK") { isShowingError = false }
                } message: {
                    Text(errorMessage ?? "An unknown error occurred")
                }
            
            // Empty state
            if isEmptyState {
                emptyStateView
            }
        }
        .task {
            await viewModel.loadInitialData()
        }
    }
    
    private var countriesListView: some View {
        Group {
            switch viewModel.savedCountriesState {
            case .idle, .loading:
                ProgressView()
                    .scaleEffect(1.5)
                
            case .loaded(let countries):
                if countries.isEmpty {
                    // Empty state handled by ZStack
                    Color.clear
                } else {
                    List {
                        ForEach(countries) { country in
                            Button {
                                coordinator.navigateTo(.countryDetail(country))
                            } label: {
                                CountryRowView(country: country)
                            }
                            .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .slide))
                        }
                        .onDelete { indexSet in
                            deleteCountries(at: indexSet, from: countries)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: countries)
                }
                
            case .error(let error):
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
                    .onAppear {
                        errorMessage = error
                        isShowingError = true
                    }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            
            Text("No Countries Added")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add a country by tapping the + button")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .transition(.opacity)
    }
    
    private var isEmptyState: Bool {
        if case .loaded(let countries) = viewModel.savedCountriesState, countries.isEmpty {
            return true
        }
        return false
    }
    
    private var isMaxCountriesReached: Bool {
        if case .loaded(let countries) = viewModel.savedCountriesState, countries.count >= 5 {
            return true
        }
        return false
    }
    
    private func deleteCountries(at offsets: IndexSet, from countries: [Country]) {
        for index in offsets {
            Task {
                let country = countries[index]
                await viewModel.removeCountry(code: country.code)
            }
        }
    }
}
