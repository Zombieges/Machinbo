//
//  UIAlertView+Custom.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2015/10/06.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    
    enum ActionButton {
        case ok, cancel
    }
    
    static func showAlertParseConnectionError() {
        showAlertView("エラー", message: "接続に失敗しました。再度実行してください")
    }

    static func showAlertView(_ title: String , message:String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        
        let controller = (UIApplication.shared.delegate as! AppDelegate).window!.rootViewController!
        controller.present(alertController, animated: true, completion: nil)
    }
    
    static func showAlertView(_ title: String, message: String, completion: @escaping (_ action: ActionButton) -> Void) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            (action:UIAlertAction) -> Void in
            completion(.ok)
        })
        alertController.addAction(okAction)
        
        let controller = (UIApplication.shared.delegate as! AppDelegate).window!.rootViewController!
        controller.present(alertController, animated: true, completion: nil)
        
    }
    
    /*
     * Alert OK CANCEL
     */
    static func showAlertOKCancel(_ title: String, message: String, actiontitle: String, completion: @escaping (_ action: ActionButton) -> Void) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: actiontitle, style: .default, handler: {
            (action:UIAlertAction) -> Void in
            completion(.ok)
        })
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler:{
            (action:UIAlertAction) -> Void in
            completion(.cancel)
        })
        alertController.addAction(cancelAction)
        
        let controller = (UIApplication.shared.delegate as! AppDelegate).window!.rootViewController!
        controller.present(alertController, animated: true, completion: nil)
    
    }

}
