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
        case ok, cancel
    }

    class func showAlertView(_ title:String , message:String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        let controller = (UIApplication.shared.delegate as! AppDelegate).window!.rootViewController!
        controller.present(alertController, animated: true, completion: nil)
    }
    
    /*
     * Alert OK CANCEL
     */
    class func showAlertOKCancel(_ title: String, message: String, completion: @escaping (_ action: ActionButton) -> Void) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            (action:UIAlertAction) -> Void in
            completion(ActionButton.ok)
        })
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler:{
            (action:UIAlertAction) -> Void in
            completion(ActionButton.cancel)
        })
        alertController.addAction(cancelAction)
        
        let controller = (UIApplication.shared.delegate as! AppDelegate).window!.rootViewController!
        controller.present(alertController, animated: true, completion: nil)
    
    }
    
    class func showAlertDismiss(_ title:String, message:String, completion: @escaping () -> ()) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
    
        let controller = (UIApplication.shared.delegate as! AppDelegate).window!.rootViewController!
        controller.present(alertController, animated: true) { () -> Void in
            let delay = 1.5 * Double(NSEC_PER_SEC)
            let time  = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                controller.dismiss(animated: true, completion: nil)
                //back
                completion()
            })
        }
    }
}
