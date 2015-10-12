//
//  TargetProfileViewController.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2015/09/08.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import UIKit
import Parse

class TargetProfileViewController: UIViewController {
    
    var mapView: MapViewController!
    let modalTextLabel = UILabel()
    var lblName: String = ""
    
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Gender: UILabel!
    @IBOutlet weak var Comment: UILabel!
    @IBOutlet weak var ProfileImage: UIImageView!
    
    override func loadView() {
        if let view = UINib(nibName: "TargetProfileView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.title = "マップ"
        
        //ユーザー情報取得
        self.setUserInfo()
    }
    
    func setUserInfo() {
        //ユーザー情報取得
        var query = PFQuery(className: "UserInfo")
        query.whereKey("UserID", containsString: "demo13")
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let object = objects?.first as? PFObject {
                    self.Name.text = object.valueForKey("Name") as? String
                    self.Gender.text = object.valueForKey("Age") as? String
                    self.Comment.text = object.valueForKey("Comment") as? String
                    //TODO:ナベに画像を圧縮してもらう
                    self.ProfileImage = object.valueForKey("ProfilePicture") as? UIImageView
                }
                
            } else {
                let title = "エラー"
                let message = "ユーザー情報が取得できませんでした。前画面からアクセスし直し、改善されない場合は一度立ち上げ直してください。"
                UIAlertView.showAlertView(title, message: message)
            }
        }
    }
    
    @IBAction func onClickBuckButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showModal(sender: AnyObject){
        self.presentViewController(self.mapView, animated: true, completion: nil)
    }
}