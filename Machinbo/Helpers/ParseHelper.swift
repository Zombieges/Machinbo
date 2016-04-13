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
    
    class func getNearUserInfomation(myLocation: CLLocationCoordinate2D, completion:((withError: NSError?, result:[PFObject]?)->Void)?) {
        //25km圏内、近くから100件取得
        let myGeoPoint = PFGeoPoint(latitude: myLocation.latitude, longitude: myLocation.longitude)
        
        let query = PFQuery(className: "Action")
        query.whereKey("GPS", nearGeoPoint: myGeoPoint, withinKilometers: 25.0)
        query.limit = 300
        query.includeKey("CreatedBy")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let resultNearUser = objects as! [PFObject]
                completion?(withError: error, result: resultNearUser)
                
            }
        }
    }
    
    class func getMyGoNow(loginUser: String, completion:((withError: NSError?, result: PFObject?)->Void)?) {
        let query = PFQuery(className: "GoNow")
        query.whereKey("UserID", containsString: loginUser)
        query.includeKey("TargetUser.CreatedBy")//ActionのPointerからUserInfoへリレーション
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let object = objects!.first as? PFObject
                completion?(withError: error, result: object)
            }
        }
    }
    
    class func getGoNowMeList(loginUser: String, completion:((withError: NSError?, result:[AnyObject]?)->Void)?) {
        let query = PFQuery(className: "GoNow")
        query.whereKey("TargetUserID", containsString: loginUser)
        query.includeKey("User")//UserInfoのPointerから情報を取得
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                completion?(withError: error, result: objects)
            }
        }
    }
    
    class func getUserInfomation(userID: String, completion:((withError: NSError?, result: PFObject?)->Void)?) {
        let query = PFQuery(className: "UserInfo")
        query.whereKey("UserID", containsString: userID)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                let object = objects!.first as? PFObject
                completion?(withError: error, result: object)
            }
        }
    }
    
    class func getActionInfomation(userID: String, completion:((withError: NSError?, result: PFObject?)->Void)?) {
        
        let userInfoQuery = PFQuery(className: "UserInfo")
        userInfoQuery.whereKey("UserID", containsString: userID)
        
        let actionQuery = PFQuery(className: "Action")
        actionQuery.includeKey("CreatedBy")
        actionQuery.whereKey("CreatedBy", matchesQuery: userInfoQuery)
        
        actionQuery.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            if error == nil {
                //既存のレコードを削除
                object!.deleteInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        //
                        NSLog("削除しました！")
                        
                    } else {
                        // handle error
                    }
                }
                
                completion?(withError: error, result: object)
            }
        }
    }
    
    class func setUserInfomation(userID: String, name: String, gender: String, age: String, comment: String, photo: PFFile) {
        //新規ユーザー登録
        let info = PFObject(className: "UserInfo")
        info["UserID"] = userID
        info["Name"] = name
        info["Gender"] = gender
        info["Age"] = age
        info["Comment"] = comment
        info["ProfilePicture"] = photo
        
        info.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                NSLog("ユーザー初期登録成功")
            }
        }
    }
    
    class func setUserName(userID: String, name: String) {
        let info = PFObject(className: "UserInfo")
        info["UserID"] = userID
        info["Name"] = name
        
        info.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                NSLog("ユーザー初期登録成功")
            }
        }
    }
    
    class func deleteGoNow(targetObjectID: String, completion: () -> ()) {
        let query = PFQuery(className: "GoNow")
        query.getObjectInBackgroundWithId(targetObjectID, block: { objects, error in
            if error != nil {
                NSLog("%@", error!)
            } else {
                objects!.deleteInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    completion()
                }
            }
        })
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