//
//  MockStorageProvider.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

import Foundation
@testable import CapitaList

class MockStorageProvider: StorageProviderProtocol {
    private var storage: [String: Any] = [:]
    
    func set(_ value: Any?, forKey defaultName: String) {
        // Store the value (or remove it if nil)
        if let value = value {
            storage[defaultName] = value
        } else {
            storage.removeValue(forKey: defaultName)
        }
    }
    
    func data(forKey defaultName: String) -> Data? {
        if let data = storage[defaultName] as? Data {
            return data
        }
        
        return nil
    }
}
