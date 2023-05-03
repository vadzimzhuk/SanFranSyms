//
//  Storage.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 13.06.22.
//

import Foundation
import Firebase
import SwiftUI

protocol StorageService {
    func getSymbols() -> [SymbolsCategory]
}

typealias ContentData = [SymbolsCategory]

class FileStorageManager: StorageService {
    static let fileName = "SFSymbolsAll"
    static let fileNameExtension = ".json"

    private var symbolCategories: [SymbolsCategory] { getCategories() }

    private func getCategories() -> [SymbolsCategory] {
        let url = Bundle.main.url(forResource: Self.fileName, withExtension: Self.fileNameExtension)!
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

    func getSymbols() -> [SymbolsCategory] {
        return symbolCategories.filter { category in
            guard #available(iOS 16.0, *) else { return category.name != "what's new" }

            return true
        }
    }
}
