//
//  GonowData.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2017/02/08.
//  Copyright © 2017年 Zombieges. All rights reserved.
//

import Foundation
import Parse

class GonowData {
    var pfObject: PFObject
    
    init (parseObject: PFObject) {
        pfObject = parseObject
    }
    
    var ObjectId: String {
        get { return pfObject.objectId! }
        set(v) { pfObject.objectId = v }
    }
    
    var UserID: String {
        get { return pfObject.object(forKey: "UserID") as! String }
        set(v) { pfObject.setValue(v, forKey: "UserID") }
    }
    
    var IsApproved: Bool {
        get { return pfObject.object(forKey: "IsApproved") as! Bool }
        set(v) { pfObject.setValue(v, forKey: "IsApproved") }
    }
    
    var IsDeleteUser: Bool {
        get { return pfObject.object(forKey: "isDeleteUser") as! Bool }
        set(v) { pfObject.setValue(v, forKey: "isDeleteUser") }
    }
    
    var IsDeleteTarget: Bool {
        get { return pfObject.object(forKey: "isDeleteTarget") as! Bool }
        set(v) { pfObject.setValue(v, forKey: "isDeleteTarget") }
    }
    
    var TargetUserID: String {
        get { return pfObject.object(forKey: "TargetUserID") as! String }
        set(v) { pfObject.setValue(v, forKey: "TargetUserID") }
    }
    
    var UserGoNow: PFObject {
        get { return pfObject.object(forKey: "userGoNow") as! PFObject }
        set(v) { pfObject.setValue(v, forKey: "userGoNow") }
    }
    
    var TargetGoNow: PFObject {
        get { return pfObject.object(forKey: "targetGoNow") as! PFObject }
        set(v) { pfObject.setValue(v, forKey: "targetGoNow") }
    }
}
