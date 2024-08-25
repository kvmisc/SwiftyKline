//
//  AppDelegate.swift
//  klineapp
//
//  Created by Kevin Wu on 2024/08/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = KlineViewController()
    window?.makeKeyAndVisible()

    return true
  }

}
