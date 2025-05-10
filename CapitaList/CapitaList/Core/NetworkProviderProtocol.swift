//
//  NetworkProviderProtocol.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//


import Foundation

protocol NetworkProviderProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkProviderProtocol {}
