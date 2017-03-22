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
        get {return pfObject.object(forKey: "name") as! String}
        set {pfObject.setValue(newValue, forKey: "name")}
    }
    
    
    
}
