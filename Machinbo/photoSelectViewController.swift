//
//  PhotoSelectViewController.swift
//  Machinbo
//
//  Created by Kazuhiro Watanabe on 2015/07/20.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import UIKit

class PhotoSelectViewController: UIViewController {
    
    var mySelectedImage: UIImage!
    var mySelectedImageView: UIImageView!
    
    override func viewDidLoad() {
        
        self.edgesForExtendedLayout = UIRectEdge.None
        self.view.backgroundColor = UIColor.whiteColor()
        
        setImage()
    }
    
    /**
    選択された画像をUIImageViewにセットする.
    */
    func setImage(){
        self.title = "Selected Image"
        
        mySelectedImageView = UIImageView(frame: self.view.bounds)
        mySelectedImageView.contentMode = UIViewContentMode.ScaleAspectFit
        mySelectedImageView.image = mySelectedImage
        self.view.addSubview(mySelectedImageView)
    }
    
}