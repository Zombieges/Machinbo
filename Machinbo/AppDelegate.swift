//
//  AppDelegate.swift
//  Machinbo
//
//  Created by 渡辺和宏 on 2015/06/14.
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
        
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        Parse.enableLocalDatastore()
        
        let googleMapsKey = ConfigHelper.getPlistKey("GOOGLE_MAPS_API_KEY") as String
        let parseAppIdKey = ConfigHelper.getPlistKey("PARSE_APP_ID_KEY") as String
        let parseClientKey = ConfigHelper.getPlistKey("PARSE_CLIENT_KEY") as String
        
        println("★google maps api key = " + googleMapsKey)
        println("★PASER APP KEY = " + parseAppIdKey)
        println("★PASER CLIENT KEY = " + parseClientKey)
        
        //GoogleMaps
        GMSServices.provideAPIKey(googleMapsKey)
        
        //Parse
        Parse.setApplicationId(parseAppIdKey, clientKey:parseClientKey)
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        /*
        var aDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist") {
            aDict = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = aDict {
            println("google maps api key = " + (dict.objectForKey("GOOGLE_MAPS_API_KEY") as! String))
            println("★PASER APP KEY = " + (dict.objectForKey("PARSE_APP_ID_KEY") as! String))
            println("★PASER CLIENT KEY = " + (dict.objectForKey("PARSE_CLIENT_KEY") as! String))
            
            
            GMSServices.provideAPIKey(dict.objectForKey("GOOGLE_MAPS_API_KEY") as! String )
            // Initialize Parse.
            //Parse.setApplicationId(dict.objectForKey("PARSE_APP_ID_KEY") as! String,
            //    clientKey: dict.objectForKey("PARSE_CLIENT_KEY") as! String)
            
            
            // [Optional] Track statistics around application opens.
            //PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        }
        */
        
        
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

