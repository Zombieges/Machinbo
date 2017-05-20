//
//  FirstLuanch.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2017/05/20.
//  Copyright © 2017年 Zombieges. All rights reserved.
//

import Foundation
import UIKit

class FirstLaunchViewController: UIViewController {
    
    override func viewDidLoad() {
        if let view = UINib(nibName: "FirstLaunchView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
    }
    
    
    @IBAction func startButton(_ sender: Any) {
        let tabBarConrtoller = LayoutManager.createNavigationProfile()
        UIApplication.shared.keyWindow?.rootViewController = tabBarConrtoller
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
    
    
}
