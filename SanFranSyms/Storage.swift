//
//  Storage.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 13.06.22.
//

import Foundation
import Firebase
import FirebaseRemoteConfig
import SwiftUI

protocol StorageService {}

protocol SFSymbolsProvider {
    var allCategories: [SymbolsCategory] { get }
}

protocol AppConfigProvider {
    var content: ContentData? { get }

    func fetchConfig()
}

typealias ContentData = [SymbolsCategory]

class AppConfigManager: AppConfigProvider {
    private let remoteConfig: RemoteConfig // TODO: - set as global dependency

    var content: ContentData? {
        let symbolsData = remoteConfig.configValue(forKey: "content").dataValue
            let symbols = try? JSONDecoder().decode(SymbolsCategoriesResponse.self, from: symbolsData)

            if #available(iOS 16.0, *) {
                return symbols?.categories
            } else {
                let excludedCategory = symbols?.categories.first { $0.name == "what's new" }

                let categories: [SymbolsCategory]? = symbols?.categories.map { category in
                    var cat = category
                    cat.filterSymbols(excludedSymbols: excludedCategory?.symbols ?? [])
                    return cat
                }
                return categories
            }
    }

    init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
    }

    func fetchConfig() {
        Task { [weak self] in
            try await self?.remoteConfig.fetch()
            try await self?.remoteConfig.activate()
        }
    }
}

class FileStorageManager: StorageService {

    static let shared = FileStorageManager()

    private var symbolCategories: [SymbolsCategory] {
        getCategories()
    }

    private var configProvider: AppConfigProvider = AppConfigManager()

    private init() {}

    private func getCategories() -> [SymbolsCategory] {

        if let content = configProvider.content {
            return content
        } else {
            configProvider.fetchConfig()

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
    }

    func allCategories() -> [SymbolsCategory] {
        return symbolCategories.filter { category in
            guard #available(iOS 16.0, *) else { return category.name != "what's new" }

            return true
        }
    }
}

class SFSymbolsManager: SFSymbolsProvider {
    var allCategories: [SymbolsCategory] {
        FileStorageManager.shared.allCategories()
    }
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
    }
}

struct SymbolsCategoriesResponse: Codable {
    var categories: [SymbolsCategory]
}
