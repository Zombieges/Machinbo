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
    var mainNavigationCtrl: UINavigationController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        ParseHelper.launch(launchOptions)
        
        let googleMapsKey = ConfigHelper.getPlistKey("GOOGLE_MAPS_API_KEY") as String
        
        NSLog("★google maps api key = " + googleMapsKey)
        
        //GoogleMaps
        GMSServices.provideAPIKey(googleMapsKey)
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if !PersistentData.firstLaunch {
            NSLog("初めての起動です★")
            if PersistentData.userID == "" {
                PersistentData.userID = NSUUID().UUIDString
                
                NSLog("★UserID(New) = " + PersistentData.userID)
                
                //Profile画面へ遷移
                let currentController = storyboard.instantiateViewControllerWithIdentifier("profile") as? ProfileViewController
                //self.window?.rootViewController = currentController
                
            }
            
        } else {
            
            //UserInfo Search
            var query = PFQuery(className: "UserInfo")
            query.whereKey("UserID", containsString: PersistentData.userID)
            query.findObjectsInBackgroundWithBlock { (objects, error) in
                if error != nil {
                    //MAP画面へ遷移
                    let currentController = storyboard.instantiateViewControllerWithIdentifier("map") as? MapViewController
                    //self.window?.rootViewController = currentController
                }
            }
        }
        */
        
        /*
        登録済みか否かをチェック
        */
        NSLog("userID　　　" + PersistentData.userID)
        if PersistentData.userID != "" {
        //if (0 == 1){
            /*
            Main NavigationController
            */
            //基点となるViewを定義
            var storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            var mainViewController = storyboard.instantiateInitialViewController() as! UIViewController
            mainNavigationCtrl = UINavigationController(rootViewController: mainViewController)
            
            mainNavigationCtrl!.navigationBar.barTintColor = LayoutManager.getUIColorFromRGB(0x3949AB)
            mainNavigationCtrl!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
            
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window?.rootViewController = mainNavigationCtrl
            self.window?.makeKeyAndVisible()
            
        } else {
            
            let profileViewCtrl: ProfileViewController = ProfileViewController()
            
            // UIWindowを生成する.
            profileViewCtrl.FarstTimeStart = true
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window?.rootViewController = profileViewCtrl
            self.window?.makeKeyAndVisible()

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
 
