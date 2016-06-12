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
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        /*
        登録済みか否かをチェック
        */
        //PersistentData.deleteUserID()
        let firstViewController: UIViewController
        if PersistentData.User().userID == "" {
            firstViewController = storyboard.instantiateViewControllerWithIdentifier("profile") as! ProfileViewController
            
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            firstViewController = storyboard.instantiateInitialViewController() as UIViewController!
        }
        
        mainNavigationCtrl = UINavigationController(rootViewController: firstViewController)
        //#303F9F
        
        //TODO:背景色を白にする
        mainNavigationCtrl!.navigationBar.barTintColor = UIColor.hex("2F469C", alpha: 1)
        mainNavigationCtrl!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        mainNavigationCtrl!.navigationBar.tintColor = UIColor.whiteColor()
        mainNavigationCtrl!.navigationBar.translucent = false
        mainNavigationCtrl!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        mainNavigationCtrl!.navigationBar.shadowImage = UIImage()
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = mainNavigationCtrl
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func cycleTheGlobalMailComposer() {
        
    }
    
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ){
        
        // Sets up the AWS Mobile SDK for iOS
        let removingCharacterSet:NSCharacterSet = NSCharacterSet(charactersInString: "<>")
        
        let deviceTokenAsString:String = (deviceToken.description as NSString).stringByTrimmingCharactersInSet(removingCharacterSet).stringByReplacingOccurrencesOfString(" ", withString: "") as String
        
        print("Device token = \(deviceTokenAsString)")
        
        //
        // SET UP AWS CONGNITO
        //
        let poolId = ConfigHelper.getPlistKey("AWS_CONGNITO") as String
        let awsCredentialsProvider = AWSCognitoCredentialsProvider(regionType: .APNortheast1, identityPoolId: poolId)
        
        let defaultAwsServiceConfiguration = AWSServiceConfiguration(region: .APNortheast1, credentialsProvider: awsCredentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultAwsServiceConfiguration
        
        //
        // AWS SNS
        //
        let sns = AWSSNS.defaultSNS()
        let snsRequest = AWSSNSCreatePlatformEndpointInput()
        snsRequest.token = deviceTokenAsString
        snsRequest.platformApplicationArn = ConfigHelper.getPlistKey("AWS_SNS") as String
        sns.createPlatformEndpoint(snsRequest) { (AwsSnsEndPoint:AWSSNSCreateEndpointResponse?, error:NSError?) in
            if error != nil {
                print("Failed to create SNS endpoint:\(error?.description)")
            } else {
                if let createdSnsEndpoint = AwsSnsEndPoint {
                    print("created Endpoint is \(createdSnsEndpoint.endpointArn)")
                }
            }
        }
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
 
