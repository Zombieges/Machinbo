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
    UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    var inputPlace: String = ""
    var inputChar: String = ""
    var palGeoPoint: PFGeoPoint?
    
    let detailTableViewCellIdentifier: String = "DetailCell"
    var targetProfileItems = ["待ち合わせ場所", "自分の特徴"]
    
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
        
        //広告を表示
        self.showAdmob()
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
        
        if userInfo.imakokoFlag {
            ParseHelper.getActionInfomation(userInfo.userID) { (error: NSError?, result: PFObject?) -> Void in
                guard error == nil else {
                    return
                }
            
                let query = result! as PFObject
                let gpsMark = PFObject(className: "Action")
                gpsMark["CreatedBy"] = query.objectForKey("CreatedBy")
                gpsMark["GPS"] = self.palGeoPoint
                gpsMark["MarkTime"] = NSDate()
                //場所詳細
                gpsMark["PlaceDetail"] = self.inputPlace
                gpsMark["MyChar"] = self.inputChar
                //登録処理
                gpsMark.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    defer {
                        MBProgressHUDHelper.hide()
                    }
                    
                    guard error == nil else {
                        return
                    }
                        
                    //Alert
                    UIAlertView.showAlertDismiss("", message: "現在位置を登録しました") { () -> () in
                        self.navigationController!.popToRootViewControllerAnimated(true)
                    }
                }
            }
            
        } else {
            
            ParseHelper.getUserInfomation(userInfo.userID) { (error: NSError?, result: PFObject?) -> Void in
                guard error == nil else {
                    return
                }
                
                let gpsMark = PFObject(className: "Action")
                gpsMark["CreatedBy"] = result! as PFObject
                gpsMark["GPS"] = self.palGeoPoint
                gpsMark["MarkTime"] = NSDate()
                //場所詳細
                gpsMark["PlaceDetail"] = self.inputPlace
                gpsMark["MyChar"] = self.inputChar
                //登録処理
                gpsMark.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    
                    defer {
                        MBProgressHUDHelper.hide()
                    }
                    
                    guard error == nil else {
                        return
                    }
                    
                    //Alert
                    UIAlertView.showAlertDismiss("", message: "現在位置を登録しました") { () -> () in
                        self.navigationController!.popToRootViewControllerAnimated(true)
                    }
                }
            }
            
            //一回登録したいとは常にフラグを立てる
            userInfo.imakokoFlag = true
            
        }

    }
    

    
}