//
//  ConfigHelper
//  Machinbo
//
//  Created by ExtYabecchi on 2015/07/18.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation

class ConfigHelper {
    class func getPlistKey(key: String) -> String {
        var dict: NSDictionary?
        var result = ""
        
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist") {
            dict = NSDictionary(contentsOfFile: path)
        }
        
        if let value: AnyObject = dict?.valueForKey(key){
            result = value as! String
        }
        
        return result
    }
}