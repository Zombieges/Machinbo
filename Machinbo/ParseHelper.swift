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
    
    class func getNearUserInfomation(myLocation: CLLocationCoordinate2D, completion:((withError: NSError?, result:[AnyObject]?)->Void)?) {
        //50km圏内、近くから100件取得
        let myGeoPoint = PFGeoPoint(latitude: myLocation.latitude, longitude: myLocation.longitude)
        
        let query = PFQuery(className: "Action")
        query.whereKey("GPS", nearGeoPoint: myGeoPoint, withinKilometers: 50.0)
        query.limit = 100
        query.includeKey("CreatedBy")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                completion?(withError: error, result: objects)
                
            }
        }
        
        //return query.findObjects() as! [PFObject]
    }
    
    class func getGoNowMe(loginUser: String, completion:((withError: NSError?, result:[AnyObject]?)->Void)?) {
        let query = PFQuery(className: "GoNow")
        query.whereKey("UserID", containsString: loginUser)
        query.includeKey("TargetUser.CreatedBy")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                completion?(withError: error, result: objects)
            }
        }
    }
    
    class func setUserInfomation(userID: String,name: String,gender: Int,age: String,comment: String,photo: PFFile) {
        //新規ユーザー登録
        let info = PFObject(className: "UserInfo")
        info["UserID"] = userID
        info["Name"] = name
        info["Gender"] = gender
        info["Age"] = age
        info["Comment"] = comment
        info["ProfilePicture"] = photo
        //info["GPS"] = ""
        //info["MarkTime"] = ""
        info.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                NSLog("ユーザー初期登録成功")
            }
        }
    }
    
    func getErrorMessage(error:NSError?) -> String {
        var errorMessage = ""
        if error != nil {
            errorMessage = error!.localizedDescription
            errorMessage.replaceRange(errorMessage.startIndex...errorMessage.startIndex, with: String(errorMessage[errorMessage.startIndex]).capitalizedString)
        } else {
            errorMessage = "Unexpected error occured. Please try again"
        }
        return errorMessage
    }
}