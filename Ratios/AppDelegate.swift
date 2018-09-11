//
//  AppDelegate.swift
//  Ratios
//
//  Created by Pouria Almassi on 9/4/18.
//  Copyright © 2018 Blockchain Developer. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ThemeService.shared.theme = DarkTheme()
        return true
    }
}
