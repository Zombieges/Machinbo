//
//  ProgressHUBHelper.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2016/03/03.
//  Copyright (c) 2016年 Zombieges. All rights reserved.
//

import Foundation
import MBProgressHUD

class MBProgressHUDHelper: NSObject {
    
    static let sharedInstance = MBProgressHUDHelper()
    var progressHud = MBProgressHUD(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    
    
    override init() {
        super.init()
        
        progressHud.isUserInteractionEnabled = true
        progressHud.mode = .indeterminate
        progressHud.label.text = "Loading..."
        progressHud.removeFromSuperViewOnHide = true
    }

    func show(_ view: UIView) {
        UIApplication.shared.keyWindow?.addSubview(progressHud)
        progressHud.taskInProgress = true
        progressHud.show(true)
    }
    
    func hide() {
        DispatchQueue.main.async {
            if !self.progressHud.isHidden {
                self.progressHud.hide(true)
            }
        }
    }   
}

extension MBProgressHUD {
    func WSStyle() {
        self.removeFromSuperViewOnHide = true
    }
}
