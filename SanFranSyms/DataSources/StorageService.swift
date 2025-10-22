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

    init() {
        updateJSONWithAllCategory()
    }

    private func getBundleData() -> Data? {
        guard let url = Bundle.main.url(forResource: Self.fileName, withExtension: Self.fileNameExtension) else {
            return nil
        }

        return try? Data(contentsOf: url)
    }

    private func updateJSONWithAllCategory() {
        guard let url = Bundle.main.url(forResource: Self.fileName, withExtension: Self.fileNameExtension) else { return }

        do {
            guard let data = getBundleData() else { return }
            var response = try JSONDecoder().decode(SymbolsCategoriesResponse.self, from: data)

            // Remove existing "all" category if it exists
            response.categories.removeAll { $0.name.lowercased() == "all" }

            // Insert the generated all category at the beginning
            let allCategory = allSymbolsCategory()
            response.categories.insert(allCategory, at: 0)

            // Encode back to JSON
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let updatedData = try encoder.encode(response)

            // Write back to bundle (Note: This won't work in production as bundle is read-only)
            // For development, you might want to write to Documents directory instead
            try updatedData.write(to: url)

        } catch {
            print("Failed to update JSON file: \(error)")
        }
    }

    private func getCategories() -> [SymbolsCategory] {
        guard let data = getBundleData() else { return [] }

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

    private func allSymbolsCategory() -> SymbolsCategory {
        let categories = getCategories()
        let symbols = symbolCategories.flatMap(\.symbols)
        let uniqueSymbols = Array(Set(symbols))

        let allCategory = SymbolsCategory(
            name: "all",
            iconName: "square.grid.2x2",
            symbols: uniqueSymbols
        )

        return allCategory
    }

    func getSymbols() -> [SymbolsCategory] {
        return symbolCategories.filter { category in
//            guard #available(iOS 16.0, *) else { return category.name != "what's new" }

            return true
        }
    }
}
