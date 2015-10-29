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

class TargetProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var mapView: MapViewController!
    let modalTextLabel = UILabel()
    var lblName: String = ""
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ProfileImage: UIImageView!
    
    var photoItems: [String] = ["フォト"]
    var otherItems: [String] = ["名前", "性別", "年齢", "プロフィール"]
    
    
    // Sectionで使用する配列を定義する.
    private let sections: NSArray = ["フォト", "基本情報"]
    
    override func loadView() {
        if let view = UINib(nibName: "TargetProfileView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        //ユーザー情報取得
        self.setUserInfo()
        
        //tableView.delegate = self
        //tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        
    }
    
    func setUserInfo() {
        //ユーザー情報取得
        var query = PFQuery(className: "UserInfo")
        query.whereKey("UserID", containsString: "demo13")
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let object = objects?.first as? PFObject {
                    //self.Name.text = object.valueForKey("Name") as? String
                    //self.Gender.text = object.valueForKey("Age") as? String
                    //self.Comment.text = object.valueForKey("Comment") as? String
                    //TODO:ナベに画像を圧縮してもらう
                    let imageFile: PFFile? = object.valueForKey("ProfilePicture") as! PFFile?
                    imageFile?.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                        if(error == nil) {
                            self.ProfileImage!.image = UIImage(data: imageData!)!
                        }
                    })
                }
                
            } else {
                let title = "エラー"
                let message = "ユーザー情報が取得できませんでした。前画面からアクセスし直し、改善されない場合は一度立ち上げ直してください。"
                UIAlertView.showAlertView(title, message: message)
            }
        }
    }
    
    /*
    セクションの数を返す.
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    /*
    セクションのタイトルを返す.
    */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section] as? String
    }
    
    /*
    テーブルに表示する配列の総数を返す.
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.photoItems.count
        } else if section == 1 {
            return self.otherItems.count
        } else {
            return 0
        }
    }
    
    /*
    Cellに値を設定する.
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: "Cell")
        
        if indexPath.section == 0 {
            cell.textLabel?.text = photoItems[indexPath.row]
            cell.detailTextLabel?.text = "Detail Text Label"
            
        } else if indexPath.section == 1 {
            cell.textLabel?.text = otherItems[indexPath.row]
            cell.detailTextLabel?.text = otherItems[indexPath.row]
            return cell
        }
        
        return cell
    }
    
    /*
    Cellが選択された際に呼び出される.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // 選択中のセルが何番目か.
        println("Num: \(indexPath.row)")
        
        // 選択中のセルのvalue.
        //println("Value: \(myItems[indexPath.row])")
        
        // 選択中のセルを編集できるか.
        println("Edeintg: \(tableView.editing)")
    }
    
    func showModal(sender: AnyObject){
        self.presentViewController(self.mapView, animated: true, completion: nil)
    }
}