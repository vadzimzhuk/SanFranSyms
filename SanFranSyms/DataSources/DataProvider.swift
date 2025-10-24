//
//  DataProvider.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 2.05.23.
//

import Foundation

class SFSymbolsManager: ObservableObject {
    let storageService: StorageService
    let searchEngine: SFSymbolSemanticSearchEngine = .init()

    var allCategories: [SFSymbolsCategory] {
        storageService.sfSymbolsCategories
    }

    init(storageService: StorageService) {
        self.storageService = storageService

        checkTokens()
    }

    private func checkTokens() {
        for category in allCategories {
            for symbol in category.sfSymbols {
                if symbol.token.isEmpty {

                    Task {
                        if let token = searchEngine.embeddingVector(for: symbol.text) {
                            symbol.token = token
                        } else {
                            print("❌ Error embedding")
                        }

                        await MainActor.run {
                            storageService.save()
                        }
                    }
                }
            }
        }
    }
}
