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

    var content: ContentData? {
        let symbolsData = remoteConfig.configValue(forKey: "content").dataValue
        let symbols = try? JSONDecoder().decode(SymbolsCategoriesResponse.self, from: symbolsData)

        if symbolsData.isEmpty {
            Task {
                try? await fetchAndActivateConfig()
            }
        }

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

    @discardableResult
    private func fetchAndActivateConfig() async throws -> RemoteConfigFetchStatus? {
        var status: RemoteConfigFetchStatus?

        status = try await self.remoteConfig.fetch()
        try await self.remoteConfig.activate()

        return status
    }
}
