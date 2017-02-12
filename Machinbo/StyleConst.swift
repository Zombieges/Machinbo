//
//  StyleConst.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2017/02/12.
//  Copyright © 2017年 Zombieges. All rights reserved.
//

import Foundation

final class StyleConst {
    
    // UITableView Section Style ------------------------->
    static let sectionHeaderHeight: CGFloat = 42.0
    
    static var textColorForHeader: UIColor {
        return LayoutManager.getUIColorFromRGB(0x929292)
    }
    
    static var backgroundColorForHeader: UIColor {
        return LayoutManager.getUIColorFromRGB(0xF6F2F3)
    }
    
    static var borderColorForHeader: UIColor {
        return LayoutManager.getUIColorFromRGB(0xE9E9E9)
    }
    
    //-----------------------------------------------------<
}
