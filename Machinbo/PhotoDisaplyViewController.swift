//
//  PhotoDisaplyViewController.swift
//  Machinbo
//
//  Created by Kazuhiro Watanabe on 2015/07/20.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import UIKit

class PhotoDisaplyViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var myImagePicker: UIImagePickerController!
    //var myImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select a Image"
        
        //myImageView = UIImageView(frame: self.view.bounds)
        
        // インスタンス生成
        myImagePicker = UIImagePickerController()
        
        // デリゲート設定
        myImagePicker.delegate = self
        
        // 画像の取得先はフォトライブラリ
        myImagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        // 画像取得後の編集を不可に
        myImagePicker.allowsEditing = false
        
        self.presentViewController(myImagePicker, animated: true, completion: nil)
        
    }
    
    /*override func viewDidAppear(animated: Bool) {
        NSLog("aoaiao")
        self.presentViewController(myImagePicker, animated: true, completion: nil)
        
    }*/
    
    /**
    画像が選択された時に呼ばれる.
    */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        //選択された画像を取得.
        var myImage: AnyObject?  = info[UIImagePickerControllerOriginalImage]
        
        //選択された画像を表示するViewControllerを生成.
        let PhotoSelect = PhotoSelectViewController()
        
        //選択された画像を表示するViewContorllerにセットする.
        PhotoSelect.mySelectedImage = myImage as! UIImage
        
        myImagePicker.pushViewController(PhotoSelect, animated: true)
        
    }
    
    /**
    画像選択がキャンセルされた時に呼ばれる.
    */
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        // モーダルビューを閉じる
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
}