//
//  DetailProfileTableViewCell.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2015/12/04.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import UIKit

class GoNowTableViewCell : UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var gonowTime: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var entryTime: UILabel!    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // UILabelとかを追加
        
        let autoresizingMasks: UIViewAutoresizing = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth];
        self.contentView.autoresizingMask = autoresizingMasks
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImage.image = nil
        entryTime.textColor = UIColor.darkGrayColor()
        gonowTime.textColor = UIColor.darkGrayColor()
        valueLabel.textColor = UIColor.grayColor()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}