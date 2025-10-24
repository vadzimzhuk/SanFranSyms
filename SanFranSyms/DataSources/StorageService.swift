//
//  Storage.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 13.06.22.
//

import Foundation
import Firebase
import SwiftUI
import SwiftData

@Model
class SFSymbolsCategory {
    var name: String
    var iconName: String
    var sfSymbols: [SFSymbol]

    init(name: String, iconName: String, sfSymbols: [SFSymbol]) {
        self.name = name
        self.iconName = iconName
        self.sfSymbols = sfSymbols
    }
}

extension SymbolsCategory {
    var asSFSymbolsCategory: SFSymbolsCategory {
        SFSymbolsCategory(name: name, iconName: iconName, sfSymbols: symbols.map { SFSymbol(id: $0) })
    }
}

@Model
class SFSymbol {
    var id: String
    var text: String
    var token: [Double] = []

    init(id: String) {
        self.id = id
        self.text = id.split(separator: ".").joined(separator: " ")
    }
}

protocol StorageService {
    var sfSymbolsCategories: [SFSymbolsCategory] { get }
    func save()
}

typealias ContentData = [SymbolsCategory]

class FileStorageManager: StorageService {

    private let modelContext: ModelContext

    static let fileName = "SFSymbolsAll"
    static let fileNameExtension = ".json"

    var sfSymbolsCategories: [SFSymbolsCategory] {
        do {
            return try modelContext.fetch(FetchDescriptor<SFSymbolsCategory>())
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }

    init(modelContainer: ModelContainer) {
        self.modelContext = ModelContext(modelContainer)
        fillDBIfNeeded()
    }

    private func getBundleData() -> Data? {
        guard let url = Bundle.main.url(forResource: Self.fileName, withExtension: Self.fileNameExtension) else {
            return nil
        }

        return try? Data(contentsOf: url)
    }

    private func fillDBIfNeeded() {
        if sfSymbolsCategories.isEmpty {
            fetchDataToDB()
        }
    }

    private func fetchDataToDB() {
        do {
            guard let data = getBundleData() else { return }
            var response = try JSONDecoder().decode(SymbolsCategoriesResponse.self, from: data)

            let categories = response.categories.map { $0.asSFSymbolsCategory }
            for category in categories {
                modelContext.insert(category)
            }
        } catch {
            print(error)
        }
    }

    func save() {
        do {
            try modelContext.save()
        } catch {
            print("❌ error saving the context: \(error)")
        }
    }
}
