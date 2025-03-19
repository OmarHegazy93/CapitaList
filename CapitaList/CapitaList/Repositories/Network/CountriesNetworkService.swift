//
//  CountriesNetworkService.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

import Foundation

actor CountriesNetworkService {
    private let baseURL = "https://restcountries.com/v2/all"
    private let networkProvider: NetworkProviderProtocol
    
    init(networkProvider: NetworkProviderProtocol = URLSession.shared) {
        self.networkProvider = networkProvider
    }
    
    func fetchAllCountries() async -> Result<[Country], CountryError> {
        guard let url = URL(string: baseURL) else {
            return .failure(.invalidData)
        }
        
        do {
            let (data, response) = try await networkProvider.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return .failure(.networkError("Invalid response"))
            }
            
            return parseCountriesResponse(from: data)
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }
    
    private func parseCountriesResponse(from data: Data) -> Result<[Country], CountryError> {
        do {
            // Parse the API response
            let countries = try JSONDecoder().decode([Country].self, from: data)
            return .success(countries)
        } catch {
            return .failure(.invalidData)
        }
    }
}
