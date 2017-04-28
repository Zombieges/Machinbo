//
//  UIImage+Extension.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2017/04/08.
//  Copyright © 2017年 Zombieges. All rights reserved.
//

import Foundation
import JTSImageViewController

extension UIImageView {
    
    func jtsImage(viewController: UIViewController) {
        let imageInfo = JTSImageInfo()
        imageInfo.image = self.image
        imageInfo.referenceRect = self.frame
        imageInfo.referenceView = self.superview
        
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: .image, backgroundStyle: .blurred)
        imageViewer?.show(from: viewController, transition: .fromOriginalPosition)
    }
}
