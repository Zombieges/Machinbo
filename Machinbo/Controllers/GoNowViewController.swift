//
//  ImakokoViewController.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2016/03/31.
//  Copyright (c) 2016年 Zombieges. All rights reservåed.
//

import Foundation
import UIKit
import Parse
import SpriteKit
import MBProgressHUD
import GoogleMobileAds

class GoNowViewController: UIViewController, UINavigationControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate, TransisionProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    var palGeoPoint: PFGeoPoint?
    var inputDateFrom: Date?
    var inputDateTo: Date?
    var inputPlace = ""
    var inputChar = ""
    let detailTableViewCellIdentifier = "DetailCell"
    var selectedRow: Int = 0
    
    let targetProfileItems = ["何時から", "何時まで", "待ち合わせ場所", "私の特徴"]
    
    override func loadView() {
        if let view = UINib(nibName: "ImakokoView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.navigationItem.title = "待ち合わせ情報の登録"
        self.navigationController!.navigationBar.tintColor = UIColor.darkGray
        self.initTableView()
    }
    
    @IBAction func imaikuButton(_ sender: AnyObject) {
        guard self.inputDateFrom != nil else {
            UIAlertController.showAlertView("", message: "待ち合わせ時間（何時から〜）を入力してください")
            return
        }
        guard self.inputDateTo != nil else {
            UIAlertController.showAlertView("", message: "待ち合わせ時間（〜何時まで）を入力してください")
            return
        }
        
        MBProgressHUDHelper.sharedInstance.show(self.view)
        
        ParseHelper.getMyUserInfomation(PersistentData.userID) { (error: NSError?, result: PFObject?) -> Void in
            guard let result = result, error == nil else {
                self.errorAction()
                return
            }
            
            let query = result as PFObject
            query["GPS"] = self.palGeoPoint
            query["MarkTime"] = self.inputDateFrom
            query["MarkTimeTo"] = self.inputDateTo
            query["PlaceDetail"] = self.inputPlace
            query["MyChar"] = self.inputChar
            query["IsRecruitment"] = true
            query.saveInBackground { (success: Bool, error: Error?) -> Void in
                defer { MBProgressHUDHelper.sharedInstance.hide() }
                
                guard success, error == nil else {
                    self.errorAction()
                    return
                }
                
                if let inputDateFrom = self.inputDateFrom {
                    PersistentData.markTimeFrom = inputDateFrom.formatter(format: .JP)
                }
                
                if let inputDateTo = self.inputDateTo {
                    PersistentData.markTimeTo = inputDateTo.formatter(format: .JP)
                }
                
                PersistentData.place = self.inputPlace
                PersistentData.mychar = self.inputChar
                PersistentData.isRecruitment = true //募集中フラグ
                
                UIAlertController.showAlertOKCancel("", message: "待ち合わせ登録をしました。投稿内容を確認しますか？", actiontitle: "確認") { action in
                    if action == .cancel {
                        let vc = MapViewController()
                        self.navigationController?.pushViewController(vc, animated: true)
                        return
                    }
                    
                    let vc = TargetProfileViewController(type: .entryTarget)
                    vc.targetUserInfo = result
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    fileprivate func initTableView() {
        let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle:nil)
        self.tableView.register(nibName, forCellReuseIdentifier: self.detailTableViewCellIdentifier)
        // 不要行の削除
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.rowHeight = 85.0
        self.view.addSubview(self.tableView)
    }
}


extension GoNowViewController: UIPickerViewDelegate, PickerViewControllerDelegate {
    internal func setSelectedValue(_ selectedIndex: Int, selectedValue: String, type: SelectPickerType) {}
    
    internal func setInputValue(_ inputValue: String, type: InputPickerType) {
        if type == .comment {
            if selectedRow == 2 {
                self.inputPlace = inputValue
                
            } else if selectedRow == 3 {
                self.inputChar = inputValue
            }
            
            self.tableView.reloadData()
        }
    }
    
    internal func setSelectedDate(_ selectedDate: Date) {
        if selectedRow == 0 {
            self.inputDateFrom = selectedDate
            
        } else if selectedRow == 1 {
            self.inputDateTo = selectedDate
        }
        
        self.tableView.reloadData()
    }
}


extension GoNowViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return targetProfileItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        var normalCell: UITableViewCell?
        var detailCell: DetailProfileTableViewCell?
        let tableViewCellIdentifier = "Cell"
        
        if indexPath.row <= 1 {
            normalCell = self.tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier)
            normalCell = UITableViewCell(style: .value1, reuseIdentifier: tableViewCellIdentifier)
            normalCell?.textLabel?.adjustsFontForContentSizeCategory = true
            normalCell?.detailTextLabel?.adjustsFontForContentSizeCategory = true
            
        } else {
            detailCell = self.tableView.dequeueReusableCell(withIdentifier: detailTableViewCellIdentifier, for: indexPath) as? DetailProfileTableViewCell
        }
        
        if indexPath.row == 0 {
            normalCell?.textLabel?.text = self.targetProfileItems[indexPath.row]
            normalCell?.accessoryType = .disclosureIndicator
            if let input = self.inputDateFrom {
                let formatDateString = input.formatter(format: .JP)
                normalCell?.detailTextLabel?.text = formatDateString
            }
            
            cell = normalCell
            
        } else if indexPath.row == 1 {
            normalCell?.textLabel?.text = self.targetProfileItems[indexPath.row]
            normalCell?.accessoryType = .disclosureIndicator
            if let inputDateTo = self.inputDateTo {
                let formatDateString = inputDateTo.formatter(format: .JP)
                normalCell?.detailTextLabel?.text = formatDateString
            }
            
            cell = normalCell
            
        } else if indexPath.row == 2 {
            detailCell?.titleLabel.text = self.targetProfileItems[indexPath.row]
            if inputPlace.isEmpty {
                detailCell?.valueLabel.text = "待ち合わせする場所を詳細に書いてください"
            } else {
                detailCell?.valueLabel.text = self.inputPlace
            }
            
            cell = detailCell
            
        } else if indexPath.row == 3 {
            detailCell?.titleLabel.text = self.targetProfileItems[indexPath.row]
            if inputChar.isEmpty {
                detailCell?.valueLabel.text = "自分の服装など、待ち合わせの際に分かる情報を書いてください"
            } else {
                detailCell?.valueLabel.text = self.inputChar
            }
            
            cell = detailCell
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row <= 1 ? 50 : 120
    }
    
    // セルがタップされた時
    internal func tableView(_ table: UITableView, didSelectRowAt indexPath:IndexPath) {
        self.selectedRow = indexPath.row
        guard indexPath.section == 0 else { return }
        
        if indexPath.row == 0 {
            let vc = PickerViewController(kind:.imakokoDate, inputValue: self.inputDateFrom as AnyObject)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.row == 1 {
            let vc = PickerViewController(kind: .imakokoDate, inputValue: self.inputDateTo as AnyObject)
            vc.delegate = self
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.row == 2 {
            let vc = PickerViewController(kind: .imakoko, inputValue: self.inputPlace as AnyObject)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.row == 3 {
            let vc = PickerViewController(kind: .imakoko, inputValue: self.inputChar as AnyObject)
            vc.delegate = self
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
