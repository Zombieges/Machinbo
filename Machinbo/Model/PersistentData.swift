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
    
    static var objectId : String {
        get {
            return UserDefaults.standard.string(forKey: "objectId") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue , forKey: "objectId")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var userID : String {
        get {
            return UserDefaults.standard.string(forKey: "userID") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue , forKey: "userID")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var profileImage : UIImage {
        get {
            if UserDefaults.standard.object(forKey: "profileImage") != nil {
                return UIImage(data: UserDefaults.standard.object(forKey: "profileImage") as! Data)!
                
            } else {
                return UIImage(named: "photo.png")!
            }
        }
        set{
            let imageData = UIImagePNGRepresentation(newValue)
            UserDefaults.standard.set(imageData, forKey: "profileImage")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var comment : String {
        get {
            return UserDefaults.standard.string(forKey: "comment") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue , forKey: "comment")
            UserDefaults.standard.synchronize()
        }
    }

    static var name : String {
        get {
            return UserDefaults.standard.string(forKey: "name") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue , forKey: "name")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var markTimeFrom : String {
        get {
            return UserDefaults.standard.string(forKey: "markTimeFrom") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue , forKey: "markTimeFrom")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var markTimeTo : String {
        get {
            return UserDefaults.standard.string(forKey: "markTimeTo") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue , forKey: "markTimeTo")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var place : String {
        get {
            return UserDefaults.standard.string(forKey: "place") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue , forKey: "place")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var mychar : String {
        get {
            return UserDefaults.standard.string(forKey: "mychar") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue , forKey: "mychar")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var imaikuFlag: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "imaikuFlag")
        }
        set {
            UserDefaults.standard.set(newValue , forKey: "imaikuFlag")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var location: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "location")
        }
        set {
            UserDefaults.standard.set(newValue , forKey: "location")
            UserDefaults.standard.synchronize()
        }
    }
    
   static  var isRecruitment: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: "isRecruitment")
        }
        set {
            UserDefaults.standard.set(newValue!, forKey: "isRecruitment")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var deviceToken: String {
        get {
            return UserDefaults.standard.string(forKey: "deviceToken") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue , forKey: "deviceToken")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var targetUserID : String {
        get {
            return UserDefaults.standard.string(forKey: "targetUserID") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue , forKey: "targetUserID")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var twitterName : String {
        get {
            return UserDefaults.standard.string(forKey: "twitterName") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue , forKey: "twitterName")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var blockUserList: [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: "blockUserList") ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "blockUserList")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var imaikuUserList: [String:Date] {
        get {
            return UserDefaults.standard.dictionary(forKey: "imaikuUserList") as! [String : Date]? ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "imaikuUserList")
            UserDefaults.standard.synchronize()
        }
    }
    
    //約束を一日一回に限定するプロパティ
    static var isImaikuClick: Date? {
        get {
            return UserDefaults.standard.object(forKey: "isImaikuClick") as! Date?
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isImaikuClick")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var AWSSNSEndpoint: String {
        get {
            return UserDefaults.standard.string(forKey: "awsSNSEndpoint") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue , forKey: "awsSNSEndpoint")
            UserDefaults.standard.synchronize()
        }
    }
    
    func deleteUserID() {
        // 保存データを全削除
        let userDefault = UserDefaults.standard
        
        userDefault.removeObject(forKey: "objectId")
        userDefault.removeObject(forKey: "userID")
        userDefault.removeObject(forKey: "profileImage")
        userDefault.removeObject(forKey: "comment")
        userDefault.removeObject(forKey: "name")
        userDefault.removeObject(forKey: "imaikuFlag")
        
        userDefault.removeObject(forKey: "insertTime")
        userDefault.removeObject(forKey: "place")
        userDefault.removeObject(forKey: "mychar")
        userDefault.removeObject(forKey: "location")
        
        userDefault.removeObject(forKey: "isRecruitment")
        userDefault.removeObject(forKey: "deviceToken")
        userDefault.removeObject(forKey: "targetUserID")
        userDefault.removeObject(forKey: "twitterName")
        userDefault.removeObject(forKey: "blockUserList")
        userDefault.removeObject(forKey: "imaikuUserList")
        
        userDefault.removeObject(forKey: "markTimeFrom")
        userDefault.removeObject(forKey: "markTimeTo")
        userDefault.removeObject(forKey: "isImaikuClick")
        
        userDefault.removeObject(forKey: "awsSNSEndpoint")
        
        userDefault.synchronize()
    }
    
    func deleteUserIDForKey(_ id: String) {
        // 保存データを全削除
        let userDefault = UserDefaults.standard
        userDefault.removeObject(forKey: id)
        
        userDefault.synchronize()
        
    }
}
