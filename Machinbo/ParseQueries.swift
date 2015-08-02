//
//  ParseQueries.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2015/08/02.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import Parse

class ParseQueries {
    
    class func getUserInfoList() -> [PFObject] {
        var queryForTags = PFQuery(className: "UserInfo")
        queryForTags.limit = 100
        return queryForTags.findObjects() as! [PFObject]
    }
    
}