//
//  ImakokoViewController.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2016/03/31.
//  Copyright (c) 2016年 Zombieges. All rights reserved.
//

import Foundation
import UIKit
import Parse
import SpriteKit
import MBProgressHUD
import GoogleMobileAds

extension GoNowViewController: TransisionProtocol {}

class GoNowViewController: UIViewController, UINavigationControllerDelegate,
    UIPickerViewDelegate,
    PickerViewControllerDelegate,
    GADBannerViewDelegate,
    GADInterstitialDelegate,
    UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var inputDate = NSDate()
    var inputPlace = ""
    var inputChar = ""
    var palGeoPoint: PFGeoPoint?
    
    private let normalTableViewCellIdentifier = "NormalCell"
    private let detailTableViewCellIdentifier = "DetailCell"
    
    private let targetProfileItems = ["待ち合わせ時間", "待ち合わせ場所", "自分の特徴"]
    
    var _interstitial: GADInterstitial?
    
    var selectedRow: Int = 0
    
    override func loadView() {
        if let view = UINib(nibName: "ImakokoView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.navigationItem.title = "場所と特徴を登録"
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle:nil)
        tableView.registerNib(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
        
        // 不要行の削除
        let noCreateView:UIView = UIView(frame: CGRectZero)
        noCreateView.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = noCreateView
        tableView.tableHeaderView = noCreateView
        view.addSubview(tableView)
        
        if self.isInternetConnect() {
            //広告を表示
            self.showAdmob(AdmobType.standard)
            _interstitial = self.showFullAdmob()
        }
    }
    
    /*
    セクションの数を返す.
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /*
    テーブルに表示する配列の総数を返す.
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return targetProfileItems.count
    }
    
    /*
    Cellに値を設定する.
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?
        var normalCell: UITableViewCell?
        var detailCell: DetailProfileTableViewCell?
        
        let tableViewCellIdentifier = "Cell"
        
        if indexPath.row == 0 {
            
            normalCell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier)
            if normalCell == nil {
                normalCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: tableViewCellIdentifier)
                normalCell!.textLabel!.font = UIFont.systemFontOfSize(16)
                normalCell!.detailTextLabel!.font = UIFont.systemFontOfSize(16)
            }
            
        } else {
            detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell
        }

        if indexPath.row == 0 {
            normalCell?.textLabel?.text = targetProfileItems[indexPath.row]
            let dateFormatter = NSDateFormatter();
            dateFormatter.dateFormat = "yyyy年M月d日 H:mm"
            let formatDateString = dateFormatter.stringFromDate(self.inputDate)
            normalCell?.detailTextLabel?.text = formatDateString
            
            cell = normalCell
            
        } else if indexPath.row == 1 {
            
            detailCell?.titleLabel.text = targetProfileItems[indexPath.row]
            if inputPlace.isEmpty {
                detailCell?.valueLabel.text = "待ち合わせする場所を詳細に書いてください。性と関連した内容、金銭関連の内容、その他不適切な内容を作成する場合、アカウントが停止される可能性がありますのでご注意ください"
            } else {
                detailCell?.valueLabel.text = self.inputPlace
            }
            
            cell = detailCell
            
        } else if indexPath.row == 2 {
            detailCell?.titleLabel.text = targetProfileItems[indexPath.row]
            if inputChar.isEmpty {
                detailCell?.valueLabel.text = "自分の服装など、待ち合わせの際に分かる情報を書いてください。性と関連した内容、金銭関連の内容、その他不適切な内容を作成する場合、アカウントが停止される可能性がありますのでご注意ください"
            } else {
                detailCell?.valueLabel.text = self.inputChar
            }
            
            cell = detailCell
        }
        
        return cell!
    }
    
//    // PickerViewController より性別を選択した際に実行される処理
//    internal func setGender(selectedIndex: Int,selected: String) {
//    }
//    
//    // PickerViewController より年齢を選択した際に実行される処理
//    internal func setAge(selectedIndex: Int,selected: String) {
//    }
    
    // PickerViewController よりを保存ボタンを押下した際に実行される処理
    internal func setSelectedValue(selectedIndex: Int, selectedValue: String, type: SelectPickerType) {
    }
    
    internal func setInputValue(inputValue: String, type: InputPickerType) {
        if type == InputPickerType.Comment {
            if selectedRow == 1 {
                self.inputPlace = inputValue

            } else if selectedRow == 2 {
                self.inputChar = inputValue
            }
            
            tableView.reloadData()
        }
    }
    
    internal func setSelectedDate(selectedDate: NSDate) {
        if selectedRow == 0 {
            self.inputDate = selectedDate
        }
    }
        
    
//    // PickerViewController よりを保存ボタンを押下した際に実行される処理
//    internal func setComment(comment: String) {
//        if selectedRow == 0 {
//            self.inputDate = comment
//            
//        } else if selectedRow == 1 {
//            self.inputPlace = comment
//            
//        } else if selectedRow == 2 {
//            self.inputChar = comment
//        }
//        
//        // テーブル再描画
//        tableView.reloadData()
//    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if indexPath.row == 0 {
            return 50
            
        } else {
            return 120
        }
    }
    
    // セルがタップされた時
    internal func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        
        let vc = PickerViewController()
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                vc.palKind = "imakokoDate"

                vc.palInput = inputDate
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 1 {
                vc.palKind = "imakoko"
                vc.palInput = inputPlace
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 2 {
                vc.palKind = "imakoko"
                vc.palInput = inputChar
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        selectedRow = indexPath.row
    }
    
    @IBAction func imaikuButton(sender: AnyObject) {
        
        MBProgressHUDHelper.show("Loading...")
        
        var userInfo = PersistentData.User()
        
        ParseHelper.getUserInfomation(userInfo.userID) { (error: NSError?, result: PFObject?) -> Void in
            
            guard error == nil else {
                return
            }
            
            let query = result! as PFObject
            query["GPS"] = self.palGeoPoint
            query["MarkTime"] = self.inputDate
            query["PlaceDetail"] = self.inputPlace
            query["MyChar"] = self.inputChar
            query["IsRecruitment"] = true
            
            query.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                defer {
                    MBProgressHUDHelper.hide()
                }
                
                guard error == nil else {
                    return
                }
                
                //local db に保存
                var userData = PersistentData.User()
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy年M月d日 H:mm"
                let formatDateString = dateFormatter.stringFromDate(self.inputDate)
                userData.insertTime = formatDateString
                
                userData.place = self.inputPlace
                userData.mychar = self.inputChar
                userData.isRecruitment = true //募集中フラグ
                
                UIAlertView.showAlertDismiss("", message: "現在位置を登録しました") { () -> () in
                    
                    if self._interstitial!.isReady {
                        self._interstitial!.presentFromRootViewController(self)
                    }
                    
                    self.navigationController!.popToRootViewControllerAnimated(true)
                }
            }
        }

    }
    

    
}