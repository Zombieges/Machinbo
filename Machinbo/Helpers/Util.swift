//
//  DateHelper.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2016/06/13.
//  Copyright © 2016年 Zombieges. All rights reserved.
//

import Foundation

extension NSDate {
    public var relativeDateString: String {
        let timeDelta = NSDate().timeIntervalSince1970 - self.timeIntervalSince1970
        if timeDelta < 3600 * 24 {
            let hours = Int(timeDelta/3600)
            if hours >= 0 {
                if hours == 0 {
                    return "\(Int(timeDelta/60))分前"
                }
                return "\(Int(hours))時間前"
            }
        }
        
        // n日前
        let days = Int(timeDelta/(3600*24))
        return "\(days)日前"
    }
}

class Parser {
    
    class func changeAgeRange(ageStr: String) -> String {
        
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "Y/M/d"
        let birthday = dateFormatter.dateFromString(ageStr + "/1/1")!
        let components = calendar.components([.Year, .Month, .Day], fromDate: birthday, toDate: now, options: NSCalendarOptions())
        
        let age = components.year
        var returnStr = ""
        
        if 0...19 ~= age {
            returnStr = "10代後半"
        } else if 20...23 ~= age {
            returnStr = "20代前半"
        } else if 24...26 ~= age {
            returnStr = "20代中半"
        } else if 27...29 ~= age {
            returnStr = "20代後半"
        } else if 30...33 ~= age {
            returnStr = "30代前半"
        } else if 34...36 ~= age {
            returnStr = "30代中半"
        } else if 37...39 ~= age {
            returnStr = "30代後半"
        } else if 40...43 ~= age {
            returnStr = "40代前半"
        } else if 44...46 ~= age {
            returnStr = "40代中半"
        } else if 47...49 ~= age {
            returnStr = "40代後半"
        } else if 50...99 ~= age {
            returnStr = "50代以降"
        } else {
            returnStr = "100歳以上"
        }
        
        return returnStr
    }
}