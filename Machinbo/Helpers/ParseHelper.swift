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
    //50km圏内、近くから300件取得
    let myGeoPoint = PFGeoPoint(latitude: myLocation.latitude, longitude: myLocation.longitude)
    
    var data = PersistentData.User()
    print("*************************>")
    print(data.blockUserList)
    let query = PFQuery(className: "UserInfo")
    query.whereKey("GPS", nearGeoPoint: myGeoPoint, withinKilometers: 25.0)
    query.whereKey("IsRecruitment", equalTo: true)
    query.whereKey("objectId", notContainedIn: data.blockUserList)
    query.limit = 100
    query.order(byAscending: "MarkTime")
    query.findObjectsInBackground { (objects, error) -> Void in
        if let resultNearUser = objects {
            completion?(error as NSError?, resultNearUser)
        }
    }
}

class func getTargetUserGoNow(_ objectId: String, completion:((_ withError: NSError?, _ result: PFObject?)->Void)?) {
    let query = PFQuery(className: "GoNow")
    query.whereKey("objectId", equalTo:objectId)
    query.includeKey("userGoNow")
    query.includeKey("targetGoNow")
    query.includeKey("User")
    query.includeKey("TargetUser")
    query.findObjectsInBackground { (objects, error) -> Void in
        if error == nil {
            completion?(error as NSError?, objects!.first)
        }
    }
}

class func getApprovedMeetupList(_ loginUser: String, completion:((_ withError: NSError?, _ result:[AnyObject]?)->Void)?) {
    
    let userQuery = PFQuery(className: "GoNow")
    userQuery.whereKey("UserID", equalTo: loginUser)
    userQuery.whereKey("IsApproved", equalTo: true)
    userQuery.whereKey("isDeleteUser", equalTo: false)
    
    
    let targetUserQuery = PFQuery(className: "GoNow")
    targetUserQuery.whereKey("TargetUserID", equalTo: loginUser)
    targetUserQuery.whereKey("IsApproved", equalTo: true)
    targetUserQuery.whereKey("isDeleteTarget", equalTo: false)
    
    let joinQuery = PFQuery.orQuery(withSubqueries: [userQuery, targetUserQuery])
    joinQuery.includeKey("User")//UserInfoのPointerから情報を取得
    joinQuery.includeKey("TargetUser")
    joinQuery.includeKey("userGoNow")
    joinQuery.includeKey("targetGoNow")
    joinQuery.order(byDescending: "updatedAt")
    joinQuery.findObjectsInBackground { (objects, error) -> Void in
        if error == nil {
            completion?(error as NSError?, objects)
        }
    }
}

class func getMeetupList(_ loginUser: String, completion:((_ withError: NSError?, _ result:[AnyObject]?)->Void)?) {
    
    let query = PFQuery(className: "GoNow")
    query.whereKey("UserID", equalTo: loginUser)
    query.whereKey("IsApproved", equalTo: false)//承認済みのユーザは除外
    query.whereKey("isDeleteUser", equalTo: false)//自分で削除したユーザは除外
    query.includeKey("TargetUser")
    query.includeKey("targetGoNow")
    query.order(byDescending: "updatedAt")
    //        let targetUserQuery = PFQuery(className: "GoNow")
    //        targetUserQuery.whereKey("TargetUserID", equalTo: loginUser)
    //        targetUserQuery.whereKey("IsApproved", equalTo: false)
    
    //        let joinQuery = PFQuery.orQuery(withSubqueries: [userQuery, targetUserQuery])
    //        joinQuery.includeKey("User")//UserInfoのPointerから情報を取得
    //        joinQuery.order(byDescending: "updatedAt")
    query.findObjectsInBackground { (objects, error) -> Void in
        if error == nil {
            completion?(error as NSError?, objects)
        }
    }
}

class func getReceiveList(_ loginUser: String, completion:((_ withError: NSError?, _ result:[AnyObject]?)->Void)?) {
    
    let query = PFQuery(className: "GoNow")
    query.whereKey("TargetUserID", equalTo: loginUser)
    query.whereKey("IsApproved", equalTo: false)//承認したユーザは除外
    query.whereKey("isDeleteTarget", equalTo: false)//自分で削除したユーザは除外
    query.includeKey("User")
    query.includeKey("userGoNow")
    query.order(byDescending: "updatedAt")
    query.findObjectsInBackground { (objects, error) -> Void in
        if error == nil {
            completion?(error as NSError?, objects)
        }
    }
}

class func getMyUserInfomation(_ userID: String, completion:((_ withError: NSError?, _ result: PFObject?)->Void)?) {
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
    query.whereKey("IsRecruitment", equalTo: true)
    query.findObjectsInBackground { (objects, error) -> Void in
        
        if error == nil {
            completion?(error as NSError?, objects!.first)
        }
    }
}

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
            var user = PersistentData.User()
            user.objectId = info.objectId!
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
            NSLog(error! as! String)
            
        } else {
            objects!.deleteInBackground { (success: Bool, error: Error?) -> Void in
                completion()
            }
        }
    })
}

class func deleteUserInfo(_ userID: String, completion: @escaping () -> ()) {
    
    ParseHelper.getMyUserInfomation(userID) { (error: Error?, result: PFObject?) -> Void in
        
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

class func updApproved(id: String, completion:((_ withError: NSError?, _ result: Int?)->Void)?) {
    
}
}
