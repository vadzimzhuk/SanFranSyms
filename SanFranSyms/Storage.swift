//
//  Storage.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 13.06.22.
//

import Foundation
import SwiftUI

protocol StorageService {
//    func getCategories() -> SymbolsCategoriesResponse
}

protocol SFSymbolsProvider {
    var allCategories: [SymbolsCategory] { get }
}

class FileStorageManager: StorageService {

    static let shared = FileStorageManager()

    private var symbolCategories: [SymbolsCategory] = []

    private init() {
        symbolCategories = getCategories()
    }

    private func getCategories() -> [SymbolsCategory] {
        let url = Bundle.main.url(forResource: "SFSymbolsAll", withExtension: ".json")!
        let data = try! Data(contentsOf: url)
        let symbols = try! JSONDecoder().decode(SymbolsCategoriesResponse.self, from: data)

        if #available(iOS 16.0, *) {
            return symbols.categories
        } else {
            let excludedCategory = symbols.categories.first { $0.name == "what's new" }

            let categories: [SymbolsCategory] = symbols.categories.map { category in
                var cat = category
                cat.filterSymbols(excludedSymbols: excludedCategory?.symbols ?? [])
                return cat
            }
            return categories
        }
    }

    func allCategories() -> [SymbolsCategory] {
        // TODO: - exclude whats new
        if #available(iOS 16.0, *) {
            return symbolCategories
        } else {
            return symbolCategories.filter { category in
                category.name != "what's new"
            }
        }
    }
}

class SFSymbolsManager: SFSymbolsProvider {
    var allCategories: [SymbolsCategory] = {
        FileStorageManager.shared.allCategories()
    }()
}

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
        print("cleaned category: \(name) (\(counter))")
    }
}

struct SymbolsCategoriesResponse: Codable {
    var categories: [SymbolsCategory]
}
