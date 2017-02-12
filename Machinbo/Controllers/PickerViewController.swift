//
//  PickerViewController.swift
//  Machinbo
//
//  Created by Kazuhiro Watanabe on 2015/08/02.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import Parse
import MBProgressHUD
import GoogleMobileAds
import UserNotifications

extension PickerViewController: TransisionProtocol {}

enum SelectPickerType { case gender, age }
enum InputPickerType { case comment, name }

protocol PickerViewControllerDelegate{
    func setInputValue(_ inputValue: String, type: InputPickerType)
    func setSelectedValue(_ selectedIndex: Int, selectedValue: String, type: SelectPickerType)
    func setSelectedDate(_ SelectedDate: Date)
    //func setSelectedDateTo(_ SelectedDate: Date)
}

class PickerViewController: UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    GADBannerViewDelegate,
    GADInterstitialDelegate,
UISearchBarDelegate {
    
    var delegate: PickerViewControllerDelegate?
    
    var _interstitial: GADInterstitial?
    let saveButton = UIButton()
    var selectedAgeIndex: Int?
    var selectedAge:String = ""
    var selectedGenderIndex: Int?
    var selectedGender: String = ""
    
    var inputTextField = UITextField()
    var inputTextView = UITextView()
    var inputPlace = UITextView()
    var inputMyCodinate = UITextView()
    var inputMyDatePicker = UIDatePicker()
    var realTextView = UITextView()
    
    var searchBarField = UISearchBar()
    
    // Tableで使用する配列を設定する
    fileprivate var tableView: UITableView!
    fileprivate var myItems: NSArray = []
    fileprivate var kind: String = ""
    fileprivate var Input: AnyObject = "" as AnyObject
    var palmItems:[String] = []
    var palKind: String = ""
    var palInput: AnyObject = "" as AnyObject
    var palTargetUser: PFObject?
    
    let displayWidth: CGFloat = UIScreen.main.bounds.size.width
    let displayHeight: CGFloat = UIScreen.main.bounds.size.height
    
    var selectedItem: String!
    
    let norificationView = "test"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = UINib(nibName: "PickerView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        //フル画面広告を取得
        _interstitial = showFullAdmob()
        
        self.myItems = palmItems as NSArray
        self.kind = palKind
        self.Input = palInput
        
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        
        
        if (self.kind == "gender" || self.kind == "age") {
            // TableViewの生成す
            self.tableView =
                UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight - navBarHeight!))
            // Cell名の登録をおこなう.
            //self.tableView.rowHeight = 44
            self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
            self.tableView.dataSource = self   // DataSourceの設定をする.
            self.tableView.delegate = self     // Delegateを設定する.
            
            // 不要行の削除
            let notUserRowView = UIView(frame: CGRect.zero)
            notUserRowView.backgroundColor = UIColor.lightGray
            self.tableView.tableFooterView = notUserRowView

            self.view.addSubview(tableView)
            
        } else if self.kind == "name" {
            
            inputTextField.frame = CGRect(x: 10, y: 20, width: displayWidth - 20 , height: 30)
            inputTextField.borderStyle = UITextBorderStyle.roundedRect
            inputTextField.text = self.Input as? String
            self.view.addSubview(inputTextField)
            
            createInsertDataButton(displayWidth, displayHeight: 200)
            
        } else if self.kind == "comment" {
            createCommentField(displayWidth, displayHeight: 200)
            
        } else if self.kind == "imakokoDateFrom" {
            createDatePickerField(displayWidth)
            
        } else if self.kind == "imakokoDateTo" {
            createDatePickerField(displayWidth)
            
        } else if self.kind == "imakoko" {
            createCommentField(displayWidth, displayHeight: 200)
            
            
        } else if self.kind == "imaiku" {
            createDatePickerField(displayWidth)
            //            self.navigationItem.title = "待ち合わせまでにかかる時間"
            //            self.navigationController!.navigationBar.tintColor = UIColor.white
            //
            //            tableView = UITableView(frame: CGRect(x: 0, y: navBarHeight!, width: displayWidth, height: displayHeight - navBarHeight!))
            //
            //            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
            //            tableView.dataSource = self
            //            tableView.delegate = self
            //
            //            let view:UIView = UIView(frame: CGRect.zero)
            //            view.backgroundColor = UIColor.clear
            //            tableView.tableFooterView = view
            //            tableView.tableHeaderView = view
            //            self.view.addSubview(tableView)
            
        } else if self.kind == "imageView" {
            let displaySize = UIScreen.main.bounds.size.width
            
            let image = self.palInput as! UIImageView
            image.layer.borderWidth = 0
            image.layer.cornerRadius = 0
            image.frame = CGRect(x: 0, y: 0, width: displaySize, height: displaySize);
            self.view.addSubview(image)
            
        } else if self.kind == "search" {
            self.navigationItem.title = "Twitter検索"
            self.searchBarField = UISearchBar()
            self.searchBarField.delegate = self
            self.searchBarField.frame = CGRect(x: 10, y: 30, width: displayWidth - 20 , height: 40)
            self.searchBarField.searchBarStyle = .minimal
            self.searchBarField.enablesReturnKeyAutomatically = true
            self.searchBarField.placeholder = "Twitter ID を入力してください"
            self.view.addSubview(self.searchBarField)
            
        } else if self.kind == "notificationSettings" {
            let status = UIApplication.shared.currentUserNotificationSettings?.types
            if (status?.contains(.alert))! {
                print("Alert ON")
                
                let navHaight = self.navigationController?.navigationBar.frame.size.height
                self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight - navHaight!))
                self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
                self.tableView.dataSource = self
                self.tableView.delegate = self
                
                let notificationTableView = UIView(frame: CGRect.zero)
                notificationTableView.backgroundColor = UIColor.clear
                self.tableView.tableFooterView = notificationTableView
                self.tableView.tableHeaderView = notificationTableView
                self.view.addSubview(self.tableView)
                self.tableView.reloadData()
                
            } else{
                
                let label = UILabel(frame: CGRect(x: 10, y: 20, width:  displayWidth - 10,height:  10));
                label.text = "Machinbo から通知を受信しない設定になっています。通知を受信をしたい場合は、アプリの設定を有効にしてください。"
                label.font = UIFont.italicSystemFont(ofSize: UIFont.labelFontSize)
                label.numberOfLines = 0
                label.sizeToFit()
                self.view.addSubview(label)
                
                // open app setting buttom
                createNotificationSettingsButton(displayWidth: displayWidth, displayHeight: 200)
            }
        }
    }
    
    func createDatePickerField(_ displayWidth: CGFloat) {
        // UIDatePickerの設定
        self.inputMyDatePicker = UIDatePicker()
        self.inputMyDatePicker.datePickerMode = UIDatePickerMode.dateAndTime
        self.view.addSubview(self.inputMyDatePicker)
        
        createInsertDataButton(displayWidth, displayHeight: 300)
    }
    
    func createCommentField(_ displayWidth: CGFloat, displayHeight: CGFloat) {
        
        inputTextView.frame = CGRect(x: 10, y: 20, width: displayWidth - 20 ,height: 80)
        inputTextView.text = self.Input as? String
        inputTextView.layer.masksToBounds = true
        inputTextView.layer.cornerRadius = 5.0
        inputTextView.layer.borderWidth = 1
        inputTextView.layer.borderColor = UIColor.gray.cgColor
        inputTextView.font = UIFont.systemFont(ofSize: CGFloat(15))
        inputTextView.textAlignment = NSTextAlignment.left
        inputTextView.selectedRange = NSMakeRange(0, 0)
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.view.addSubview(inputTextView)
        
        createInsertDataButton(displayWidth, displayHeight: 200)
    }
    
    func createInsertDataButton(_ displayWidth: CGFloat, displayHeight: CGFloat) {
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xB54241)
        btn.setTitle("保存", for: UIControlState())
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.layer.position = CGPoint(x: displayWidth/2, y: displayHeight)
        btn.addTarget(self, action: #selector(onClickSaveButton), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(btn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    internal func onClickSaveButton(_ sender: UIButton){
        if (self.kind == "name") {
            if self.inputTextField.text!.isEmpty {
                UIAlertController.showAlertView("", message: "名前を入力してください") { _ in
                    return
                }
            }
            
            var userInfo = PersistentData.User()
            if userInfo.userID == "" {
                self.delegate!.setInputValue(self.inputTextField.text!, type: .name)
                self.navigationController!.popViewController(animated: true)
                
                return
            }
            
            ParseHelper.getMyUserInfomation(PersistentData.User().userID) { (error: NSError?, result: PFObject?) -> Void in
                guard let result = result else {
                    return
                }
                
                result["Name"] = self.inputTextField.text
                result.saveInBackground()
                
                userInfo.name = self.inputTextField.text!
                
                self.delegate!.setInputValue(self.inputTextField.text!, type: .name)
                self.navigationController!.popViewController(animated: true)
            }
            
            
        } else if (self.kind == "comment") {
            
            if self.inputTextView.text.isEmpty {
                UIAlertController.showAlertView("", message: "コメントを入力してください") { _ in
                    return
                }
            }
            
            var userInfo = PersistentData.User()
            if userInfo.userID == "" {
                self.delegate!.setInputValue(self.inputTextView.text, type: .comment)
                self.navigationController!.popViewController(animated: true)
                return
            }
            
            //local db に値が格納されている場合、それを元にユーザ情報を検索してコメントを更新
            ParseHelper.getMyUserInfomation(PersistentData.User().userID) { (error: NSError?, result: PFObject?) -> Void in
                guard let result = result else {
                    return
                }
                
                result["Comment"] = self.inputTextView.text
                result.saveInBackground()
                
                userInfo.comment = self.inputTextView.text
                
                self.delegate!.setInputValue(self.inputTextView.text, type: .comment)
                self.navigationController!.popViewController(animated: true)
            }
            
        } else if self.kind == "imakokoDateFrom" {
            self.delegate!.setSelectedDate(self.inputMyDatePicker.date)
            self.navigationController!.popViewController(animated: true)
            
        } else if self.kind == "imakokoDateTo" {
            self.delegate!.setSelectedDate(self.inputMyDatePicker.date)
            self.navigationController!.popViewController(animated: true)
            
        } else if self.kind == "imakoko" {
            self.delegate!.setInputValue(self.inputTextView.text, type: .comment)
            self.navigationController!.popViewController(animated: true)
            
        } else if self.kind == "imaiku" {
            MBProgressHUDHelper.show("Loading...")

            let center = NotificationCenter.default as NotificationCenter
            LocationManager.sharedInstance.startUpdatingLocation()
            center.addObserver(self, selector: #selector(self.foundLocation(_:)), name: NSNotification.Name(rawValue: LMLocationUpdateNotification as String as String), object: nil)
            
        }
    }
    
    internal func onClickSearchButton(_ sender: UIButton){
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "Cell" // セルのIDを定数identifierにする。
        var cell: UITableViewCell? // nilになることがあるので、Optionalで宣言
        
        cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        }
        
        if indexPath.section == 0 {
            cell?.accessoryType = .none
            
            if indexPath.row == (self.palInput as? Int) {
                cell?.accessoryType = .checkmark
            }
            
            cell?.textLabel!.text = "\(self.myItems[indexPath.row])"
            
            if self.kind == "notificationSettings" {
                
                // settings able
                let sw = UISwitch(frame: CGRect(x:0,y: 0,width: 60,height: 40))
                
                //sw.center = CGPointMake(displayWidth - 50, cell!.frame.height/2)
                sw.center = CGPoint(x: displayWidth - 50,y: cell!.frame.height/2)
                
                sw.addTarget(self, action: #selector(PickerViewController.onChangeNotificationSwich), for: UIControlEvents.touchUpInside)
                cell?.addSubview(sw)
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (self.kind == "age"){
            if let selected = myItems[indexPath.row] as? String {
                self.delegate!.setSelectedValue(indexPath.row, selectedValue: selected.uppercased(), type: .age)
                self.navigationController!.popViewController(animated: true)
                
            }
            
        } else if (self.kind == "gender"){
            
            if let selected = myItems[indexPath.row] as? String {
                self.delegate!.setSelectedValue(indexPath.row, selectedValue: selected.uppercased(), type: .gender)
                self.navigationController!.popViewController(animated: true)
            }
            
        }
        //        else if (self.kind == "imaiku") {
        //
        //            if let selected = myItems[indexPath.row] as? String {
        //                self.selectedItem = selected
        //
        //                MBProgressHUDHelper.show("Loading...")
        //
        //                let center = NotificationCenter.default as NotificationCenter
        //                LocationManager.sharedInstance.startUpdatingLocation()
        //                center.addObserver(self, selector: #selector(self.foundLocation(_:)), name: NSNotification.Name(rawValue: LMLocationUpdateNotification as String as String), object: nil)
        //            }
        //
        //        }
    }
    
    func foundLocation(_ notif: Notification) {
        
        defer {
            NotificationCenter.default.removeObserver(self)
        }
        
        ParseHelper.getMyUserInfomation(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            
            guard error == nil else { self.errorAction(); return }
            
            let userID = result?.object(forKey: "UserID") as? String
            let targetUserID = self.palTargetUser?.object(forKey: "UserID") as? String
            let targetUserUpdatedAt = self.palTargetUser?.updatedAt
            let targetDeviceToken = self.palTargetUser?.object(forKey: "DeviceToken") as? String
            let name = result?.object(forKey: "Name") as? String
            let gps = self.palTargetUser?.object(forKey: "GPS") as? PFGeoPoint
            
            let query = PFObject(className: "GoNow")
            query["UserID"] = userID
            query["TargetUserID"] = targetUserID
            query["User"] = result
            query["TargetUser"] = self.palTargetUser
            query["unReadFlag"] = true
            query["IsApproved"] = false
            query["isDeleteUser"] = false
            query["isDeleteTarget"] = false
            query["gotoAt"] = self.inputMyDatePicker.date
            query["imakokoAt"] = targetUserUpdatedAt
            query["meetingGeoPoint"] = gps
            
            query.saveInBackground { (success: Bool, error: Error?) -> Void in
                
                defer { MBProgressHUDHelper.hide() }
                guard error == nil else { self.errorAction();return }
                
                var userInfo = PersistentData.User()
                userInfo.imaikuFlag = true
                
                ParseHelper.countUnRead(targetUserID!){ (error: NSError?, result: Int?) -> Void in
                    
                    guard error == nil else {
                        self.errorAction()
                        return
                    }
                    
                    // イマ行く対象のIDを local DB へセット
                    var userInfo = PersistentData.User()
                    userInfo.targetUserID = targetUserID!
                    
                    // Send Notification
                    NotificationHelper.sendSpecificDevice(name! + "さんより「いまから行く」されました", deviceTokenAsString: targetDeviceToken!, badges: result! as Int)
                }
                
                // 表示完了時の処理
                if self._interstitial!.isReady {
                    self._interstitial!.present(fromRootViewController: self)
                }
                
                self.navigationController!.popToRootViewController(animated: true)
                
                UIAlertController.showAlertView("", message: "待ち合わせを申請しました")
            }
        }
        
    }
    
    func errorAction() {
        MBProgressHUDHelper.hide()
        UIAlertController.showAlertView("", message: "通信エラーが発生しました。再実行してください。") { action in
            self.navigationController!.popToRootViewController(animated: true)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchStr = searchBarField.text else {
            return
        }
        
        MBProgressHUDHelper.show("Loading...")
        
        ParseHelper.getUserInfomationFromTwitter(searchStr) { (error: NSError?, result: PFObject?) -> Void in
            
            defer {
                MBProgressHUDHelper.hide()
            }
            
            guard result != nil else {
                UIAlertController.showAlertView("", message:"ユーザが存在しないか募集停止中です")
                return
            }
            
            let vc = TargetProfileViewController(type: ProfileType.targetProfile)
            vc.userInfo = result!
            
            self.navigationController!.pushViewController(vc, animated: false)
        }
        
        self.view.endEditing(true)
    }
    
    
    func createNotificationSettingsButton(displayWidth: CGFloat, displayHeight: CGFloat) {
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 350, height: 40))
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xB54241)
        btn.setTitle("go to ios settings", for: .normal)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.layer.position = CGPoint(x: displayWidth/2, y: displayHeight)
        btn.addTarget(self, action: #selector(openAppSettingPage), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(btn)
    }
    
    func openAppSettingPage() -> Void {
        //let application = UIApplication.sharedApplication()
        
        let url = NSURL(string:UIApplicationOpenSettingsURLString)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url as URL)
        }
    }
    func onChangeNotificationSwich(sender: UISwitch) {
        
        // save to local db
        var userInfo = PersistentData.User()
        userInfo.isReceiveMassageHide = sender.isOn
    }
}
