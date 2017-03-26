//
//  UserData.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2017/02/07.
//  Copyright © 2017年 Zombieges. All rights reserved.
//

import Foundation
import Parse

class UserData {
    var pfObject: PFObject
    
    init (parseObject: PFObject) {
        pfObject = parseObject
    }
    
    var name: String {
        get { return pfObject.object(forKey: "name") as! String }
        set { pfObject.setValue(newValue, forKey: "name") }
    }
    
    var userID: String {
        get { return pfObject.object(forKey: "UserID") as! String }
        set { pfObject.setValue(newValue, forKey: "UserID") }
    }
 
    var markTimeFrom: Date? {
        get { return pfObject.object(forKey: "MarkTimeFrom") as? Date }
        set { pfObject.setValue(newValue, forKey: "MarkTimeFrom") }
    }
    
    var markTimeTo: Date? {
        get { return pfObject.object(forKey: "MarkTimeTo") as? Date }
        set { pfObject.setValue(newValue, forKey: "MarkTimeTo") }
    }
    
    var deviceToken: String? {
        get { return pfObject.object(forKey: "DeviceToken") as? String }
        set { pfObject.setValue(newValue, forKey: "DeviceToken") }
    }
    
    var gps: PFGeoPoint? {
        get { return pfObject.object(forKey: "GPS") as? PFGeoPoint }
        set { pfObject.setValue(newValue, forKey: "GPS") }
    }
    
    //DeviceToken
    
    
    
    
    
}
