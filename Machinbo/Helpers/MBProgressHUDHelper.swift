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
    var progressHud: MBProgressHUD?
    
    
    override init() {
        
    }
    
    static func show(_ label: String) {
        
    }
    
    func show(_ view: UIView) {
        self.progressHud = MBProgressHUD.showAdded(to: view, animated: true)
        self.progressHud?.label.text = "Loading..."
        self.progressHud?.progress = 0.0
        self.progressHud?.WSStyle()
    }
    
    static func hide() {
    
    }
    
    func hide() {
        DispatchQueue.main.async {
            if self.progressHud != nil && !self.progressHud!.isHidden {
                self.progressHud?.hide(true)
            }
        }
    }
}

extension MBProgressHUD {
    func WSStyle() {
        self.removeFromSuperViewOnHide = true
    }
}
