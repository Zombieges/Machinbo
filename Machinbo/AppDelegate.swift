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
 
 @UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let registrationKey = "onRegistrationCompleted"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //
        // REGISTER DEVICE TOKEN FOR SNS
        //
        if #available(iOS 8.0, *) {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            // Fallback
            let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
            application.registerForRemoteNotificationTypes(types)
        }
        
        // Notification Ready
        NotificationHelper.launch()
        ParseHelper.launch(launchOptions)
        
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
            let firstViewController = storyboard.instantiateViewControllerWithIdentifier("profile") as! ProfileViewController
            let mainNavigationCtrl = UINavigationController(rootViewController: firstViewController)
            mainNavigationCtrl.navigationBar.barTintColor = UIColor.hex("fffffff", alpha: 1)
            mainNavigationCtrl.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.darkGrayColor()]
            mainNavigationCtrl.navigationBar.tintColor = UIColor.darkGrayColor()
            mainNavigationCtrl.navigationBar.translucent = false
            mainNavigationCtrl.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            mainNavigationCtrl.navigationBar.setBackgroundImage(UIImage(named: "BarBackground"),
                                                                forBarMetrics: .Default)
            mainNavigationCtrl.navigationBar.shadowImage = UIImage()
            
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window?.rootViewController = mainNavigationCtrl
            self.window?.makeKeyAndVisible()
            return
        }
 
        let mapViewController = storyboard.instantiateViewControllerWithIdentifier("map") as! MapViewController

        let mainNavigationCtrl = UINavigationController(rootViewController: mapViewController)
        mainNavigationCtrl.navigationBar.barTintColor = UIColor.hex("fffffff", alpha: 1)
        mainNavigationCtrl.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.darkGrayColor()]
        mainNavigationCtrl.navigationBar.tintColor = UIColor.darkGrayColor()
        mainNavigationCtrl.navigationBar.translucent = false
        mainNavigationCtrl.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        mainNavigationCtrl.navigationBar.setBackgroundImage(UIImage(named: "BarBackground"),
                                                             forBarMetrics: .Default)
        mainNavigationCtrl.navigationBar.shadowImage = UIImage()
        mainNavigationCtrl.tabBarItem = UITabBarItem(title: "ホーム", image: UIImage(named: "home.png"), tag: 1)
   
        let meetupViewController = storyboard.instantiateViewControllerWithIdentifier("meetup") as! MeetupViewController
        
        let meetupNavigationCtrl = UINavigationController(rootViewController: meetupViewController)
        meetupNavigationCtrl.navigationBar.barTintColor = UIColor.hex("fffffff", alpha: 1)
        meetupNavigationCtrl.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.darkGrayColor()]
        meetupNavigationCtrl.navigationBar.tintColor = UIColor.darkGrayColor()
        meetupNavigationCtrl.navigationBar.translucent = false
        meetupNavigationCtrl.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        meetupNavigationCtrl.navigationBar.setBackgroundImage(UIImage(named: "BarBackground"),
                                                                forBarMetrics: .Default)
        meetupNavigationCtrl.navigationBar.shadowImage = UIImage()
        meetupNavigationCtrl.tabBarItem = UITabBarItem(title: "待ち合わせ", image: UIImage(named: "meetup.png"), tag: 2)
        
        let profileViewController = storyboard.instantiateViewControllerWithIdentifier("profile") as! ProfileViewController
        
        let profileNavigationCtrl = UINavigationController(rootViewController: profileViewController)
        profileNavigationCtrl.navigationBar.barTintColor = UIColor.hex("fffffff", alpha: 1)
        profileNavigationCtrl.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.darkGrayColor()]
        profileNavigationCtrl.navigationBar.tintColor = UIColor.darkGrayColor()
        profileNavigationCtrl.navigationBar.translucent = false
        profileNavigationCtrl.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        profileNavigationCtrl.navigationBar.setBackgroundImage(UIImage(named: "BarBackground"),
                                                                forBarMetrics: .Default)
        profileNavigationCtrl.navigationBar.shadowImage = UIImage()
        profileNavigationCtrl.tabBarItem = UITabBarItem(title: "プロフィール", image: UIImage(named: "profile_icon.png"), tag: 3)
        
        
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([mainNavigationCtrl, meetupNavigationCtrl, profileNavigationCtrl], animated: false)
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.addSubview(tabBarController.view)
        self.window?.rootViewController = tabBarController
        self.window?.makeKeyAndVisible()
    }
    
    // REGISTER DEVICE TOKEN
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        
        // remove "<>" and space from deviceToken
        let removingCharacterSet:NSCharacterSet = NSCharacterSet(charactersInString: "<>")
        
        // get device token
        let deviceTokenAsString = (deviceToken.description as NSString).stringByTrimmingCharactersInSet(removingCharacterSet).stringByReplacingOccurrencesOfString(" ", withString: "") as String
        
        print("Device token = \(deviceTokenAsString)")
        
        // save device token to local db
        var userData = PersistentData.User()
        userData.deviceToken = deviceTokenAsString
        
    }
    
    // FAILED TO REGISTER DEVICE TOKEN
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        //print("couldn't register: \(error)")
        print("Registration for remote notification failed with error: \(error.localizedDescription)")
        // [END receive_apns_token_error]
        let userInfo = ["error": error.localizedDescription]
        NSNotificationCenter.defaultCenter().postNotificationName(
            registrationKey, object: nil, userInfo: userInfo)
    }
    
    
    func application( application: UIApplication,
                      didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                                                   fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
        print("Notification receiveda: \(userInfo)")
        
        
        // to do notification off 時の処理を追記
        NSNotificationCenter.defaultCenter().postNotificationName("CognitoPushNotification", object: userInfo)
        handler(UIBackgroundFetchResult.NoData);
        
        // [END_EXCLUDE]
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
 
