 //
//  AppDelegate.swift
//  keepin
//
//  Created by Ben Walker on 2017-06-21.
//  Copyright © 2017 Ben Walker. All rights reserved.
//

 
 import UIKit
 import SpriteKit
 import GameplayKit
 import StoreKit
 import AVFoundation
 

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		do {
			try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
			try AVAudioSession.sharedInstance().setActive(true)
		} catch (let error) {
			print(error)
		}
        return true
    }
    
   
    func applicationWillResignActive(_ application: UIApplication) {
               
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
       
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
       
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "openCount") + 1, forKey: "openCount")
        NotificationCenter.default.post(Notification.init(name: Notification.Name("showBanner")))
    
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

