//
//  CapitaListApp.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

import SwiftUI

struct CapitaListApp: App {
    var body: some Scene {
        WindowGroup {
            CoordinatorView()
        }
    }
}

@main
struct MainEntryPoint {
    static func main() {
        guard isProduction() else {
            TestApp.main()
            return
        }
 
        CapitaListApp.main()
    }
 
    private static func isProduction() -> Bool {
        return NSClassFromString("XCTestCase") == nil
    }
}

struct TestApp: App {
    var body: some Scene {
        WindowGroup {
        }
    }
}
