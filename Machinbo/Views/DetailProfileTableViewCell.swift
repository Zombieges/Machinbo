//
//  DetailProfileTableViewCell.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2015/11/17.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import UIKit

class DetailProfileTableViewCell : UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // UILabelとかを追加
        
        let autoresizingMasks: UIViewAutoresizing = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth];
        self.contentView.autoresizingMask = autoresizingMasks
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.textColor = UIColor.black
        valueLabel.textColor = UIColor.gray
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
