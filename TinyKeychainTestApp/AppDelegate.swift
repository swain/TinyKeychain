//
//  AppDelegate.swift
//  TinyKeychainTestApp
//
//  Created by Swain Molster on 8/12/18.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    @nonobjc private let window = UIWindow(frame: UIScreen.main.bounds)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        
        return true
    }


}

