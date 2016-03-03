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
    static func show(label: String) {
        let view = (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController?.view
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = label
        hud.WSStyle()
    }
    
    static func show(view: UIView, label: String) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = label
        hud.WSStyle()
    }
    
    // Hides the progress hud
    //
    static func hide() {
        let view = (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController?.view
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            MBProgressHUD.hideHUDForView(view, animated: true)
        })
    }
    
    static func hide(view: UIView) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            MBProgressHUD.hideHUDForView(view, animated: true)
        })
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