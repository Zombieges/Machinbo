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
        
        // BadgeNumber を０にする.
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let googleMapsKey = ConfigHelper.getPlistKey("GOOGLE_MAPS_API_KEY") as String
        NSLog("★google maps api key = " + googleMapsKey)
        
        //GoogleMaps
        GMSServices.provideAPIKey(googleMapsKey)
        
        //Fabric認証
        Fabric.with([Twitter()])
        
        //Navgation & Tab
        //LayoutManager.createNavigationAndTabItems()
        createNavigationItem()
        
        return true
    }
    
    func createNavigationItem() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard PersistentData.User().userID != "" else {
            let firstViewController = storyboard.instantiateViewController(withIdentifier: "profile") as! ProfileViewController
            let mainNavigationCtrl = UINavigationController(rootViewController: firstViewController)
            mainNavigationCtrl.navigationBar.barTintColor = UIColor.hex("fffffff", alpha: 1)
            mainNavigationCtrl.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.darkGray]
            mainNavigationCtrl.navigationBar.tintColor = UIColor.darkGray
            mainNavigationCtrl.navigationBar.isTranslucent = false
            mainNavigationCtrl.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            mainNavigationCtrl.navigationBar.setBackgroundImage(UIImage(named: "BarBackground"),
                                                                for: .default)
            mainNavigationCtrl.navigationBar.shadowImage = UIImage()
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = mainNavigationCtrl
            self.window?.makeKeyAndVisible()
            return
        }
        
        let mapViewController = storyboard.instantiateViewController(withIdentifier: "map") as! MapViewController
        
        let mainNavigationCtrl = UINavigationController(rootViewController: mapViewController)
        mainNavigationCtrl.navigationBar.barTintColor = UIColor.hex("fffffff", alpha: 1)
        mainNavigationCtrl.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.darkGray]
        mainNavigationCtrl.navigationBar.tintColor = UIColor.darkGray
        mainNavigationCtrl.navigationBar.isTranslucent = false
        mainNavigationCtrl.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        mainNavigationCtrl.navigationBar.setBackgroundImage(UIImage(named: "BarBackground"),
                                                            for: .default)
        mainNavigationCtrl.navigationBar.shadowImage = UIImage()
        
        let mainTabBar = UITabBarItem(title: "ホーム", image: UIImage(named: "home@2x.png"), tag: 0)
        mainTabBar.setTitleTextAttributes([NSForegroundColorAttributeName : LayoutManager.getUIColorFromRGB(0x0D47A1)], for: .selected)
        mainNavigationCtrl.tabBarItem = mainTabBar
        
        
        let markerDragConroller = storyboard.instantiateViewController(withIdentifier: "entry") as! MarkerDraggableViewController
        
        let editNavigationCtrl = UINavigationController(rootViewController: markerDragConroller)
        editNavigationCtrl.navigationBar.barTintColor = UIColor.hex("fffffff", alpha: 1)
        editNavigationCtrl.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.darkGray]
        editNavigationCtrl.navigationBar.tintColor = UIColor.darkGray
        editNavigationCtrl.navigationBar.isTranslucent = false
        editNavigationCtrl.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        editNavigationCtrl.navigationBar.setBackgroundImage(UIImage(named: "BarBackground"),
                                                            for: .default)
        editNavigationCtrl.navigationBar.shadowImage = UIImage()
        
        let editTabBar = UITabBarItem(title: "登録", image: UIImage(named: "edit@2x.png"), tag: 1)
        editTabBar.setTitleTextAttributes([NSForegroundColorAttributeName : LayoutManager.getUIColorFromRGB(0x0D47A1)], for: .selected)
        editNavigationCtrl.tabBarItem = editTabBar
        

        let meetupViewController = storyboard.instantiateViewController(withIdentifier: "meetup") as! MeetupViewController
        
        let meetupNavigationCtrl = UINavigationController(rootViewController: meetupViewController)
        meetupNavigationCtrl.navigationBar.barTintColor = UIColor.hex("fffffff", alpha: 1)
        meetupNavigationCtrl.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.darkGray]
        meetupNavigationCtrl.navigationBar.tintColor = UIColor.darkGray
        meetupNavigationCtrl.navigationBar.isTranslucent = false
        meetupNavigationCtrl.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        meetupNavigationCtrl.navigationBar.setBackgroundImage(UIImage(named: "BarBackground"),
                                                              for: .default)
        meetupNavigationCtrl.navigationBar.shadowImage = UIImage()
        
        let meetupTabBar = UITabBarItem(title: "待ち合わせ", image: UIImage(named: "meetup@2x.png"), tag: 2)
        meetupTabBar.setTitleTextAttributes([NSForegroundColorAttributeName : LayoutManager.getUIColorFromRGB(0x0D47A1)], for: .selected)
        meetupNavigationCtrl.tabBarItem = meetupTabBar
        
        
        let profileViewController = storyboard.instantiateViewController(withIdentifier: "profile") as! ProfileViewController
        
        let profileNavigationCtrl = UINavigationController(rootViewController: profileViewController)
        profileNavigationCtrl.navigationBar.barTintColor = UIColor.hex("fffffff", alpha: 1)
        profileNavigationCtrl.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.darkGray]
        profileNavigationCtrl.navigationBar.tintColor = UIColor.darkGray
        profileNavigationCtrl.navigationBar.isTranslucent = false
        profileNavigationCtrl.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        profileNavigationCtrl.navigationBar.setBackgroundImage(UIImage(named: "BarBackground"),
                                                               for: .default)
        profileNavigationCtrl.navigationBar.shadowImage = UIImage()
        let profileTabBar = UITabBarItem(title: "プロフィール", image: UIImage(named: "profile_icon@2x.png"), tag: 3)
        profileTabBar.setTitleTextAttributes([NSForegroundColorAttributeName : LayoutManager.getUIColorFromRGB(0x0D47A1)], for: .selected)
        profileNavigationCtrl.tabBarItem = profileTabBar
        
        UITabBar.appearance().tintColor = LayoutManager.getUIColorFromRGB(0x0D47A1)
        
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([mainNavigationCtrl, editNavigationCtrl, meetupNavigationCtrl, profileNavigationCtrl], animated: false)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.addSubview(tabBarController.view)
        self.window?.rootViewController = tabBarController
        self.window?.makeKeyAndVisible()
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
    
    
    func application( _ application: UIApplication,
                      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                      fetchCompletionHandler handler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Notification receiveda: \(userInfo)")
        
        
        // to do notification off 時の処理を追記
        NotificationCenter.default.post(name: Notification.Name(rawValue: "CognitoPushNotification"), object: userInfo)
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
 
