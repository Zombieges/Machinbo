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
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.removeObjectForKey("userID")
        userDefault.removeObjectForKey("imaikuFlag")
        
        userDefault.removeObjectForKey("insertTime")
        userDefault.removeObjectForKey("place")
        userDefault.removeObjectForKey("mychar")
        
        userDefault.synchronize()
        
    }
    
    class func deleteUserIDForKey(id: String) {
        // 保存データを全削除
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.removeObjectForKey(id)
        
        userDefault.synchronize()
        
    }
    
    struct User {
        
        var userID : String {
            get {
                return NSUserDefaults.standardUserDefaults().stringForKey("userID") ?? ""
            }
            set {
                NSUserDefaults.standardUserDefaults().setObject(newValue , forKey: "userID")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        
        var profileImage : UIImage {
            get {
                if NSUserDefaults.standardUserDefaults().objectForKey("profileImage") != nil {
                    return UIImage(data: NSUserDefaults.standardUserDefaults().objectForKey("profileImage") as! NSData)!
                    
                } else {
                    return UIImage(named: "photo.png")!
                }
            }
            set{
                let imageData = UIImagePNGRepresentation(newValue)
                //var myEncodedImageData = NSKeyedArchiver.archivedDataWithRootObject(imageData)
                NSUserDefaults.standardUserDefaults().setObject(imageData, forKey: "profileImage")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        var comment : String {
            get {
                return NSUserDefaults.standardUserDefaults().stringForKey("comment") ?? ""
            }
            set {
                NSUserDefaults.standardUserDefaults().setObject(newValue , forKey: "comment")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        var gender : String {
            get {
                return NSUserDefaults.standardUserDefaults().stringForKey("gender") ?? ""
            }
            set {
                NSUserDefaults.standardUserDefaults().setObject(newValue , forKey: "gender")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        var name : String {
            get {
                return NSUserDefaults.standardUserDefaults().stringForKey("name") ?? ""
            }
            set {
                NSUserDefaults.standardUserDefaults().setObject(newValue , forKey: "name")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        var age : String {
            get {
                return NSUserDefaults.standardUserDefaults().stringForKey("age") ?? ""
            }
            set {
                NSUserDefaults.standardUserDefaults().setObject(newValue , forKey: "age")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        var insertTime : String {
            get {
                return NSUserDefaults.standardUserDefaults().stringForKey("insertTime") ?? ""
            }
            set {
                NSUserDefaults.standardUserDefaults().setObject(newValue , forKey: "insertTime")
                NSUserDefaults.standardUserDefaults().synchronize() 
            }
        }
        var place : String {
            get {
                return NSUserDefaults.standardUserDefaults().stringForKey("place") ?? ""
            }
            set {
                NSUserDefaults.standardUserDefaults().setObject(newValue , forKey: "place")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        var mychar : String {
            get {
                return NSUserDefaults.standardUserDefaults().stringForKey("mychar") ?? ""
            }
            set {
                NSUserDefaults.standardUserDefaults().setObject(newValue , forKey: "mychar")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        var imaikuFlag: Bool {
            get {
                return NSUserDefaults.standardUserDefaults().boolForKey("imaikuFlag") ?? false
            }
            set {
                NSUserDefaults.standardUserDefaults().setBool(newValue , forKey: "imaikuFlag")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        
        var location: Bool {
            get {
                return NSUserDefaults.standardUserDefaults().boolForKey("location") ?? false
            }
            set {
                NSUserDefaults.standardUserDefaults().setBool(newValue , forKey: "location")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        
        var isRecruitment: Bool {
            get {
                return NSUserDefaults.standardUserDefaults().boolForKey("isRecruitment") ?? false
            }
            set {
                NSUserDefaults.standardUserDefaults().setBool(newValue , forKey: "isRecruitment")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
}