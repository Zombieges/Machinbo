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

class SettingsViewController: UIViewController, UINavigationControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var inputPlace: String = ""
    var inputChar: String = ""
    var palGeoPoint: PFGeoPoint?
    
    private let sections = ["サポート", "Machinboいついて","通知について", " "]
    private let supportLabels = ["Twitter公式アカウント"]
    private let appRuleLabels = ["サービス規約"]
    private let notificationLabels = ["通知設定"]
    private let otherLabels = ["アカウント削除"]
    
    var selectedRow: Int = 0
    
    override func loadView() {
        if let view = UINib(nibName: "SettingsView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.navigationItem.title = "オプション"
        
        let noCreateView = UIView(frame: CGRect.zero)
        noCreateView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = noCreateView
        self.tableView.tableHeaderView = noCreateView
        
        self.view.addSubview(self.tableView)
        
        if self.isInternetConnect() {
            self.showAdmob(AdmobType.standard)
        }
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCellIdentifier = "Cell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier)
        if cell == nil {
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
    
    internal func setComment(_ comment: String) {
        if selectedRow == 0 {
            self.inputPlace = comment
            
        } else if selectedRow == 1 {
            self.inputChar = comment
        }
        
        self.tableView.reloadData()
    }

    func tableView(_ table: UITableView, didSelectRowAt indexPath:IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let url = URL(string: ConfigHelper.getPlistKey("TWITTER_LINK"))
                if UIApplication.shared.canOpenURL(url!){
                    UIApplication.shared.openURL(url!)
                }
            }
            
        }  else if indexPath.section == 1 {
            
            let vc = PickerViewController()
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
                self.deleteAccount()
            }
        }
    }
    
    func deleteAccount() {
        MBProgressHUDHelper.show("Loading...")
        
        UIAlertController.showAlertOKCancel("", message: "アカウントを削除しますと、いままでの履歴が削除されてしまいます。本当にアカウントを削除してもよろしいですか？", actiontitle: "削除") { action in
            
            if action == .cancel {
                MBProgressHUDHelper.hide()
                return
            }
            
            self.deleteUserInfo(PersistentData.User().userID)
            PersistentData.deleteUserID()
        }
    }
    
    func deleteUserInfo(_ userID: String) {
        
        ParseHelper.deleteUserInfo(userID) { () -> () in
            
            UIAlertController.showAlertView("", message: "アカウントを削除しました") { _ in
                let newRootVC = ProfileViewController()
                let navigationController = UINavigationController(rootViewController: newRootVC)
                navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGray]
                navigationController.navigationBar.tintColor = .darkGray
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
