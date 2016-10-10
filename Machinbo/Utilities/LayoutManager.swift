//
//  LayoutManager.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2015/08/13.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import UIKit

class LayoutManager {
    
    class func getUIColorFromRGB(rgbValue: UInt) -> UIColor {
        //RGB値からUIColorを生成
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    class func createNavigationAndTabItems() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard PersistentData.User().userID != "" else {
            let firstViewController = storyboard.instantiateViewControllerWithIdentifier("profile") as! ProfileViewController
            let mainNavigationCtrl = UINavigationController(rootViewController: firstViewController)
            mainNavigationCtrl.navigationBar.barTintColor = UIColor.hex("fffffff", alpha: 1)
            mainNavigationCtrl.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
            mainNavigationCtrl.navigationBar.tintColor = UIColor.darkGrayColor()
            mainNavigationCtrl.navigationBar.translucent = false
            mainNavigationCtrl.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            mainNavigationCtrl.navigationBar.setBackgroundImage(UIImage(named: "BarBackground"),
                                                                forBarMetrics: .Default)
            mainNavigationCtrl.navigationBar.shadowImage = UIImage()
            //UIApplication.sharedApplication().keyWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
            //self.window?.addSubview(tabBarController.view)
            UIApplication.sharedApplication().keyWindow?.rootViewController = mainNavigationCtrl
            UIApplication.sharedApplication().keyWindow?.makeKeyAndVisible()
            return
        }
        
        let mapViewController = storyboard.instantiateViewControllerWithIdentifier("map") as! MapViewController
        
        let mainNavigationCtrl = UINavigationController(rootViewController: mapViewController)
        mainNavigationCtrl.navigationBar.barTintColor = UIColor.hex("fffffff", alpha: 1)
        mainNavigationCtrl.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
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
        meetupNavigationCtrl.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
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
        profileNavigationCtrl.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        profileNavigationCtrl.navigationBar.tintColor = UIColor.darkGrayColor()
        profileNavigationCtrl.navigationBar.translucent = false
        profileNavigationCtrl.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        profileNavigationCtrl.navigationBar.setBackgroundImage(UIImage(named: "BarBackground"),
                                                               forBarMetrics: .Default)
        profileNavigationCtrl.navigationBar.shadowImage = UIImage()
        profileNavigationCtrl.tabBarItem = UITabBarItem(title: "プロフィール", image: UIImage(named: "profile_icon.png"), tag: 3)
        
        
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([mainNavigationCtrl, meetupNavigationCtrl, profileNavigationCtrl], animated: false)
        
        //self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        UIApplication.sharedApplication().keyWindow?.addSubview(tabBarController.view)
        UIApplication.sharedApplication().keyWindow?.rootViewController = tabBarController
        UIApplication.sharedApplication().keyWindow?.makeKeyAndVisible()
    }
}

//UIColorのextensionとして登録しておく
extension UIColor {
    class func hex (var hexStr : NSString, alpha : CGFloat) -> UIColor {
        hexStr = hexStr.stringByReplacingOccurrencesOfString("#", withString: "")
        let scanner = NSScanner(string: hexStr as String)
        var color: UInt32 = 0
        if scanner.scanHexInt(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            print("invalid hex string", terminator: "")
            return UIColor.whiteColor();
        }
    }
}