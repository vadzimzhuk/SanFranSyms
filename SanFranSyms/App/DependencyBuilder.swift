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
}
