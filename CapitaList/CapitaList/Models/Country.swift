//
//  Models.swift
//  CapitaList
//
//  Created by Omar Hegazy on 19/03/2025.
//

struct Country: Codable, Equatable, Identifiable {
    let name: String
    let code: String
    let capital: String
    private let latlngArray: [Double]
    private let currenciesArray: [Currency]
    
    init(
        name: String,
        code: String,
        capital: String,
        latlngArray: [Double],
        currenciesArray: [Currency]
    ) {
        self.name = name
        self.code = code
        self.capital = capital
        self.latlngArray = latlngArray
        self.currenciesArray = currenciesArray
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case code = "alpha3Code"
        case capital
        case latlngArray = "latlng"
        case currenciesArray = "currencies"
    }
    
    var id: String { code }
    
    var location: Location? {
        guard latlngArray.count == 2 else { return nil }
        return Location(latitude: latlngArray[0], longitude: latlngArray[1])
    }
    
    var currencyString: String {
        guard let currency = currenciesArray.first else { return "" }
        return "\(currency.code) \(currency.name) \(currency.symbol)"
    }
}

struct Currency: Codable, Equatable {
    let code: String
    let name: String
    let symbol: String
}

struct Location: Hashable, Codable {
    let latitude: Double
    let longitude: Double
} 
