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
    private let sections: NSArray = [" ", " "]
    
    var myDetailText : NSString = ""
    
    override func loadView() {
        if let view = UINib(nibName: "TargetProfileView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        //tableView.delegate = self
        //tableView.dataSource = self
        
        headerView.layer.borderWidth = 5
        headerView.layer.borderColor = UIColor.redColor().CGColor//IColor(red:179,green:179,blue:179,alpha:10).CGColor
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        
        let imageFile: PFFile? = self.userInfo.valueForKey("ProfilePicture") as! PFFile?
        imageFile?.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
            if(error == nil) {
                self.ProfileImage!.image = UIImage(data: imageData!)!
            }
        })
        
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
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let text: NSString = myDetailText as NSString // myDetailTextは、detailTextLabelに入力するテキスト。NSStringにキャストする。
        let labelWidth = tableView.bounds.size.width - 30.0 // 30.0は適当。正しくdetailTextLabelの幅を計算してください。
        let maxSize = CGSize(width: labelWidth, height: CGFloat.max)
        let attribute = [NSFontAttributeName: UIFont.systemFontOfSize(11.0)] // デフォルトのdetailTextLabelのフォントとそのサイズ。これも適切な値にしてください。
        let size = text.boundingRectWithSize(maxSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attribute, context: nil).size
        
        var rowHeight = 30.0 as CGFloat
        if indexPath.row == 3 {
            rowHeight = 100.0
        }
        
        return size.height + rowHeight // この28.0も適当な数字。
    }
    /*
    Cellに値を設定する.
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier = "Cell" // セルのIDを定数identifierにする。
        let identifierDetail = "DetailCell" // セルのIDを定数identifierにする。
        var cell: UITableViewCell? // nilになることがあるので、Optionalで宣言
        // セルを再利用する。
        cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? UITableViewCell
        if cell == nil { // 再利用するセルがなかったら（不足していたら）
            // セルを新規に作成する。
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identifier)
        }
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell?.textLabel?.text = otherItems[indexPath.row]
                cell?.detailTextLabel?.text = self.userInfo.objectForKey("Name") as? String
                
            } else if indexPath.row == 1 {
                cell?.textLabel?.text = otherItems[indexPath.row]
                cell?.detailTextLabel?.text = self.userInfo.objectForKey("Gender") as? String
                
            } else if indexPath.row == 2 {
                cell?.textLabel?.text = otherItems[indexPath.row]
                cell?.detailTextLabel?.text = self.userInfo.objectForKey("Age") as? String
                
            } else if indexPath.row == 3 {
                
                cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: identifier)
                
                myDetailText = self.userInfo.objectForKey("Comment") as! NSString
                //let cell = tableView.dequeueReusableCellWithIdentifier(identifierDetail, forIndexPath: indexPath) as! DetailProfileTableViewCell
                myDetailText = "あいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそあいうえおかきくけこさしすせそ"
            
                cell?.detailTextLabel?.numberOfLines = 0
                cell?.textLabel?.text = otherItems[indexPath.row]
                
                //cell?.detailTextLabel?.text = self.userInfo.objectForKey("Comment") as? String
                cell?.detailTextLabel?.text = myDetailText as String
                //cell?.detailTextLabel?.font = UIFont.systemFontOfSize(15)
                
                
            } else if indexPath.row == 4 {
                
            }
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
}