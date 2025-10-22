//
//  DataProvider.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 2.05.23.
//

import Foundation

protocol SFSymbolsProvider {
    var allCategories: [SymbolsCategory] { get }
}

class SFSymbolsManager: SFSymbolsProvider {
    let storageService: StorageService
    let configProvider: AppConfigProvider

    var allCategories: [SymbolsCategory] {
//        !configProvider.content.isEmpty ? configProvider.content : storageService.getSymbols()
        storageService.getSymbols()
    }

    init(storageService: StorageService, configProvider: AppConfigProvider) {
        self.storageService = storageService
        self.configProvider = configProvider
    }
}
