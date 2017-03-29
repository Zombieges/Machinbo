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
        
        let parseAppIdKey = ConfigData(type: .parseApp).getPlistKey
        let parseUrl = ConfigData(type: .parseURL).getPlistKey
        let parseClientKey = ConfigData(type: .parseClient).getPlistKey
        
        Parse.initialize(with: ParseClientConfiguration(block: { (configuration: ParseMutableClientConfiguration) -> Void in
            configuration.server = parseUrl
            configuration.clientKey = parseClientKey
            configuration.applicationId = parseAppIdKey
        }))
    }
    
    class func getNearUserInfomation(_ myLocation: CLLocationCoordinate2D, completion:((_ withError: NSError?, _ result:[PFObject]?)->Void)?) {
        //50km圏内、近くから300件取得
        let myGeoPoint = PFGeoPoint(latitude: myLocation.latitude, longitude: myLocation.longitude)
        let now = Date()
        
        print("*************************>")
        print(PersistentData.blockUserList)
        let query = PFQuery(className: "UserInfo")
        query.whereKey("GPS", nearGeoPoint: myGeoPoint, withinKilometers: 25.0)
        query.whereKey("IsRecruitment", equalTo: true)
        query.whereKey("MarkTimeTo", greaterThanOrEqualTo: now)
        query.whereKey("MarkTime", lessThanOrEqualTo: now)
        query.whereKey("objectId", notContainedIn: PersistentData.blockUserList)
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
    
    class func createUserInfomation(_ userID: String, name: String, gender: String, age: String, twitter: String, comment: String, photo: UIImage, deviceToken: String) {
        
        let imageData = UIImagePNGRepresentation(photo)
        let imageFile = PFFile(name:"image.png", data:imageData!)
        
        //新規ユーザー登録
        let info = PFObject(className: "UserInfo")
        info["UserID"] = userID
        info["Name"] = name
        info["Gender"] = gender
        info["Age"] = age
        info["Twitter"] = twitter
        info["Comment"] = comment
        info["ProfilePicture"] = imageFile
        info["DeviceToken"] = deviceToken
        
        info.saveInBackground { (success: Bool, error: Error?) -> Void in
            defer {
                MBProgressHUDHelper.sharedInstance.hide()
            }
            
            guard success, error == nil else {
                UIAlertController.showAlertParseConnectionError()
                return
            }
            
            NSLog("ユーザー初期登録成功")
            PersistentData.userID = userID
            PersistentData.name = name
            PersistentData.gender = gender
            PersistentData.age = age
            PersistentData.comment = comment
            PersistentData.twitterName = twitter
            PersistentData.profileImage = photo
            PersistentData.objectId = info.objectId!
            
            let tabBarConrtoller: UITabBarController = LayoutManager.createNavigationAndTabItems()
            UIApplication.shared.keyWindow?.addSubview((tabBarConrtoller.view)!)
            UIApplication.shared.keyWindow?.rootViewController = tabBarConrtoller
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
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
            
            if let result = result {
                //UserInfoの削除
                result.deleteInBackground { (success: Bool, error: Error?) -> Void in
                    guard success else {
                        return
                    }
                    
                    //local db の削除
                    PersistentData().deleteUserID()
                    completion()
                }
                
            } else {
                MBProgressHUDHelper.sharedInstance.hide()
                //local db の削除
                PersistentData().deleteUserID()
                
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
}
