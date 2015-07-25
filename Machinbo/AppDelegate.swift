 //
 //  AppDelegate.swift
 //  Machinbo
 //
 //  Created by Zombieges on 2015/06/14.
 //  Copyright (c) 2015年 Zombieges. All rights reserved.
 //
 
 import UIKit
 import GoogleMaps
 import Parse
 import Bolts
 
 @UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Parse.enableLocalDatastore()
        
        let googleMapsKey = ConfigHelper.getPlistKey("GOOGLE_MAPS_API_KEY") as String
        let parseAppIdKey = ConfigHelper.getPlistKey("PARSE_APP_ID_KEY") as String
        let parseClientKey = ConfigHelper.getPlistKey("PARSE_CLIENT_KEY") as String
        
        NSLog("★google maps api key = " + googleMapsKey)
        NSLog("★PASER APP KEY = " + parseAppIdKey)
        NSLog("★PASER CLIENT KEY = " + parseClientKey)
        NSLog("★UUID = " + NSUUID().UUIDString)
        
        //GoogleMaps
        GMSServices.provideAPIKey(googleMapsKey)
        
        //Parse
        Parse.setApplicationId(parseAppIdKey, clientKey:parseClientKey)
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        
        // first time to launch this app
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.registerDefaults(["firstLaunch": true])
        
        
        var query: PFQuery = PFQuery(className: "UserInfo")
        query.whereKey("UserID", containsString: NSUUID().UUIDString)
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if error == nil {
                let currentController = storyboard.instantiateViewControllerWithIdentifier("profile") as? ProfileViewController
                //self.window?.rootViewController = currentController
                
                return
                
            } else {
                let currentController = storyboard.instantiateViewControllerWithIdentifier("map") as? MapViewController
                //self.window?.rootViewController = currentController
            }
        }
        
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
 }
 
