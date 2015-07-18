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

extension PHPhotoLibrary {
    
    //ユーザーに許可を促す.
    class func Authorization(){
        
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            
            switch(status){
            case .Authorized:
                println("Authorized")
                
            case .Denied:
                println("Denied")
                
            case .NotDetermined:
                println("NotDetermined")
                
            case .Restricted:
                println("Restricted")
            }
            
        }
    }
}

class ProfileViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var sex: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var profile: UITextField!
    
    @IBOutlet weak var impPhotoButton: UIButton!
    
    @IBOutlet weak var editButon: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    
    
    // アルバム.
    var myAlbum: NSMutableArray!
    
    
    // Cell数を返すメソッド.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myAlbum.count
    }
    
    // Cellの初期化をするメソッド.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as! UITableViewCell
        
        // Cellに値を設定.
        cell.textLabel?.text = "\(myAlbum[indexPath.row])"
        
        return cell
    }
    
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
        
        myAlbum = NSMutableArray()
        
        // フォトアプリの中にあるアルバムを検索する.
        
        /*        var list = PHFetchResult()
        list = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: nil)
        */
        
        var list = PHFetchResult()
        list = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
        println(list.debugDescription);
        
        
        println(list.debugDescription);
        
        
        // リストの中にあるオブジェクトに対して１つずつ呼び出す.
        list.enumerateObjectsUsingBlock { (album, index, isStop) -> Void in
            
            // アルバムのタイトル名をコレクションする.
            //self.myAlbum.addObject(album.localizedTitle)
            
        }
        
        // 結果表示用のTableViewを用意.
        let barHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        // TableViewを生成.
        let myTableView: UITableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
        
        
        
        
        /*       var imageManager: PHImageManager?
        
        
        // 写真取り込み機能
        var assets = PHFetchResult()
        assets = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
        println(assets.debugDescription);
        assets.enumerateObjectsUsingBlock({ obj, idx, stop in
        
        if obj is PHAsset
        {
        let asset:PHAsset = obj as! PHAsset;
        /*println("Asset IDX:\(idx)");
        println("mediaType:\(asset.mediaType)");
        println("mediaSubtypes:\(asset.mediaSubtypes)");
        println("pixelWidth:\(asset.pixelWidth)");
        println("pixelHeight:\(asset.pixelHeight)");
        println("creationDate:\(asset.creationDate)");
        println("modificationDate:\(asset.modificationDate)");
        println("duration:\(asset.duration)");
        println("favorite:\(asset.favorite)");
        println("hidden:\(asset.hidden)");*/
        
        
        let phimgr:PHImageManager = PHImageManager();
        phimgr.requestImageForAsset(asset,
        targetSize: CGSize(width: 320, height: 320),
        contentMode: .AspectFill, options: nil) {
        image, info in
        
        var myImageView: UIImageView!
        myImageView = UIImageView(frame: CGRectMake(0,0,100,120))
        
        //self.photoImageView.image = image
        myImageView.image = image
        self.view.addSubview(myImageView)
        //println("UIImage get!");
        }
        
        }
        });
        */
        /*        let ipc:UIImagePickerController = UIImagePickerController();
        ipc.delegate = self
        ipc.sourceType = UIImagePickerControllerSourceType.Camera
        // UIImagePickerControllerSourceType.PhotoLibraryでアルバムへのアクセス
        self.presentViewController(ipc, animated:true, completion:nil)
        
        func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if info[UIImagePickerControllerOriginalImage] != nil {
        let image:UIImage = info[UIImagePickerControllerOriginalImage]  as! UIImage
        }
        //allowsEditingがtrueの場合 UIImagePickerControllerEditedImage
        //閉じる処理
        picker.dismissViewControllerAnimated(true, completion: nil);
        }
        */
    }
}
