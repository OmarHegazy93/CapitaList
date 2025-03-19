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
    private let parser = Parser()
    
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
            
            // Use the parser to decode the API response
            let result: Result<[Country], ParsingError> = parser.decode(data)
            
            switch result {
            case .success(let countries):
                return .success(countries)
            case .failure:
                return .failure(.invalidData)
            }
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }
}
