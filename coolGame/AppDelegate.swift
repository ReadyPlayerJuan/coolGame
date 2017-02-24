//
//  AppDelegate.swift
//  another test game
//
//  Created by Erin Seel on 12/3/16.
//  Copyright © 2016 Nick Seel. All rights reserved.
//
import UIKit
//import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:[UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        /*
        BITHockeyManager.shared().configure(withIdentifier: "968c1f596266449795313281eabb6296")
        // Do some additional configuration if needed here
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()*/


        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        GameState.ignoreDelta = true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        GameState.ignoreDelta = true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        //EntityManager.redrawEntities(node: GameState.drawNode, name: "all")
        GameState.ignoreDelta = true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension String {
    func length() -> Int {
        return self.characters.count
    }
    
    func charAt(_ i: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: i)
        let end = self.index(self.startIndex, offsetBy: i+1)
        let range = start..<end
        return self.substring(with: range)
    }
    
    func toInt() -> Int? {
        return NumberFormatter().number(from: self)?.intValue
    }
    
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}

