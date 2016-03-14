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
    
    class func showAlertView(title:String , message:String) {
        let alert = UIAlertView()
        alert.title = title
        alert.message = message
        alert.addButtonWithTitle("OK")
        alert.show()
    }
    
    class func showAlertDismiss(tittle:String, message:String) {
        let completeDialog = UIAlertController(
            title: tittle,
            message: message,
            preferredStyle: .Alert
        )
        
        let controller = (UIApplication.sharedApplication().delegate as! AppDelegate).window!.rootViewController!
        controller.presentViewController(completeDialog, animated: true) { () -> Void in
            let delay = 1.0 * Double(NSEC_PER_SEC)
            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                controller.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
}