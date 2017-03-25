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

class GoNowViewController:
    UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    UINavigationControllerDelegate,
    UIPickerViewDelegate,
    PickerViewControllerDelegate,
    GADBannerViewDelegate,
    GADInterstitialDelegate,
    TransisionProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    var palGeoPoint: PFGeoPoint?
    private var inputDateFrom: Date?
    private var inputDateTo: Date?
    private var inputPlace = ""
    private var inputChar = ""
    private let normalTableViewCellIdentifier = "NormalCell"
    private let detailTableViewCellIdentifier = "DetailCell"
    private let targetProfileItems = ["待ち合わせ（何時から〜）", "待ち合わせ（〜何時まで）", "待ち合わせ場所", "自分の特徴"]
    private var selectedRow: Int = 0
    private lazy var dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 H:mm"
        return formatter
    }()
    
    override func loadView() {
        if let view = UINib(nibName: "ImakokoView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.navigationItem.title = "待ち合わせ情報の登録"
        self.navigationController!.navigationBar.tintColor = UIColor.darkGray
        
        self.initTableView()
    }
    
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
            normalCell!.textLabel!.font = UIFont.systemFont(ofSize: 16)
            normalCell!.detailTextLabel!.font = UIFont.systemFont(ofSize: 16)
            
        } else {
            detailCell = self.tableView.dequeueReusableCell(withIdentifier: detailTableViewCellIdentifier, for: indexPath) as? DetailProfileTableViewCell
        }
        
        if indexPath.row == 0 {
            normalCell?.textLabel?.text = self.targetProfileItems[indexPath.row]
            if let input = self.inputDateFrom {
                let formatDateString = self.dateFormatter.string(from: input)
                normalCell?.detailTextLabel?.text = formatDateString
            }
            
            cell = normalCell
            
        } else if indexPath.row == 1 {
            normalCell?.textLabel?.text = self.targetProfileItems[indexPath.row]
            if self.inputDateTo != nil {
                let formatDateString = self.dateFormatter.string(from: self.inputDateTo!)
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
            let vc = PickerViewController(kind: PickerKind.imakokoDateFrom, inputValue: self.inputDateFrom as AnyObject)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.row == 1 {
            let vc = PickerViewController(kind: PickerKind.imakokoDateTo, inputValue: self.inputDateTo as AnyObject)
            vc.delegate = self
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.row == 2 {
            let vc = PickerViewController(kind: PickerKind.imakoko, inputValue: self.inputPlace as AnyObject)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.row == 3 {
            let vc = PickerViewController(kind: PickerKind.imakoko, inputValue: self.inputChar as AnyObject)
            vc.delegate = self
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
        
        var userInfo = PersistentData.User()
        ParseHelper.getMyUserInfomation(userInfo.userID) { (error: NSError?, result: PFObject?) -> Void in
            guard error == nil else { print("Error information"); return }
            
            let query = result! as PFObject
            query["GPS"] = self.palGeoPoint
            query["MarkTime"] = self.inputDateFrom
            query["MarkTimeTo"] = self.inputDateTo
            query["PlaceDetail"] = self.inputPlace
            query["MyChar"] = self.inputChar
            query["IsRecruitment"] = true
            query.saveInBackground { (success: Bool, error: Error?) -> Void in
                defer { MBProgressHUDHelper.sharedInstance.hide() }
                guard error == nil else { print("Error information"); return }
                
                var userData = PersistentData.User()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy年M月d日 H:mm"
                if self.inputDateFrom != nil {
                    userData.markTimeFrom =  dateFormatter.string(from: self.inputDateFrom!)
                }
                
                if self.inputDateTo != nil {
                    userData.markTimeTo = dateFormatter.string(from: self.inputDateTo!)
                }
                
                userData.place = self.inputPlace
                userData.mychar = self.inputChar
                userData.isRecruitment = true //募集中フラグ
                
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
    
    private func initTableView() {
        let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle:nil)
        self.tableView.register(nibName, forCellReuseIdentifier: self.detailTableViewCellIdentifier)
        // 不要行の削除
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.rowHeight = 85.0
        self.view.addSubview(self.tableView)
    }
    
}
