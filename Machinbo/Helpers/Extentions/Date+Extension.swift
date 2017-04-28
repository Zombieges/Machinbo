//
//  Date+Extension.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2017/04/08.
//  Copyright © 2017年 Zombieges. All rights reserved.
//

import Foundation

enum DateFormatType: String {
    case JP = "yyyy年M月d日 H:mm"
    case AD = "yyyy-M-d"
}

extension Date {
    func formatter(format: DateFormatType) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
    
    public var relativeDateString: String {
        let timeDelta = Date().timeIntervalSince1970 - self.timeIntervalSince1970
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
