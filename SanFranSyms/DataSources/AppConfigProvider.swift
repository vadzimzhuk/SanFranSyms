//
//  AppConfig.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 2.05.23.
//

import Foundation
import FirebaseRemoteConfig

protocol AppConfigProvider {
    var content: ContentData? { get }
}

class AppConfigManager: AppConfigProvider {

    private let remoteConfig: RemoteConfig

    var symbols: [SymbolsCategory] {
        let symbolsData = remoteConfig.configValue(forKey: "sfsymbols").dataValue

        if symbolsData.isEmpty {
            Task {
                try? await fetchAndActivateConfig()
            }
        }

        let symbols = try? JSONDecoder().decode(SymbolsCategoriesResponse.self, from: symbolsData)

        return symbols?.categories ?? []
    }

    var content: ContentData? {

        if #available(iOS 16.0, *) {
            return symbols
        } else {
            let excludedCategory = symbols.first { $0.name == "what's new" }

            let categories: [SymbolsCategory]? = symbols.map { category in
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

    @discardableResult
    private func fetchAndActivateConfig() async throws -> RemoteConfigFetchStatus? {
        var status: RemoteConfigFetchStatus?

        status = try await self.remoteConfig.fetch()
        try await self.remoteConfig.activate()

        return status
    }
}
