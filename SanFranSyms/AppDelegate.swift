//
//  AppDelegate.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 1.05.23.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        FirebaseApp.configure()

        return true
    }
}
