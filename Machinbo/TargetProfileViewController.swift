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

class TargetProfileViewController: UIViewController, UITableViewDelegate {
    
    var mapView: MapViewController!
    let modalTextLabel = UILabel()
    var lblName: String = ""
    var userInfo: AnyObject = []

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ProfileImage: UIImageView!
    
    var otherItems: [String] = ["名前", "性別", "年齢", "プロフィール"]
    var otherItemsValue: [String] = []
    
    // Sectionで使用する配列を定義する.
    private let sections: NSArray = ["プロフィール"]

    let detailTableViewCellIdentifier: String = "DetailCell"
    
    override func loadView() {
        if let view = UINib(nibName: "TargetProfileView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        //self.tableView.estimatedRowHeight = 60
        //self.tableView.rowHeight = UITableViewAutomaticDimension
        //self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ell")
        
        //self.tableView.registerClass(DetailProfileTableViewCell.self, forCellReuseIdentifier: detailTableViewCellIdentifier)
        
        let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle:nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension

        self.view.addSubview(tableView)
        
        if let imageFile = self.userInfo.valueForKey("ProfilePicture") as? PFFile {
            imageFile.getDataInBackgroundWithBlock { (imageData, error) -> Void in
                if(error == nil) {
                    self.ProfileImage.image = UIImage(data: imageData!)!
                    self.ProfileImage.layer.borderColor = UIColor.whiteColor().CGColor
                    self.ProfileImage.layer.borderWidth = 3
                    self.ProfileImage.layer.cornerRadius = 10
                    self.ProfileImage.layer.masksToBounds = true
                }
            }
        }
        
    }
    
    /*
    func setUserInfo() {
        //ユーザー情報取得
        var query = PFQuery(className: "UserInfo")
        query.whereKey("UserID", containsString: "demo13")
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let object = objects?.first as? PFObject {
                    self.otherItemsValue.append((object.valueForKey("Name") as? String)!)
                    self.otherItemsValue.append("")
                    self.otherItemsValue.append((object.valueForKey("Age") as? String)!)
                    self.otherItemsValue.append((object.valueForKey("Comment") as? String)!)
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
    }*/
    
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
            return self.otherItems.count
        } else {
            return 0
        }
    }
    
    /*
    Cellに値を設定する.
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tableViewCellIdentifier = "Cell"
        
        var cell: UITableViewCell? // nilになることがあるので、Optionalで宣言
        if indexPath.section == 0 {
            
            if indexPath.row < 3 {
                // セルを再利用する。
                var normalCell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier) as? UITableViewCell
                if normalCell == nil { // 再利用するセルがなかったら（不足していたら）
                    // セルを新規に作成する。
                    normalCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: tableViewCellIdentifier)
                }
                
                if indexPath.row == 0 {
                    normalCell?.textLabel?.text = otherItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = self.userInfo.objectForKey("Name") as? String
                    
                } else if indexPath.row == 1 {
                    normalCell?.textLabel?.text = otherItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = self.userInfo.objectForKey("Gender") as? String
                    
                } else if indexPath.row == 2 {
                    normalCell?.textLabel?.text = otherItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = self.userInfo.objectForKey("Age") as? String
                }
                
                cell = normalCell
                
            } else {
                
                let detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell
                
                if indexPath.row == 3 {
                    detailCell?.titleLabel.text = otherItems[indexPath.row]
                    detailCell?.valueLabel.text = self.userInfo.objectForKey("Comment") as? String
                    
                }
                
                cell = detailCell
            }
            
        } else if indexPath.section == 2 {
            
        }
        
        return cell!
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
    
    /*
    いまから行きますボタン押下時
    */
    @IBAction func clickImaikuButton(sender: AnyObject) {
        //PickerViewController へ遷移し、何分以内に行くかを選択させる
        
        //ひとまず、何分かかるか選択する機能はおいておく

        
        //すでに登録済みかを確認
        /*
        var query = PFQuery(className: "Action")
        query.whereKey("UserID", containsString: userid)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                //GoogleMapsHelper.setUserMarker(map, userObjects: objects)
                completion(success: true, errorMesssage: nil, result: objects)
            } else {
                
            }
            
        }*/
        
        //ナベがクロマティにイマイクなケース
        //UserID demo6 が target demo7 にイマイク
        
        //ユーザーIDの取得
        let userid = "demo1"//PersistentData.userID
        let targetUserid = self.userInfo.objectForKey("UserID") as! String
        
        let query = PFQuery(className: "Action")
        query.getObjectInBackgroundWithId(userid, block: { (target, error) -> Void in

            if error != nil {
                //self.navigationController?.popToRootViewControllerAnimated(TRUE)
                NSLog("========> error")
                
                /*
                var testObject = PFObject(className:"Action")
                testObject["mitNavn"] = "janus"
                testObject.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError!) -> Void in
                    if (success) {
                        // The object has been saved.
                        println("succesfull saved object")
                    } else {
                        // There was a problem, check error.description
                        println("error saving the object")
                    }
                }*/
                
            } else if let target = target {
                
                //既にイマイク登録されている場合は登録できない
                //一度登録したのは１日経過するか、削除しなければいかん
                target.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if (success) {
                        NSLog("Save to area")
                        
                    } else {
                        NSLog("non success!!")
                    }
                })
                
            }

        })

        //gpsMark["GPS"] = geoPoint
        
        /*query.whereKey("TargetUserID", equalTo: self.userInfo.objectForKey("UserID"))
        
        query["MarkTime"] = NSDate()
        query.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            NSLog("GPS情報登録成功")
        }*/
    }
    
}