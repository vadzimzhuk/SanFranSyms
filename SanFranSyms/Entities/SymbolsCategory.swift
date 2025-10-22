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

struct SFSymbolsCategory: Hashable, Codable {
    var name: String
    var iconName: String
    var sfSymbols: [SFSymbol]

    mutating func filterSymbols(excludedSymbols: [String]) {
        var counter = 0
        sfSymbols.removeAll { symbol in
            if excludedSymbols.contains(symbol.id) { counter += 1}
            return excludedSymbols.contains(symbol.id)
        }
    }
}

extension SFSymbolsCategory: SFSymbolsCategoryProtocol {
    var symbols: [String] {
        sfSymbols.map { $0.id }
    }
}

extension SymbolsCategory {
    var asSFSymbolsCategory: SFSymbolsCategory {
        .init(name: self.name, iconName: self.iconName, sfSymbols: symbols.map { SFSymbol(id: $0) })
    }
}
