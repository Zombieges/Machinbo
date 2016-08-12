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
    
    enum ActionButton {
        case OK, Cancel
    }

    class func showAlertView(title:String , message:String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .Alert
        )

        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        let controller = (UIApplication.sharedApplication().delegate as! AppDelegate).window!.rootViewController!
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /*
     * Alert OK CANCEL
     */
    class func showAlertOKCancel(title: String, message: String, completion: (action: ActionButton) -> Void) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .Alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: {
            (action:UIAlertAction) -> Void in
            completion(action: ActionButton.OK)
        })
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler:{
            (action:UIAlertAction) -> Void in
            completion(action: ActionButton.Cancel)
        })
        alertController.addAction(cancelAction)
        
        let controller = (UIApplication.sharedApplication().delegate as! AppDelegate).window!.rootViewController!
        controller.presentViewController(alertController, animated: true, completion: nil)
    
    }
    
    class func showAlertDismiss(title:String, message:String, completion: () -> ()) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .Alert
        )
    
        let controller = (UIApplication.sharedApplication().delegate as! AppDelegate).window!.rootViewController!
        controller.presentViewController(alertController, animated: true) { () -> Void in
            let delay = 1.5 * Double(NSEC_PER_SEC)
            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                controller.dismissViewControllerAnimated(true, completion: nil)
                //back
                completion()
            })
        }
    }
}