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
import MBProgressHUD

enum ProfileType {
    case TargetProfile, ImaikuTargetProfile
}

class TargetProfileViewController: UIViewController, UITableViewDelegate {
    
    let mapView: MapViewController = MapViewController()
    let modalTextLabel = UILabel()
    let lblName: String = ""
    
    var actionInfo: AnyObject?
    var userInfo: AnyObject = []
    var targetObjectID: String?
    //遷移元の画面IDを指定
    var kind: String = ""

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var targetButton: ZFRippleButton!
    
    var targetProfileItems: [String] = ["名前", "性別", "年齢", "プロフィール"]
    var otherItems: [String] = ["登録時間", "場所", "特徴"]
    
    // Sectionで使用する配列を定義する.
    private let sections: NSArray = ["プロフィール", "待ち合わせ情報"]

    let detailTableViewCellIdentifier: String = "DetailCell"
    
    var type: ProfileType = ProfileType.TargetProfile
    
    init (type: ProfileType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func loadView() {
        if let view = UINib(nibName: "TargetProfileView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
   
        let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle:nil)
        tableView.registerNib(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension

        view.addSubview(tableView)
        
        if let actionInfo: AnyObject = self.actionInfo {
             userInfo = actionInfo.objectForKey("CreatedBy") as! PFObject
            
            if let imageFile = userInfo.valueForKey("ProfilePicture") as? PFFile {
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
        
        if type == ProfileType.ImaikuTargetProfile {
            targetButton.setTitle("取り消し", forState: .Normal)
        }

    }
    
    /*
    セクションの数を返す.
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        let returnSectionCount = sections.count
        /*
        if type == ProfileType.TargetProfile {
            returnSectionCount -= 1
        }*/
        
        return returnSectionCount
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
            return self.targetProfileItems.count
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
        
        let tableViewCellIdentifier = "Cell"
        
        var cell: UITableViewCell? // nilになることがあるので、Optionalで宣言
        if indexPath.section == 0 {
            
            if indexPath.row < 3 {
                // セルを再利用する
                var normalCell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier)
                if normalCell == nil { // 再利用するセルがなかったら（不足していたら）
                    // セルを新規に作成する。
                    normalCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: tableViewCellIdentifier)
                }
                
                if indexPath.row == 0 {
                    normalCell?.textLabel?.text = targetProfileItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = self.userInfo.objectForKey("Name") as? String
                    
                } else if indexPath.row == 1 {
                    normalCell?.textLabel?.text = targetProfileItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = self.userInfo.objectForKey("Gender") as? String
                    
                } else if indexPath.row == 2 {
                    normalCell?.textLabel?.text = targetProfileItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = self.userInfo.objectForKey("Age") as? String
                }
                
                cell = normalCell
                
            } else {
                
                let detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell
                
                if indexPath.row == 3 {
                    detailCell?.titleLabel.text = targetProfileItems[indexPath.row]
                    detailCell?.valueLabel.text = self.userInfo.objectForKey("Comment") as? String
                    
                }
                
                cell = detailCell
            }
            
        } else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                var normalCell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier)
                if normalCell == nil { // 再利用するセルがなかったら（不足していたら）
                    // セルを新規に作成する。
                    normalCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: tableViewCellIdentifier)
                }
                
                normalCell?.textLabel?.text = otherItems[indexPath.row]
                
                let dateFormatter = NSDateFormatter();
                dateFormatter.dateFormat = "yyyy年M月d日 H:m"
                let formatDateString = dateFormatter.stringFromDate(self.actionInfo!.objectForKey("MarkTime") as! NSDate)
                
                normalCell?.detailTextLabel?.text = formatDateString
                
                cell = normalCell
                
            } else if indexPath.row == 1 {
                let detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell
                
                detailCell?.titleLabel.text = otherItems[indexPath.row]
                detailCell?.valueLabel.text = self.actionInfo!.objectForKey("PlaceDetail") as? String
                
                cell = detailCell
                
            } else if indexPath.row == 2 {
                let detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell
                
                detailCell?.titleLabel.text = otherItems[indexPath.row]
                detailCell?.valueLabel.text = self.actionInfo!.objectForKey("MyChar") as? String
                
                cell = detailCell
            }
            
        }
        
        return cell!
    }
    
    /*
    Cellが選択された際に呼び出される.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 選択中のセルが何番目か.
        print("Num: \(indexPath.row)")
        // 選択中のセルを編集できるか.
        print("Edeintg: \(tableView.editing)")
    }
    
    func showModal(sender: AnyObject){
        self.presentViewController(self.mapView, animated: true, completion: nil)
    }
    
    @IBAction func clickImaikuButton(sender: AnyObject) {
        
        MBProgressHUDHelper.show("Loading...")
        
        var userInfo = PersistentData.User()
        
        if type == ProfileType.TargetProfile {
            
            if userInfo.imaikuFlag {
                UIAlertView.showAlertDismiss("", message: "既にいまから行く対象の人がいます", completion: { () -> () in
                    //self.navigationController!.popToRootViewControllerAnimated(true)
                    MBProgressHUDHelper.hide()
                })
            }
            //imaiku flag on
            userInfo.imaikuFlag = true
            
            let vc = PickerViewController()
            vc.palTargetUser = self.actionInfo as? PFObject
            vc.palKind = "imaiku"
            vc.palmItems = ["5分","10分", "15分", "20分", "25分", "30分", "35分", "40分", "45分", "50分", "55分", "60分"]
            
            self.navigationController!.pushViewController(vc, animated: true)
            MBProgressHUDHelper.hide()

        } else if type == ProfileType.ImaikuTargetProfile {
            
            //imaiku flag on
            userInfo.imaikuFlag = false
            
            //imaiku削除
            UIAlertView.showAlertOKCancel("", message: "いまから行くを取り消しますか？") { action in
                
                if action == UIAlertView.ActionButton.OK {
                    
                    UIAlertView.showAlertDismiss("", message: "取り消しました", completion: { () -> () in
                        ParseHelper.deleteGoNow(self.targetObjectID!) { () -> () in
                            self.navigationController!.popToRootViewControllerAnimated(true)
                            MBProgressHUDHelper.hide()
                        }
                    })
                    
                } else {
                    MBProgressHUDHelper.hide()
                }
            }
            
        }
        
    }
    
}