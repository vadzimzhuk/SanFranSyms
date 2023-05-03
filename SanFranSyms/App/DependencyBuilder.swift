//
//  DependencyBuilder.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 3.05.23.
//

import Foundation

enum DependencyBuilder {
    static var appConfigProvider: AppConfigProvider = {
        AppConfigManager()
    }()

    static var fileStorageService: StorageService = {
        FileStorageManager()
    }()

    static var sfSymbolsProvider: SFSymbolsProvider = {
        SFSymbolsManager(storageService: fileStorageService, configProvider: appConfigProvider)
    }()
}
