//
//  AppDelegate.swift
//  QuestionsApp
//
//  Created by William Cather on 6/25/25.
//

// MARK: File - AppDelegate.swift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var shared: AppDelegate { UIApplication.shared.delegate as! AppDelegate }
    var window: UIWindow?
    var rootNavigationController: UINavigationController?  // ← ADD THIS
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
