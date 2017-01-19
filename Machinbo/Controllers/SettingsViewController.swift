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
    
    fileprivate let sections = ["サポート", "Machinboいついて","通知について", " "]
    fileprivate let supportLabels = ["Twitter公式アカウント"]
    fileprivate let appRuleLabels = ["サービス規約"]
    fileprivate let notificationLabels = ["通知設定"]
    let otherLabels = ["アカウント削除"]
    
    var selectedRow: Int = 0
    
    override func loadView() {
        if let view = UINib(nibName: "SettingsView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.navigationItem.title = "オプション"
        // 不要行の削除
        let noCreateView:UIView = UIView(frame: CGRect.zero)
        noCreateView.backgroundColor = UIColor.clear
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
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        
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
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    /*
     テーブルに表示する配列の総数を返す.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.supportLabels.count
            
        } else if section == 1 {
            return self.notificationLabels.count
            
        } else if section == 2 {
            return self.appRuleLabels.count
            
        } else if section == 3 {
            return self.otherLabels.count
            
        } else {
            return 0
        }
    }
    
    /*
     Cellに値を設定する.
     */
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCellIdentifier = "Cell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier)
        if cell == nil { // 再利用するセルがなかったら（不足していたら）
            // セルを新規に作成する。
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: tableViewCellIdentifier)
        }
        
        if indexPath.section == 0 {
            cell?.textLabel?.text = supportLabels[indexPath.row] as String
            
            if indexPath.row == 0 {
                cell?.imageView?.image = UIImage(named: "logo_twitter.png")
            }
            
        } else if indexPath.section == 1 {
            cell?.textLabel?.text = notificationLabels[indexPath.row] as String
            
        } else if indexPath.section == 2 {
            cell?.textLabel?.text = appRuleLabels[indexPath.row] as String
            
        } else if indexPath.section == 3 {
            cell?.textLabel?.text = otherLabels[indexPath.row] as String
        }
        
        return cell!
    }
    
    // PickerViewController よりを保存ボタンを押下した際に実行される処理
    internal func setComment(_ comment: String) {
        if selectedRow == 0 {
            inputPlace = comment
            
        } else if selectedRow == 1 {
            inputChar = comment
        }
        
        // テーブル再描画
        tableView.reloadData()
    }
    
    // セルがタップされた時
    internal func tableView(_ table: UITableView, didSelectRowAt indexPath:IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let url = URL(string: ConfigHelper.getPlistKey("TWITTER_LINK"))
                if UIApplication.shared.canOpenURL(url!){
                    UIApplication.shared.openURL(url!)
                }
            }
            
        }  else if indexPath.section == 1 {
            
            let vc = PickerViewController()
            //vc.palTargetUser = self.userInfo as? PFObject
            vc.palKind = "notificationSettings"
            vc.palmItems = ["メッセージ内容の表示"]
            
            self.navigationController!.pushViewController(vc, animated: true)
            
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let vc = PickerViewController()
                vc.palKind = "yakkan"
                
                self.navigationController!.pushViewController(vc, animated: true)
            }
            
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                deleteAccount()
            }
        }
    }
    
    func deleteAccount() {
        
        MBProgressHUDHelper.show("Loading...")
        
        //アカウント削除処理
        UIAlertController.showAlertOKCancel("", message: "アカウントを削除しますと、いままでの履歴が削除されてしまいます。本当にアカウントを削除してもよろしいですか？") { action in
            
            if action == .cancel {
                MBProgressHUDHelper.hide()
                return
            }
            
            let userData = PersistentData.User()
            
            //ActionオブジェクトがNilの場合は、UserInfoオブジェクトのみ削除する
            self.deleteUserInfo(userData.userID)
            PersistentData.deleteUserID()
        }
    }
    
    func deleteUserInfo(_ userID: String) {
        
        ParseHelper.deleteUserInfo(userID) { () -> () in
            
            UIAlertController.showAlertView("", message: "アカウントを削除しました") { _ in
                let newRootVC = ProfileViewController()
                let navigationController = UINavigationController(rootViewController: newRootVC)
                navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.darkGray]
                navigationController.navigationBar.tintColor = UIColor.darkGray
                navigationController.navigationBar.isTranslucent = false
                navigationController.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                navigationController.navigationBar.setBackgroundImage(UIImage(named: "BarBackground"),
                                                                      for: .default)
                navigationController.navigationBar.shadowImage = UIImage()
                UIApplication.shared.keyWindow?.rootViewController = navigationController
                
                self.viewDidLoad()
            }
        }
    }
    
}
