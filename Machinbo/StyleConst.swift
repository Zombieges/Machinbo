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
    
    static var displayWideZFRippleButton = { (title: String!) -> ZFRippleButton in
        let displayWidth = UIScreen.main.bounds.size.width
        
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: displayWidth - 20, height: 50))
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0x0D47A1, alpha: 1.0)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0x0D47A1, alpha: 1.0)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0x1976D2)
        btn.setTitle(title, for: UIControlState())
        btn.layer.cornerRadius = 2
        btn.layer.masksToBounds = true
        btn.layer.position = CGPoint(x: displayWidth/2, y: 200)
        
        return btn
    }
    
}
