//
//  MarkWindow.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2015/08/01.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import UIKit

class MarkWindow: UIView {
    
    //プロフィール写真
    @IBOutlet weak var ProfileImage: UIImageView!
    //名前
    @IBOutlet weak var Name: UILabel!
    //詳細
    @IBOutlet weak var Detail: UILabel!
    //画面遷移View
    @IBOutlet weak var ClickView: UIView!

    @IBOutlet weak var timeAgoText: UILabel!
}