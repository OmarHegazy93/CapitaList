//
//  MainView.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

import SwiftUI

struct MainView: View {
    @State private var viewModel: MainViewModel
    @State private var isShowingCountrySearch = false
    @State private var errorMessage: String?
    @State private var isShowingError = false
    
    init(viewModel: MainViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                countriesListView
                    .navigationTitle("My Countries")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                isShowingCountrySearch = true
                            }) {
                                Image(systemName: "plus")
                                    .fontWeight(.semibold)
                            }
                            .disabled(isMaxCountriesReached)
                        }
                    }
                    .sheet(isPresented: $isShowingCountrySearch) {
                        CountrySearchView(
                            viewModel: viewModel,
                            isPresented: $isShowingCountrySearch
                        )
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
                            NavigationLink(destination: CountryDetailView(country: country)) {
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

struct CountryRowView: View {
    let country: Country
    
    var body: some View {
        HStack(spacing: 15) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 30)
                .overlay(
                    Text(country.code.prefix(2))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(country.name)
                    .font(.headline)
                
                Text(country.capital ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct CountryDetailView: View {
    let country: Country
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 15) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 60)
                        .overlay(
                            Text(country.code.prefix(2))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        )
                    
                    VStack(alignment: .leading) {
                        Text(country.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(country.code)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.bottom)
                
                detailSection(title: "Capital", value: country.capital ?? "")
                
                detailSection(
                    title: "Currencies",
                    value: country.currencyString,
                    subtitle: ""
                )
                
                if let location = country.location {
                    detailSection(
                        title: "Coordinates",
                        value: String(format: "Lat: %.2f", location.latitude),
                        subtitle: String(format: "Long: %.2f", location.longitude)
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Country Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func detailSection(title: String, value: String, subtitle: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .padding(.top, 4)
        }
    }
}
