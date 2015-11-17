//
//  DetailProfileTableViewCell.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2015/11/17.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import UIKit

class DetailProfileTableViewCell : UITableViewCell {
 
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var subTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}