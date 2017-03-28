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
 import AWSSNS
 import Fabric
 import TwitterKit
 import UserNotifications
 import GoogleMobileAds
 
 @UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let registrationKey = "onRegistrationCompleted"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //
        // REGISTER DEVICE TOKEN FOR SNS
        //
        if #available(iOS 10.0, *) {
            // iOS10.0以上
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
                guard error == nil else { return }
                
                if granted { UIApplication.shared.registerForRemoteNotifications() }
            }
        } else {
            
            // それ以外
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        // Notification Ready
        NotificationHelper.launch()
        ParseHelper.launch(launchOptions)
        
        
        let googleMapsKey = ConfigData(type: .googleMap).getPlistKey
        print("★google maps api key = " + googleMapsKey)
        
        //GoogleMaps
        GMSServices.provideAPIKey(googleMapsKey)
        
        //AdMob
        let AdMobAppID = ConfigData(type: .adMobApp).getPlistKey
        GADMobileAds.configure(withApplicationID: AdMobAppID)
        print("★google admob app id = " + AdMobAppID)
        
        
        //Fabric認証
        Fabric.with([Twitter()])
        
        //TabBarを生成
        if PersistentData.User().userID.isEmpty {
            //初期表示はProfileViewのみ
            let navigationCntroller = LayoutManager.createNavigationProfile()
            self.window?.rootViewController = navigationCntroller
            self.window?.makeKeyAndVisible()
            
        } else {
            let tabBarController = LayoutManager.createNavigationAndTabItems()
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.addSubview(tabBarController.view)
            self.window?.rootViewController = tabBarController
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }
    
    // REGISTER DEVICE TOKEN
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        
        // remove "<>" and space from deviceToken
        //let removingCharacterSet = CharacterSet(charactersIn: "<>")
        
        // get device token
        let deviceTokenAsString = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        
        print("Device token = \(deviceTokenAsString)")
        
        // save device token to local db
        var userData = PersistentData.User()
        userData.deviceToken = deviceTokenAsString
        
    }
    
    // FAILED TO REGISTER DEVICE TOKEN
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //print("couldn't register: \(error)")
        print("Registration for remote notification failed with error: \(error.localizedDescription)")
        // [END receive_apns_token_error]
        let userInfo = ["error": error.localizedDescription]
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: registrationKey), object: nil, userInfo: userInfo)
    }
    
    // The FUNCTION IS FOR RECIVING NOTIFICATION
    func application( _ application: UIApplication,
                      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                      fetchCompletionHandler handler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Notification receiveda: \(userInfo)")
        
        print("Notification receiveda: \(userInfo)")
        if let aps = userInfo["aps"] as? [String:Any] {
            print("alert: \(aps["alert"] as? String)")
            UIAlertController.showAlertView("", message: (aps["alert"] as! String))
            
        }
        
        handler(UIBackgroundFetchResult.noData);
        // [END_EXCLUDE]
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // BadgeNumber を0にする.
        UIApplication.shared.applicationIconBadgeNumber = 0

    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
 }
 
