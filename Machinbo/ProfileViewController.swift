//
//  ProfileViewController.swift
//  Machinbo
//
//  Created by Kazuhiro Watanabe on 2015/07/05.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import UIKit
import Photos

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var sex: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var profile: UITextField!
    
    @IBOutlet weak var impPhotoButton: UIButton!
    
    @IBOutlet weak var editButon: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // control init
        name.enabled = false
        sex.enabled = false
        age.enabled = false
        profile.enabled = false
        editButon.hidden = false
        cancelButton.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editDepression(sender: AnyObject) {
        
        // control init
        name.enabled = true
        sex.enabled = true
        age.enabled = true
        profile.enabled = true
        editButon.hidden = true
        cancelButton.hidden = false
    }
    
    @IBAction func cancelDepression(sender: AnyObject) {
        
        // control init
        name.enabled = false
        sex.enabled = false
        age.enabled = false
        profile.enabled = false
        editButon.hidden = false
        cancelButton.hidden = true
    }
    
    @IBAction func importPhoto(sender: AnyObject) {
        
        var myImageView: UIImageView!
        myImageView = UIImageView(frame: CGRectMake(0,0,100,120))
        
        // 写真取り込み機能
        var assets = PHFetchResult()
        assets = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
        println(assets.debugDescription);
        assets.enumerateObjectsUsingBlock({ obj, idx, stop in
            
            if obj is PHAsset
            {
                let asset:PHAsset = obj as! PHAsset;
                println("Asset IDX:\(idx)");
                println("mediaType:\(asset.mediaType)");
                println("mediaSubtypes:\(asset.mediaSubtypes)");
                println("pixelWidth:\(asset.pixelWidth)");
                println("pixelHeight:\(asset.pixelHeight)");
                println("creationDate:\(asset.creationDate)");
                println("modificationDate:\(asset.modificationDate)");
                println("duration:\(asset.duration)");
                println("favorite:\(asset.favorite)");
                println("hidden:\(asset.hidden)");
                
                
                let phimgr:PHImageManager = PHImageManager();
                phimgr.requestImageForAsset(asset,
                    targetSize: CGSize(width: 320, height: 320),
                    contentMode: .AspectFill, options: nil) {
                        image, info in
                        //self.photoImageView.image = image
                        myImageView.image = image
                        self.view.addSubview(myImageView)
                        //println("UIImage get!");
                }
                
            }
        });
    }
}
