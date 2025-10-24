//
//  SanFranSymsApp.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 13.06.22.
//

import SwiftUI
import SwiftData
import Firebase

@main
struct SanFranSymsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    let modelContainer: ModelContainer

    var contentProvider: SFSymbolsManager

    init() {
        let schema = Schema(versionedSchema: DBSchema100.self)

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            contentProvider = SFSymbolsManager(storageService: FileStorageManager(modelContainer: modelContainer))
        } catch {
            fatalError("Failed to initialize model container: \(error)")
        }

        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            SymbolsCategoriesView()
        }
        .environmentObject(contentProvider)
    }
}

enum DBSchema100: VersionedSchema {
    static var models: [any PersistentModel.Type] = [SFSymbolsCategory.self, SFSymbol.self]
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
}
