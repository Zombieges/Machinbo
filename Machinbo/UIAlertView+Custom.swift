//
//  UIAlertView+Custom.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2015/10/06.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import UIKit

public extension UIAlertView {
    
    class func showAlertView(title:String , message:String)
    {
        let alert = UIAlertView()
        alert.title = title
        alert.message = message
        alert.addButtonWithTitle("OK")
        alert.show()
    }
}