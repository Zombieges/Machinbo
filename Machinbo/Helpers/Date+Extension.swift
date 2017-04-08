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
}
