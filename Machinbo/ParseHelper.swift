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
        //50km圏内、近くから100件取得
        var myGeoPoint = PFGeoPoint(latitude: myLocation.latitude, longitude: myLocation.longitude)
        
        var query = PFQuery(className: "UserInfo")
        query.whereKey("GPS", nearGeoPoint: myGeoPoint, withinKilometers: 50.0)
        query.limit = 100
        return query.findObjects() as! [PFObject]
    }
    
    class func setUserInfomation(userID: String) {
        //新規ユーザー登録
        let info = PFObject(className: "UserInfo")
        info["UserID"] = userID
        info["Name"] = ""
        info["Gender"] = 0
        info["Age"] = ""
        info["Comment"] = ""
        info["GPS"] = nil
        info["MarkTime"] = nil
        info.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            NSLog("ユーザー初期登録成功")
        }
    }
}