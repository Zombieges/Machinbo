//
//  ProgressHUBHelper.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2016/03/03.
//  Copyright (c) 2016年 Zombieges. All rights reserved.
//

import Foundation
import MBProgressHUD

class MBProgressHUDHelper {
    
    static func show(_ label: String) {
        let view = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.view
        let hud = MBProgressHUD.showAdded(to: view!, animated: true)
        hud.label.text = label
        hud.progress = 0.0
        hud.WSStyle()
    }
    
    static func show(_ view: UIView, label: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = label
        hud.progress = 0.0
        hud.WSStyle()
    }
    
    static func hide() {
        let view = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.view
        MBProgressHUD.hide(for: view!, animated: true)
    }
    
    static func hide(_ view: UIView) {
//        DispatchQueue.main.async(execute: { () -> Void in
//            MBProgressHUD.hide(for: view, animated: true)
//        })
        MBProgressHUD.hide(for: view, animated: true)
    }
    
}

extension MBProgressHUD {
    func WSStyle() {
        self.removeFromSuperViewOnHide = true
    }
}
