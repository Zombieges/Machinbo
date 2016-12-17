//
//  ConfigHelper
//  Machinbo
//
//  Created by ExtYabecchi on 2015/07/18.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation

class ConfigHelper {
    class func getPlistKey(_ key: String) -> String {
        var dict: NSDictionary?
        var result = ""
        
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            dict = NSDictionary(contentsOfFile: path)
        }
        
        if let value: AnyObject = dict?.value(forKey: key) as AnyObject?{
            result = value as! String
        }
        
        return result
    }
}
