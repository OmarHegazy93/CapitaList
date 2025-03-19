//
//  StorageProviderProtocol.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

import Foundation

protocol StorageProviderProtocol: AnyObject {
    func set(_ value: Any?, forKey defaultName: String)
    func data(forKey defaultName: String) -> Data?
}

extension UserDefaults: StorageProviderProtocol {}
