//
//  EnvironmentValues.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 2.05.23.
//

import SwiftUI

    // Storage
struct ContentProviderKey: EnvironmentKey {
    static let defaultValue: SFSymbolsProvider = DependencyBuilder.sfSymbolsProvider
}
    // Config
struct AppConfigProviderKey: EnvironmentKey {
    static let defaultValue: AppConfigProvider = DependencyBuilder.appConfigProvider
}
    // Subscription
struct SubscriptionServiceKey: EnvironmentKey {
    static let defaultValue: SubscriptionService? = DependencyBuilder.subscriptionService
}

    // MARK: - EnvironmentValues
extension EnvironmentValues {
    var contentProvider: SFSymbolsProvider {
        self[ContentProviderKey.self]
    }

    var appConfigProvider: AppConfigProvider {
        get {
            self[AppConfigProviderKey.self]
        }
        set {
            self[AppConfigProviderKey.self] = newValue
        }
    }
    
    var subscriptionService: SubscriptionService? {
        get {
            self[SubscriptionServiceKey.self]
        }
        set {
            self[SubscriptionServiceKey.self] = newValue
        }
    }
}

extension View {
    func appConfigProvider(_ appConfigProvider: AppConfigProvider) -> some View {
        environment(\.appConfigProvider, appConfigProvider)
    }
    
    func subscriptionService(_ subscriptionService: SubscriptionService?) -> some View {
        environment(\.subscriptionService, subscriptionService)
    }
}
