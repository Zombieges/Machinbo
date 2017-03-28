//
//  GonowData.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2017/02/08.
//  Copyright © 2017年 Zombieges. All rights reserved.
//

import Foundation
import Parse

struct GonowData {
    
    var pfObject: PFObject
    
    init (parseObject: PFObject) {
        pfObject = parseObject
    }
    
    var ObjectId: String {
        get { return pfObject.objectId! }
        set { pfObject.objectId = newValue }
    }
    
    var UserID: String {
        get { return pfObject.object(forKey: "UserID") as! String }
        set { pfObject.setValue(newValue, forKey: "UserID") }
    }
    
    var IsApproved: Bool {
        get { return pfObject.object(forKey: "IsApproved") as! Bool }
        set { pfObject.setValue(newValue, forKey: "IsApproved") }
    }
    
    var IsDeleteUser: Bool {
        get { return pfObject.object(forKey: "isDeleteUser") as! Bool }
        set { pfObject.setValue(newValue, forKey: "isDeleteUser") }
    }
    
    var IsDeleteTarget: Bool {
        get { return pfObject.object(forKey: "isDeleteTarget") as! Bool }
        set { pfObject.setValue(newValue, forKey: "isDeleteTarget") }
    }
    
    var TargetUserID: String {
        get { return pfObject.object(forKey: "TargetUserID") as! String }
        set { pfObject.setValue(newValue, forKey: "TargetUserID") }
    }
    
    var UserGoNow: PFObject? {
        get { return pfObject.object(forKey: "userGoNow") as? PFObject }
        set { pfObject.setValue(newValue, forKey: "userGoNow") }
    }
    
    var TargetGoNow: PFObject? {
        get { return pfObject.object(forKey: "targetGoNow") as? PFObject }
        set { pfObject.setValue(newValue, forKey: "targetGoNow") }
    }
    
    var GotoAt: Date? {
        get { return pfObject.object(forKey: "gotoAt") as? Date }
        set { pfObject.setValue(newValue, forKey: "gotoAt") }
    }
}
