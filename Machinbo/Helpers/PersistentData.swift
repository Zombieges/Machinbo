//
//  PersistentData.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2015/08/13.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import UIKit

class PersistentData {
    
    class func deleteUserID() {
        // 保存データを全削除
        let userDefault = UserDefaults.standard
        userDefault.removeObject(forKey: "userID")
        userDefault.removeObject(forKey: "profileImage")
        userDefault.removeObject(forKey: "comment")
        userDefault.removeObject(forKey: "gender")
        userDefault.removeObject(forKey: "name")
        userDefault.removeObject(forKey: "age")
        userDefault.removeObject(forKey: "imaikuFlag")
        
        userDefault.removeObject(forKey: "insertTime")
        userDefault.removeObject(forKey: "place")
        userDefault.removeObject(forKey: "mychar")
        userDefault.removeObject(forKey: "location")
        
        userDefault.removeObject(forKey: "isRecruitment")
        userDefault.removeObject(forKey: "deviceToken")
        userDefault.removeObject(forKey: "targetUserID")
        userDefault.removeObject(forKey: "twitterName")
        
        userDefault.synchronize()
        
    }
    
    class func deleteUserIDForKey(_ id: String) {
        // 保存データを全削除
        let userDefault = UserDefaults.standard
        userDefault.removeObject(forKey: id)
        
        userDefault.synchronize()
        
    }
    
    struct User {
        
        var userID : String {
            get {
                return UserDefaults.standard.string(forKey: "userID") ?? ""
            }
            set {
                UserDefaults.standard.set(newValue , forKey: "userID")
                UserDefaults.standard.synchronize()
            }
        }
        
        var profileImage : UIImage {
            get {
                if UserDefaults.standard.object(forKey: "profileImage") != nil {
                    return UIImage(data: UserDefaults.standard.object(forKey: "profileImage") as! Data)!
                    
                } else {
                    return UIImage(named: "photo.png")!
                }
            }
            set{
                let imageData = UIImagePNGRepresentation(newValue)
                //var myEncodedImageData = NSKeyedArchiver.archivedDataWithRootObject(imageData)
                UserDefaults.standard.set(imageData, forKey: "profileImage")
                UserDefaults.standard.synchronize()
            }
        }
        var comment : String {
            get {
                return UserDefaults.standard.string(forKey: "comment") ?? ""
            }
            set {
                UserDefaults.standard.set(newValue , forKey: "comment")
                UserDefaults.standard.synchronize()
            }
        }
        var gender : String {
            get {
                return UserDefaults.standard.string(forKey: "gender") ?? ""
            }
            set {
                UserDefaults.standard.set(newValue , forKey: "gender")
                UserDefaults.standard.synchronize()
            }
        }
        var name : String {
            get {
                return UserDefaults.standard.string(forKey: "name") ?? ""
            }
            set {
                UserDefaults.standard.set(newValue , forKey: "name")
                UserDefaults.standard.synchronize()
            }
        }
        var age : String {
            get {
                return UserDefaults.standard.string(forKey: "age") ?? ""
            }
            set {
                UserDefaults.standard.set(newValue , forKey: "age")
                UserDefaults.standard.synchronize()
            }
        }
        var insertTime : String {
            get {
                return UserDefaults.standard.string(forKey: "insertTime") ?? ""
            }
            set {
                UserDefaults.standard.set(newValue , forKey: "insertTime")
                UserDefaults.standard.synchronize() 
            }
        }
        var place : String {
            get {
                return UserDefaults.standard.string(forKey: "place") ?? ""
            }
            set {
                UserDefaults.standard.set(newValue , forKey: "place")
                UserDefaults.standard.synchronize()
            }
        }
        var mychar : String {
            get {
                return UserDefaults.standard.string(forKey: "mychar") ?? ""
            }
            set {
                UserDefaults.standard.set(newValue , forKey: "mychar")
                UserDefaults.standard.synchronize()
            }
        }
        var imaikuFlag: Bool {
            get {
                return UserDefaults.standard.bool(forKey: "imaikuFlag") 
            }
            set {
                UserDefaults.standard.set(newValue , forKey: "imaikuFlag")
                UserDefaults.standard.synchronize()
            }
        }
        
        var location: Bool {
            get {
                return UserDefaults.standard.bool(forKey: "location") 
            }
            set {
                UserDefaults.standard.set(newValue , forKey: "location")
                UserDefaults.standard.synchronize()
            }
        }
        
        var isRecruitment: Bool? {
            get {
                return UserDefaults.standard.bool(forKey: "isRecruitment")
            }
            set {
                UserDefaults.standard.set(newValue!, forKey: "isRecruitment")
                UserDefaults.standard.synchronize()
            }
        }
        
        var deviceToken: String {
            get {
                return UserDefaults.standard.string(forKey: "deviceToken") ?? ""
            }
            set {
                UserDefaults.standard.set(newValue , forKey: "deviceToken")
                UserDefaults.standard.synchronize()
            }
        }
        var targetUserID : String {
            get {
                return UserDefaults.standard.string(forKey: "targetUserID") ?? ""
            }
            set {
                UserDefaults.standard.set(newValue , forKey: "targetUserID")
                UserDefaults.standard.synchronize()
            }
        }
        var twitterName : String {
            get {
                return UserDefaults.standard.string(forKey: "twitterName") ?? ""
            }
            set {
                UserDefaults.standard.set(newValue , forKey: "twitterName")
                UserDefaults.standard.synchronize()
            }
        }
    }
}
