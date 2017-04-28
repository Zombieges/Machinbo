//
//  UIImage+Extension.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2017/04/09.
//  Copyright © 2017年 Zombieges. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let size = CGSize(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        
        let rect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        self.draw(in: rect)
        //context!.setFillColor(UIColor.black.cgColor)
        context!.addRect(rect)
        //context!.drawPath(using: .fill)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
