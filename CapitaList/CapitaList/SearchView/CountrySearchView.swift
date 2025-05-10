//
//  CountrySearchView.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

import SwiftUI

struct CountrySearchView: View {
    @State private var viewModel: SearchViewModel
    
    init(viewModel: SearchViewModel, onCountrySelected: @escaping (Country) -> Void) {
        let vm = viewModel
        vm.onCountrySelected = onCountrySelected
        _viewModel = State(wrappedValue: vm)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    searchBarView
                    
                    countriesList
                }
                .navigationTitle("Choose a Country")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            viewModel.dismiss()
                        }
                    }
                }
            }
            .task {
                await viewModel.loadAllCountries()
                await viewModel.loadCurrentlySelectedCountries()
            }
        }
    }
    
    private var searchBarView: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search countries", text: $viewModel.searchText)
                    .autocorrectionDisabled()
                    .onChange(of: viewModel.searchText) { _, newValue in
                        Task {
                            await viewModel.searchCountry(name: newValue)
                        }
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                        Task {
                            await viewModel.searchCountry(name: "")
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
        }
    }
    
    private var countriesList: some View {
        List {
            ForEach(viewModel.displayableCountries) { country in
                CountryRowView(country: country)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if viewModel.isSelectionValid(for: country) {
                            viewModel.onCountrySelected?(country)
                            viewModel.dismiss()
                        }
                    }
                    .listRowBackground(
                        viewModel.isSelectionValid(for: country)
                            ? Color(uiColor: .systemBackground)
                            : Color(uiColor: .systemGray6)
                    )
                    .disabled(!viewModel.isSelectionValid(for: country))
            }
        }
        .listStyle(.plain)
    }
}
