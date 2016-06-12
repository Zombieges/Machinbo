//
//  SettingsViewController.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2016/05/07.
//  Copyright © 2016年 Zombieges. All rights reserved.
//

import Foundation
import UIKit
import Parse
import SpriteKit
import MBProgressHUD
import GoogleMobileAds

extension SettingsViewController: TransisionProtocol {}

class SettingsViewController: UIViewController, UINavigationControllerDelegate,
    GADBannerViewDelegate,
    GADInterstitialDelegate,
    UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var inputPlace: String = ""
    var inputChar: String = ""
    var palGeoPoint: PFGeoPoint?
    
    let sections = ["サポート", "Machinboいついて", " "]
    let supportLabels = ["Twitter公式アカウント"]
    let appRuleLabels = ["サービス規約"]
    let otherLabels = ["アカウント削除"]
    
    var selectedRow: Int = 0
    
    override func loadView() {
        if let view = UINib(nibName: "SettingsView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.navigationItem.title = "オプション"
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
//        let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle:nil)
//        tableView.registerNib(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
        
        // 不要行の削除
        let noCreateView:UIView = UIView(frame: CGRectZero)
        noCreateView.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = noCreateView
        tableView.tableHeaderView = noCreateView
        
        
        view.addSubview(tableView)
        
        if self.isInternetConnect() {
            //広告を表示
            self.showAdmob(AdmobType.standard)
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
        return sections[section]
    }
    
    /*
     テーブルに表示する配列の総数を返す.
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.supportLabels.count
            
        } else if section == 1 {
            return self.appRuleLabels.count
            
        } else if section == 2 {
            return self.otherLabels.count
            
        } else {
            return 0
        }
    }
    
    /*
     Cellに値を設定する.
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let tableViewCellIdentifier = "Cell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier)
        if cell == nil { // 再利用するセルがなかったら（不足していたら）
            // セルを新規に作成する。
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: tableViewCellIdentifier)
        }
        
        if indexPath.section == 0 {
            cell?.textLabel?.text = supportLabels[indexPath.row] as String
            
            if indexPath.row == 0 {
                cell?.imageView?.image = UIImage(named: "logo_twitter.png")
            }
            
        } else if indexPath.section == 1 {
            cell?.textLabel?.text = appRuleLabels[indexPath.row] as String
            
        } else if indexPath.section == 2 {
            cell?.textLabel?.text = otherLabels[indexPath.row] as String
        }
        
        return cell!
    }
    
    // PickerViewController よりを保存ボタンを押下した際に実行される処理
    internal func setComment(comment: String) {
        if selectedRow == 0 {
            inputPlace = comment
            
        } else if selectedRow == 1 {
            inputChar = comment
        }
        
        // テーブル再描画
        tableView.reloadData()
    }
    
    // セルがタップされた時
    internal func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let url = NSURL(string: ConfigHelper.getPlistKey("TWITTER_LINK"))
                if UIApplication.sharedApplication().canOpenURL(url!){
                    UIApplication.sharedApplication().openURL(url!)
                }
            }
            
        } else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                let path = NSBundle.mainBundle().pathForResource("UserPolicy", ofType: "txt")!
//                if let data = NSData(contentsOfFile: path){
//                    label.text = String(NSString(data: data, encoding: NSUTF8StringEncoding)!)
//                }else{
//                    label.text = "データなし"
//                }
                
                let vc = PickerViewController()
                //vc.palTargetUser = self.userInfo as? PFObject
                vc.palKind = "yakkan"
                
                self.navigationController!.pushViewController(vc, animated: true)
            }

        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                deleteAccount()
            }
        }
    }
    
    func deleteAccount() {
        
        MBProgressHUDHelper.show("Loading...")
        
        //アカウント削除処理
        UIAlertView.showAlertOKCancel("", message: "アカウントを削除しますと、いままでの履歴が削除されてしまいます。本当にアカウントを削除してもよろしいですか？") { action in
            
            if action == UIAlertView.ActionButton.Cancel {
                MBProgressHUDHelper.hide()
                return
            }
            
            let userData = PersistentData.User()
            
            //ActionオブジェクトがNilの場合は、UserInfoオブジェクトのみ削除する
            self.deleteUserInfo(userData.userID)
        }
    }
    
    func deleteUserInfo(userID: String) {
        
        ParseHelper.deleteUserInfo(userID) { () -> () in
            
            UIAlertView.showAlertDismiss("", message: "アカウントを削除しました") {}
            
            let newRootVC = ProfileViewController()
            let navigationController = UINavigationController(rootViewController: newRootVC)
            navigationController.navigationBar.barTintColor = LayoutManager.getUIColorFromRGB(0x3949AB)
            navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
            UIApplication.sharedApplication().keyWindow?.rootViewController = navigationController
            
            self.viewDidLoad()
        }
    }
    
}