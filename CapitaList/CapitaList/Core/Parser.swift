//
//  DataParserProtocol.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

import Foundation

/// Enum representing possible parsing errors
public enum ParsingError: Error {
    /// Error indicating invalid data with the associated underlying error
    case invalidData(Error)
}

/// Implementation of the Data Parser conforming to `DataParserProtocol`
final class Parser {
    /// The JSON decoder used for decoding data
    private let decoder: JSONDecoder
    private let encode: JSONEncoder
    
    /// Initializer with dependency injection for JSONDecoder
    /// - Parameter decoder: The JSON decoder to use, defaults to `JSONDecoder` with snake case key decoding strategy
    init(
        encode: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.encode = encode
        self.decoder = decoder
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func decode<T: Decodable>(_ data: Data) -> Result<T, ParsingError> {
        do {
            let decodedObject = try decoder.decode(T.self, from: data)
            return .success(decodedObject)
        } catch {
            return .failure(.invalidData(error))
        }
    }
    
    func encode<T: Encodable>(_ model: T) -> Result<Data, ParsingError> {
        do {
            let encodedData = try JSONEncoder().encode(model)
            return .success(encodedData)
        } catch {
            return .failure(.invalidData(error))
        }
    }
}
