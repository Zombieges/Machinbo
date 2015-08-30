//
//  ParseHelper.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2015/08/02.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import Parse

class ParseHelper {
    
    class func launch(launchOptions: [NSObject: AnyObject]?) {
        
        let parseAppIdKey = ConfigHelper.getPlistKey("PARSE_APP_ID_KEY") as String
        let parseClientKey = ConfigHelper.getPlistKey("PARSE_CLIENT_KEY") as String
        
        NSLog("★PASER APP KEY = " + parseAppIdKey)
        NSLog("★PASER CLIENT KEY = " + parseClientKey)
        
        Parse.enableLocalDatastore()
        Parse.setApplicationId(parseAppIdKey, clientKey:parseClientKey)
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        //UserInfo Search
        var query = PFQuery(className: "UserInfo")
        query.whereKey("UserID", containsString: "015CD7AC-F749-479E-B350-B1C41A832EED")
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

    }
    
    /*class func getUserInfo(userID:String) -> PFObject {
        var query = PFQuery(className: "UserInfo")
        query.whereKey("UserID", containsString: userID)
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let object = objects?.first {
                    return object as! PFObject
                }
                
            } else {
                return PFObject()
            }
        }
    }*/
    
    class func getNearUserInfomation(myLocation: CLLocationCoordinate2D) -> [PFObject] {
        var myGeoPoint = PFGeoPoint(latitude: myLocation.latitude, longitude: myLocation.longitude)
        
        var query = PFQuery(className: "UserInfo")
        query.whereKey("GPS", nearGeoPoint: myGeoPoint, withinKilometers: 50.0)
        query.limit = 100
        return query.findObjects() as! [PFObject]
    }
}