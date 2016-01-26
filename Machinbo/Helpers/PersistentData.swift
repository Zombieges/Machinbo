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
    

    /*class var userID : String {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("userID") ?? ""
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "userID")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }*/
    
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
        var comment : String {
            get {
                return NSUserDefaults.standardUserDefaults().stringForKey("comment") ?? ""
            }
            set {
                NSUserDefaults.standardUserDefaults().setObject(newValue , forKey: "comment")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        var gender : Int {
            get {
                return NSUserDefaults.standardUserDefaults().integerForKey("gender") ?? 0
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



    }

    /*var userID = NSUserDefaults.standardUserDefaults().stringForKey("userID") ?? "" {
        didSet{
            NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "userID")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }*/
}