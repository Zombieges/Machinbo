//
//  DateHelper.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2016/06/13.
//  Copyright © 2016年 Zombieges. All rights reserved.
//

import Foundation

class Parser {
    
    class func changeAgeRange(_ ageStr: String) -> String {
        
        let calendar = Calendar.current
        let now = Date()
        
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "Y/M/d"
        let birthday = dateFormatter.date(from: ageStr + "/1/1")!
        let components = (calendar as NSCalendar).components([.year, .month, .day], from: birthday, to: now, options: NSCalendar.Options())
        
        let age = Int(components.year!)
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
