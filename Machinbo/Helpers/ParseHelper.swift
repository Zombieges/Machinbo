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
    
    class func launch(_ launchOptions: [AnyHashable: Any]?) {
        
//        let parseAppIdKey = ConfigHelper.getPlistKey("PARSE_APP_ID_KEY") as String
//        let parseClientKey = ConfigHelper.getPlistKey("PARSE_CLIENT_KEY") as String
//        
//        NSLog("★PASER APP KEY = " + parseAppIdKey)
//        NSLog("★PASER CLIENT KEY = " + parseClientKey)
//        
//        Parse.enableLocalDatastore()
//        Parse.setApplicationId(parseAppIdKey, clientKey:parseClientKey)
//        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        let parseAppIdKey = ConfigHelper.getPlistKey("PARSE_APP_ID_KEY") as String
        let parseUrl = ConfigHelper.getPlistKey("PARSE_URL") as String
        let parseClientKey = ConfigHelper.getPlistKey("PARSE_CLIENT_KEY") as String
        
        Parse.initialize(with: ParseClientConfiguration(block: { (configuration: ParseMutableClientConfiguration) -> Void in
            configuration.server = parseUrl
            configuration.clientKey = parseClientKey
            configuration.applicationId = parseAppIdKey
        }))
    }

    class func getNearUserInfomation(_ myLocation: CLLocationCoordinate2D, completion:((_ withError: NSError?, _ result:[PFObject]?)->Void)?) {
        //25km圏内、近くから100件取得
        let myGeoPoint = PFGeoPoint(latitude: myLocation.latitude, longitude: myLocation.longitude)
        
        let query = PFQuery(className: "UserInfo")
        query.whereKey("GPS", nearGeoPoint: myGeoPoint, withinKilometers: 25.0)
        query.whereKey("IsRecruitment", equalTo: true)
        query.limit = 300
        query.order(byAscending: "MarkTime")
        query.findObjectsInBackground { (objects, error) -> Void in
            if let resultNearUser = objects {
                completion?(error as NSError?, resultNearUser)
            }
        }
    }
    
    class func getMyGoNow(_ loginUser: String, completion:((_ withError: NSError?, _ result: PFObject?)->Void)?) {
        let query = PFQuery(className: "GoNow")
        query.whereKey("UserID", equalTo: loginUser)
        query.includeKey("TargetUser")//PointerからUserInfoへリレーション
        query.findObjectsInBackground { (objects, error) -> Void in
            
            if error == nil {
                completion?(error as NSError?, objects!.first)
            }
        }
    }
    
    class func getApprovedMeetupList(_ loginUser: String, completion:((_ withError: NSError?, _ result:[AnyObject]?)->Void)?) {
        let query = PFQuery(className: "GoNow")
        query.whereKey("TargetUserID", equalTo: loginUser)
        query.whereKey("IsApproved", equalTo: true)
        query.includeKey("User")//UserInfoのPointerから情報を取得
        query.order(byDescending: "updatedAt")
        query.findObjectsInBackground { (objects, error) -> Void in
            if error == nil {
                completion?(error as NSError?, objects)
            }
        }
    }
    
    class func getMeetupList(_ loginUser: String, completion:((_ withError: NSError?, _ result:[AnyObject]?)->Void)?) {
        let query = PFQuery(className: "GoNow")
        query.whereKey("TargetUserID", equalTo: loginUser)
        //承認済み
        query.whereKey("IsApproved", equalTo: false)
        query.includeKey("User")//UserInfoのPointerから情報を取得
        query.order(byDescending: "updatedAt")
        query.findObjectsInBackground { (objects, error) -> Void in
            if error == nil {
                completion?(error as NSError?, objects)
            }
        }
    }
    
    class func getUserInfomation(_ userID: String, completion:((_ withError: NSError?, _ result: PFObject?)->Void)?) {
        let query = PFQuery(className: "UserInfo")
        query.whereKey("UserID", equalTo: userID)
        query.findObjectsInBackground { (objects, error) -> Void in
            
            if error == nil {
                completion?(error as NSError?, objects!.first)
            }
        }
    }
    
    class func getUserInfomationFromTwitter(_ twitterName: String, completion:((_ withError: NSError?, _ result: PFObject?)->Void)?) {
        let query = PFQuery(className: "UserInfo")
        query.whereKey("Twitter", equalTo: twitterName)
        query.findObjectsInBackground { (objects, error) -> Void in
            
            if error == nil {
                completion?(error as NSError?, objects!.first)
            }
        }
    }
    
//    class func getActionInfomation(userID: String, completion:((withError: NSError?, result: PFObject?)->Void)?) {
//        
//        let userInfoQuery = PFQuery(className: "UserInfo")
//        userInfoQuery.whereKey("UserID", equalTo: userID)
//        
//        let actionQuery = PFQuery(className: "Action")
//        actionQuery.includeKey("CreatedBy")
//        actionQuery.whereKey("CreatedBy", matchesQuery: userInfoQuery)
//        
//        actionQuery.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
//            if error == nil {
//                //既存のレコードを削除
//                object!.deleteInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in }
//                
//            }
//            
//            completion?(withError: error, result: object)
//        }
//    }
    
    class func setUserInfomation(_ userID: String, name: String, gender: String, age: String, twitter: String, comment: String, photo: PFFile, deviceToken: String) {
        //新規ユーザー登録
        let info = PFObject(className: "UserInfo")
        info["UserID"] = userID
        info["Name"] = name
        info["Gender"] = gender
        info["Age"] = age
        info["Twitter"] = twitter
        info["Comment"] = comment
        info["ProfilePicture"] = photo
        info["DeviceToken"] = deviceToken
        
        info.saveInBackground { (success: Bool, error: Error?) -> Void in
            if success {
                NSLog("ユーザー初期登録成功")
                //UIAlertView.showAlertView("", message: "ユーザ登録が完了しました")
            }
        }
    }
    
    class func setUserName(_ userID: String, name: String) {
        let info = PFObject(className: "UserInfo")
        info["UserID"] = userID
        info["Name"] = name
        
        info.saveInBackground { (success: Bool, error: Error?) -> Void in
            if success {
                NSLog("ユーザー初期登録成功")
            }
        }
    }
    
    class func deleteGoNow(_ targetObjectID: String, completion: @escaping () -> ()) {
        let query = PFQuery(className: "GoNow")
        query.getObjectInBackground(withId: targetObjectID, block: { objects, error in
            if error != nil {
                //NSLog("%@" += error! as! String)
                NSLog(error! as! String)

            } else {
                objects!.deleteInBackground { (success: Bool, error: Error?) -> Void in
                    completion()
                }
            }
        })
    }
    
    class func deleteUserInfo(_ userID: String, completion: @escaping () -> ()) {
        
        ParseHelper.getUserInfomation(userID) { (error: Error?, result: PFObject?) -> Void in
            
            guard let theResult = result else {
                MBProgressHUDHelper.hide()
                //local db の削除
                PersistentData.deleteUserID()
                return
            }
            
            //UserInfoの削除
            theResult.deleteInBackground { (success: Bool, error: Error?) -> Void in
                guard success else {
                    return
                }
                
                //local db の削除
                PersistentData.deleteUserID()
                completion()
            }
        }
    }
    
    class func countUnRead(_ targetObjectID: String, completion:((_ withError: NSError?, _ result: Int?)->Void)?) {
        let query = PFQuery(className: "GoNow")
        query.whereKey("TargetUserID", equalTo: targetObjectID)
        query.whereKey("unReadFlag", equalTo: true)
        query.countObjectsInBackground {
            (number, error) in
            
            if error == nil {
                completion?(error as NSError?, Int(number))
            }
        }
    }
    
    func getErrorMessage(_ error:NSError?) -> String {
        var errorMessage = ""
        if error != nil {
            errorMessage = error!.localizedDescription
            errorMessage.replaceSubrange(errorMessage.startIndex...errorMessage.startIndex, with: String(errorMessage[errorMessage.startIndex]).capitalized)
        } else {
            errorMessage = "Unexpected error occured. Please try again"
        }
        return errorMessage
    }
}
