//
//  CountrySearchView.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

import SwiftUI

// This file defines the search view for finding countries
struct CountrySearchView: View {
    let viewModel: MainViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var selectedCountry: Country?
    @State private var isShowingSuccessAnimation = false
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    searchBarView
                    
                    Spacer()
                    
                    searchResultView
                    
                    Spacer()
                }
                .padding(.horizontal)
                .navigationTitle("Search Countries")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            coordinator.dismissSheet()
                        }
                    }
                }
                .alert("Error", isPresented: $showError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
                
                // Success animation overlay
                if isShowingSuccessAnimation {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.green)
                            
                            Text("Added Successfully!")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.top)
                        }
                        .padding(30)
                        .background(Color(uiColor: .systemBackground).opacity(0.9))
                        .cornerRadius(20)
                        .shadow(radius: 10)
                    }
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                isShowingSuccessAnimation = false
                            }
                            coordinator.dismissSheet()
                        }
                    }
                }
            }
        }
    }
    
    private var searchBarView: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search for a country", text: $searchText)
                    .autocorrectionDisabled()
                    .onSubmit {
                        performSearch()
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(10)
            .padding(.vertical)
            
            if isSearching {
                ProgressView()
                    .padding()
            }
        }
    }
    
    private var searchResultView: some View {
        Group {
            switch viewModel.searchResultState {
            case .idle:
                emptyStateView
                
            case .loading:
                ProgressView("Searching...")
                    .padding()
                
            case .loaded(let country):
                countryResultView(country)
                
            case .error(let message):
                VStack(spacing: 15) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("Country Not Found")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(message)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(12)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.searchResultState)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 15) {
            Image(systemName: "globe.americas")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            
            Text("Search for a Country")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Enter a country name to see details and add it to your saved list")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(30)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }
    
    private func countryResultView(_ country: Country) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 40)
                    .overlay(
                        Text(country.code.prefix(2))
                            .font(.headline)
                            .fontWeight(.bold)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(country.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Capital: \(country.capital ?? "Unknown")")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("Currencies: \(country.currencyString)")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Button(action: {
                addCountryToSavedList(country)
            }) {
                HStack {
                    Spacer()
                    Text("Add to My Countries")
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 10)
        }
        .padding(20)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        
        Task {
            await viewModel.searchCountry(name: searchText)
            await MainActor.run {
                isSearching = false
            }
        }
    }
    
    private func addCountryToSavedList(_ country: Country) {
        Task {
            let success = await viewModel.saveCountry(country)
            
            await MainActor.run {
                if success {
                    withAnimation(.spring()) {
                        isShowingSuccessAnimation = true
                    }
                } else {
                    errorMessage = "Failed to add country. You may already have 5 countries saved."
                    showError = true
                }
            }
        }
    }
}
