//
//  DateHelper.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2016/06/13.
//  Copyright © 2016年 Zombieges. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    enum BorderPosition {
        case Top
        case Right
        case Bottom
        case Left
    }
    
    func border(borderWidth: CGFloat, borderColor: UIColor?, borderRadius: CGFloat?) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor?.cgColor
        if let _ = borderRadius {
            self.layer.cornerRadius = borderRadius!
        }
        self.layer.masksToBounds = true
    }
    
    func border(positions: [BorderPosition], borderWidth: CGFloat, borderColor: UIColor?) {
        
        let topLine = CALayer()
        let leftLine = CALayer()
        let bottomLine = CALayer()
        let rightLine = CALayer()
        
        self.layer.sublayers = nil
        self.layer.masksToBounds = true
        
        if let _ = borderColor {
            topLine.backgroundColor = borderColor!.cgColor
            leftLine.backgroundColor = borderColor!.cgColor
            bottomLine.backgroundColor = borderColor!.cgColor
            rightLine.backgroundColor = borderColor!.cgColor
        } else {
            topLine.backgroundColor = UIColor.white.cgColor
            leftLine.backgroundColor = UIColor.white.cgColor
            bottomLine.backgroundColor = UIColor.white.cgColor
            rightLine.backgroundColor = UIColor.white.cgColor
        }
        
        if positions.contains(.Top) {
            topLine.frame = CGRect(x:0.0, y:0.0, width:self.frame.width, height:borderWidth)
            self.layer.addSublayer(topLine)
        }
        if positions.contains(.Left) {
            leftLine.frame = CGRect(x:0.0,y: 0.0, width:borderWidth,height: self.frame.height)
            self.layer.addSublayer(leftLine)
        }
        if positions.contains(.Bottom) {
            bottomLine.frame = CGRect(x:0.0,y: self.frame.height - borderWidth, width:self.frame.width, height:borderWidth)
            self.layer.addSublayer(bottomLine)
        }
        if positions.contains(.Right) {
            rightLine.frame = CGRect(x:self.frame.width - borderWidth, y:0.0,width: borderWidth, height:self.frame.height)
            self.layer.addSublayer(rightLine)
        }
        
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let _ = self.layer.borderColor {
                return UIColor(cgColor: self.layer.borderColor!)
            }
            return nil
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
}
