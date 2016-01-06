//
//  PersistentData.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2015/08/13.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation

class PersistentData {

    class var firstLaunch : Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("firstLaunch") ?? false
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(firstLaunch, forKey: "firstLaunch")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    

    class var userID : String {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("userID") ?? ""
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "userID")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    /*
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
    }

    var userID = NSUserDefaults.standardUserDefaults().stringForKey("userID") ?? "" {
        didSet{
            NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "userID")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
    }
*/
    
    
}