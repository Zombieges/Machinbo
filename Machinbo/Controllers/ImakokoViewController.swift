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

extension ImakokoViewController: TransisionProtocol {}

class ImakokoViewController: UIViewController, UINavigationControllerDelegate,
    UIPickerViewDelegate,
    PickerViewControllerDelegate,
    GADBannerViewDelegate,
    GADInterstitialDelegate,
    UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var inputPlace: String = ""
    var inputChar: String = ""
    var palGeoPoint: PFGeoPoint?
    
    let detailTableViewCellIdentifier: String = "DetailCell"
    var targetProfileItems = ["待ち合わせ場所", "自分の特徴"]
    
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
        
        let detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell

        if indexPath.row == 0 {
            detailCell?.titleLabel.text = targetProfileItems[indexPath.row]
            if inputPlace.isEmpty {
                detailCell?.valueLabel.text = "　"
            } else {
                detailCell?.valueLabel.text = inputPlace
            }
            
        } else if indexPath.row == 1 {
            detailCell?.titleLabel.text = targetProfileItems[indexPath.row]
            if inputChar.isEmpty {
                detailCell?.valueLabel.text = "　"
            } else {
                detailCell?.valueLabel.text = inputChar
            }
        }
        
        return detailCell!
    }
    
    // PickerViewController より性別を選択した際に実行される処理
    internal func setGender(selectedIndex: Int,selected: String) {
    }
    
    // PickerViewController より年齢を選択した際に実行される処理
    internal func setAge(selectedIndex: Int,selected: String) {
    }
    
    // PickerViewController よりを保存ボタンを押下した際に実行される処理
    internal func setName(name: String) {
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
        
        let vc = PickerViewController()
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                vc.palKind = "imakoko"
                vc.palInput = inputPlace
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 1 {
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
            query["MarkTime"] = NSDate()
            query["PlaceDetail"] = self.inputPlace
            query["MyChar"] = self.inputChar
            
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
                dateFormatter.dateFormat = "yyyy年M月d日 H:m"
                userData.insertTime = dateFormatter.stringFromDate(NSDate())
                
                userData.place = self.inputPlace
                userData.mychar = self.inputChar
                
                //Alert
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