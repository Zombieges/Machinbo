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

class SettingsViewController: UIViewController, UINavigationControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate, UITableViewDelegate, TransisionProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    var inputPlace: String = ""
    var inputChar: String = ""
    var palGeoPoint: PFGeoPoint?
    
    private let sections = ["サポート", "通知","規約", " "]
    private let supportLabels = ["Twitter公式アカウント"]
    private let appRuleLabels = ["サービス規約"]
    private let notificationLabels = ["通知設定"]
    private let otherLabels = ["アカウント削除"]
    
    var selectedRow: Int = 0
    
    override func loadView() {
        if let view = UINib(nibName: "SettingsView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        let noCreateView = UIView(frame: CGRect.zero)
        noCreateView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = noCreateView
        self.tableView.tableHeaderView = noCreateView
        
        self.view.addSubview(self.tableView)
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return StyleConst.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel(frame: CGRect(x: 8, y: 0, width: tableView.frame.size.width - 16, height: StyleConst.sectionHeaderHeight))
        label.font = UIFont(name: "Helvetica-Bold",size: CGFloat(15))
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textColor = StyleConst.textColorForHeader
        view.addSubview(label)
        
        return view
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
                cell?.imageView?.image = UIImage(named: "logo_twitter")
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
                let url = URL(string: ConfigData(type: .twitter).getPlistKey)
                if UIApplication.shared.canOpenURL(url!){
                    UIApplication.shared.openURL(url!)
                }
            }
            
        }  else if indexPath.section == 1 {
            
            let vc = PickerViewController(kind: PickerKind.notificationSettings)
            self.navigationController!.pushViewController(vc, animated: true)
            
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                //let vc = PickerViewController(kind: PickerKind.yakkan)
                self.goToRulesPages()
            }
            
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                self.deleteAccount()
            }
        }
    }
    
    func goToRulesPages() {
        if let url = URL(string: ConfigData(type: .rule).getPlistKey) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    func deleteAccount() {
        guard self.isInternetConnect() else {
            self.errorAction()
            return
        }
        
        UIAlertController.showAlertOKCancel("", message: "アカウントを削除しますと、いままでの履歴が削除されてしまいます。本当にアカウントを削除してもよろしいですか？", actiontitle: "削除") { action in
            
            if action == .cancel {
                MBProgressHUDHelper.sharedInstance.hide()
                return
            }
            
            MBProgressHUDHelper.sharedInstance.show(self.view)
            
            ParseHelper.deleteUserInfo(PersistentData.userID) { () -> () in
                
                MBProgressHUDHelper.sharedInstance.hide()
                
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
    
}
