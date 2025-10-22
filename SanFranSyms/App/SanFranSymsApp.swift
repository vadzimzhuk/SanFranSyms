//
//  SanFranSymsApp.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 13.06.22.
//

import SwiftUI
import Firebase

@main
struct SanFranSymsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let searchEngine = SFSymbolSemanticSearchEngine.shared

    var body: some Scene {
        WindowGroup {
            SymbolsCategoriesView()
        }
    }

    init() {
        FirebaseApp.configure()
    }
}
