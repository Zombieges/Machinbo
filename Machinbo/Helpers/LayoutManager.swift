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
    
    let displayWidth: CGFloat = UIScreen.main.bounds.size.width
    
    class func getUIColorFromRGB(_ rgbValue: UInt, alpha: CGFloat = 1.0) -> UIColor {
        //RGB値からUIColorを生成
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    class func createNavigationProfile() -> UINavigationController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let firstViewController = storyboard.instantiateViewController(withIdentifier: "profile") as! ProfileViewController
        let mainNavigationCtrl = UINavigationController(rootViewController: firstViewController)
        mainNavigationCtrl.navigationBar.barTintColor = UIColor.hex("fffffff", alpha: 1)
        mainNavigationCtrl.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        mainNavigationCtrl.navigationBar.tintColor = UIColor.darkGray
        mainNavigationCtrl.navigationBar.isTranslucent = false
        mainNavigationCtrl.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        mainNavigationCtrl.navigationBar.setBackgroundImage(UIImage(named: "BarBackground"),
                                                            for: .default)
        mainNavigationCtrl.navigationBar.shadowImage = UIImage()
        
        return mainNavigationCtrl
    }
    
    class func createNavigationAndTabItems() -> UITabBarController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
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
        tabBarController.tabBar.isTranslucent = false
        
        return tabBarController
    }
}

//UIColorのextensionとして登録しておく
extension UIColor {
    class func hex (_ hexStr : NSString, alpha : CGFloat) -> UIColor {
        var hexStr = hexStr
        hexStr = hexStr.replacingOccurrences(of: "#", with: "") as NSString
        let scanner = Scanner(string: hexStr as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            print("invalid hex string", terminator: "")
            return UIColor.white;
        }
    }
}
