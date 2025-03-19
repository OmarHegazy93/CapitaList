//
//  MockNetworkProvider.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

import Foundation
@testable import CapitaList

final class MockNetworkProvider: NetworkProviderProtocol {
    // Configure mock responses
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        // If error is set, throw it
        if let mockError = mockError {
            throw mockError
        }
        
        // Return mock data or empty data if not set
        let data = mockData ?? Data()
        
        // Return mock response or create a default success response
        let response = mockResponse ?? HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        return (data, response)
    }
    
    // MARK: - Helper Methods for Testing
    
    /// Set a successful response with data
    func setSuccessResponse(data: Data, for url: URL? = nil, statusCode: Int = 200) {
        self.mockData = data
        self.mockResponse = HTTPURLResponse(
            url: url ?? URL(string: "https://example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
        self.mockError = nil
    }
    
    /// Set a JSON success response from a dictionary
    func setJSONResponse(_ json: [String: Any], for url: URL? = nil, statusCode: Int = 200) throws {
        let jsonData = try JSONSerialization.data(withJSONObject: json)
        setSuccessResponse(data: jsonData, for: url, statusCode: statusCode)
    }
    
    /// Set a failure response
    func setFailureResponse(statusCode: Int, for url: URL? = nil) {
        self.mockData = nil
        self.mockResponse = HTTPURLResponse(
            url: url ?? URL(string: "https://invalidURL.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
        self.mockError = nil
    }
    
    /// Set a network error
    func setNetworkError(_ error: Error) {
        self.mockError = error
        self.mockResponse = nil
        self.mockData = nil
    }
}
