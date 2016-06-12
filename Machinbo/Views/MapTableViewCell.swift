//
//  MapTableViewCell.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2016/05/30.
//  Copyright © 2016年 Zombieges. All rights reserved.
//

import UIKit

class MapTableViewCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // UILabelとかを追加
        
        let autoresizingMasks: UIViewAutoresizing = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth];
        self.contentView.autoresizingMask = autoresizingMasks
    }
}