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
    var sfSymbolsCategories: [SFSymbolsCategory] { get }
//    func getSymbols() -> [SymbolsCategory]
//    var symbolCategories: [SymbolsCategory] { get }
}

typealias ContentData = [SymbolsCategory]

class FileStorageManager: StorageService {
    static let fileName = "SFSymbolsAll"
    static let sfFileName = "SFSymbolEntities"
    static let fileNameExtension = ".json"

    var symbolCategories: [SymbolsCategory] { getCategories() }
    var sfSymbolsCategories: [SFSymbolsCategory] = []

    init() {
        fetchSFSymbolCategories()
    }

    private func fetchSFSymbolCategories() {
        let categories = getSfCategories()

        if !categories.isEmpty {
            self.sfSymbolsCategories = categories
        } else {
            self.sfSymbolsCategories = getCategories().map { $0.asSFSymbolsCategory }

            saveSFSymbolCategories()
        }

        if self.sfSymbolsCategories.first?.sfSymbols.first?.token.isEmpty == true {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self else { return }
                    //                tokenize
                self.sfSymbolsCategories = self.sfSymbolsCategories.map { var category = $0
                    return category.tokenizeSymbols() }
                    //                save
                self.saveSFSymbolCategories()
            }
        }
    }

    private func getBundleData() -> Data? {
        guard let url = Bundle.main.url(forResource: Self.fileName, withExtension: Self.fileNameExtension) else {
            return nil
        }

        return try? Data(contentsOf: url)
    }

//    private func updateJSONWithAllCategory() {
//        guard let url = Bundle.main.url(forResource: Self.fileName, withExtension: Self.fileNameExtension) else { return }
//
//        do {
//            guard let data = getBundleData() else { return }
//            var response = try JSONDecoder().decode(SymbolsCategoriesResponse.self, from: data)
//
//            // Remove existing "all" category if it exists
//            response.categories.removeAll { $0.name.lowercased() == "all" }
//
//            // Insert the generated all category at the beginning
//            let allCategory = allSymbolsCategory()
//            response.categories.insert(allCategory, at: 0)
//
//            // Encode back to JSON
//            let encoder = JSONEncoder()
//            encoder.outputFormatting = .prettyPrinted
//            let updatedData = try encoder.encode(response)
//
//            // Write back to bundle (Note: This won't work in production as bundle is read-only)
//            // For development, you might want to write to Documents directory instead
//            try updatedData.write(to: url)
//
//        } catch {
//            print("Failed to update JSON file: \(error)")
//        }
//    }

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

//    private func allSymbolsCategory() -> SymbolsCategory {
//        let categories = getCategories()
//        let symbols = symbolCategories.flatMap(\.symbols)
//        let uniqueSymbols = Array(Set(symbols))
//
//        let allCategory = SymbolsCategory(
//            name: "all",
//            iconName: "square.grid.2x2",
//            symbols: uniqueSymbols
//        )
//
//        return allCategory
//    }

//    internal func getSymbols() -> [SymbolsCategory] {
//        return symbolCategories.filter { category in
////            guard #available(iOS 16.0, *) else { return category.name != "what's new" }
//
//            return true
//        }
//    }

    private func saveSFSymbolCategories() {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to get documents directory")
            return
        }

        let fileURL = documentsURL.appendingPathComponent(Self.sfFileName).appendingPathExtension(Self.fileNameExtension)

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(sfSymbolsCategories)

            try data.write(to: fileURL)
            print("Successfully saved sfSymbolsCategories to \(fileURL)")
        } catch {
            print("Failed to save sfSymbolsCategories: \(error)")
        }
    }

    private func getSfCategories() -> [SFSymbolsCategory] {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to get documents directory")
            return []
        }

        let url = documentsURL.appendingPathComponent(Self.sfFileName).appendingPathExtension(Self.fileNameExtension)

        do {
            let data = try Data(contentsOf: url)
            let symbols = try JSONDecoder().decode([SFSymbolsCategory].self, from: data)
            return symbols
        } catch {
            print(error)
        }

        return []
    }
}
