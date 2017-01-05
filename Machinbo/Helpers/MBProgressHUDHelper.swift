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
    
    // Shows the progress hud coving the whoel screen
    //
    static func show(_ label: String) {
        let view = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.view
        let hud = MBProgressHUD.showAdded(to: view!, animated: true)
        hud.labelText = label
        hud.WSStyle()
    }
    
    static func show(_ view: UIView, label: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.labelText = label
        hud.WSStyle()
    }
    
    // Hides the progress hud
    //
    static func hide() {
        let view = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.view
//        DispatchQueue.main.async(execute: { () -> Void in
//            MBProgressHUD.hide(for: view!, animated: true)
//        })
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
        //self.color = WSColor.NavbarGrey
        //self.labelColor = WSColor.Green
        //self.labelFont = WSFont.SueEllenFrancisco(22)
        //self.activityIndicatorColor = WSColor.DarkBlue
        //self.dimBackground = true
        self.removeFromSuperViewOnHide = true
    }
}
