//
//  SymbolsCategory.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 2.05.23.
//

import Foundation

struct SymbolsCategory: Hashable, Codable {
    var name: String
    var iconName: String
    var symbols: [String]

    mutating func filterSymbols(excludedSymbols: [String]) {
        var counter = 0
        symbols.removeAll { symbol in
            if excludedSymbols.contains(symbol) { counter += 1}
            return excludedSymbols.contains(symbol)
        }
    }
}

struct SymbolsCategoriesResponse: Codable {
    var categories: [SymbolsCategory]
}
