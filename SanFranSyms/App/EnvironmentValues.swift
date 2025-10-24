//
//  EnvironmentValues.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 2.05.23.
//

import SwiftUI

    // Storage

    // Config
struct AppConfigProviderKey: EnvironmentKey {
    static let defaultValue: AppConfigProvider = DependencyBuilder.appConfigProvider
}

    // MARK: - EnvironmentValues
extension EnvironmentValues {


    var appConfigProvider: AppConfigProvider {
        get {
            self[AppConfigProviderKey.self]
        }
        set {
            self[AppConfigProviderKey.self] = newValue
        }
    }
}

extension View {
    func appConfigProvider(_ appConfigProvider: AppConfigProvider) -> some View {
        environment(\.appConfigProvider, appConfigProvider)
    }
}
