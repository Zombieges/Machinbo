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

enum SelectPickerType { case gender, age }
enum InputPickerType { case comment, name }

enum PickerKind {
    case gender
    case age
    case name
    case comment
    case imakokoDateFrom
    case imakokoDateTo
    case imakoko
    case imaiku
    case imageView
    case search
    case notificationSettings
    case yakkan
}

extension PickerViewController: TransisionProtocol {}

protocol PickerViewControllerDelegate{
    func setInputValue(_ inputValue: String, type: InputPickerType)
    func setSelectedValue(_ selectedIndex: Int, selectedValue: String, type: SelectPickerType)
    func setSelectedDate(_ SelectedDate: Date)
}

class PickerViewController: UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    GADBannerViewDelegate,
    GADInterstitialDelegate,
UISearchBarDelegate {
    
    var delegate: PickerViewControllerDelegate?
    var _interstitial: GADInterstitial?
    
    private var inputTextView = UITextView()
    private var inputTextField = UITextField()
    private var inputPlace = UITextView()
    private var inputMyCodinate = UITextView()
    private var inputMyDatePicker = UIDatePicker()
    private var realTextView = UITextView()
    private var searchBarField = UISearchBar()
    
    // Tableで使用する配列を設定する
    private var tableView: UITableView!
    private var myItems = [String]()
    private var inputValue: AnyObject = "" as AnyObject

    private let displayWidth = UIScreen.main.bounds.size.width
    private let displayHeight = UIScreen.main.bounds.size.height
    
    private let sections = [" ", " "]
    
    var palKind: PickerKind!
    var palInput: AnyObject = "" as AnyObject
    var palTargetUser: PFObject?
    
    init(kind: PickerKind, inputValue: AnyObject = "" as AnyObject) {
        self.palKind = kind
        self.palInput = inputValue
        //self.palTargetUser = targetUser
        
        super.init(nibName: nil, bundle: nil)  
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = UINib(nibName: "PickerView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        //フル画面広告を取得
        _interstitial = showFullAdmob()
        
        self.inputValue = palInput
        
        if self.palKind == .gender {
            self.navigationItem.title = "性別"
            self.myItems = ["男性","女性"]
            self.setTableView()

        } else if self.palKind == .age {
            self.navigationItem.title = "年齢"
            let comp = (Calendar.current as NSCalendar).components(NSCalendar.Unit.year, from: Date())
            for i in 0...50 {
                self.myItems.append((String(comp.year! - i)))
            }
            self.setTableView()

        } else if self.palKind == .name {
            self.navigationItem.title = "名前"
            
            self.inputTextField = UITextField()
            self.inputTextField.frame = CGRect(x: 10, y: 20, width: UIScreen.main.bounds.size.width - 20 , height: 30)
            self.inputTextField.borderStyle = .roundedRect
            self.inputTextField.text = self.inputValue as? String
            self.view.addSubview(self.inputTextField)
            
            createInsertDataButton(displayWidth, displayHeight: 200)
        
        } else if self.palKind == .comment {
            createCommentField(displayWidth, displayHeight: 200)
            
        } else if self.palKind == .imakokoDateFrom {
            self.navigationItem.title = "待ち合わせ開始時間"
            createDatePickerField(displayWidth)
            
        } else if self.palKind == .imakokoDateTo {
            self.navigationItem.title = "待ち合わせ終了時間"
            createDatePickerField(displayWidth)
            
        } else if self.palKind == .imakoko {
            createCommentField(displayWidth, displayHeight: 200)
            
            
        } else if self.palKind == .imaiku {
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
            
        } else if self.palKind == .imageView {
            let displaySize = UIScreen.main.bounds.size.width
            
            let image = self.palInput as! UIImageView
            image.layer.borderWidth = 0
            image.layer.cornerRadius = 0
            image.frame = CGRect(x: 0, y: 0, width: displaySize, height: displaySize);
            self.view.addSubview(image)
            
        } else if self.palKind == .search {
            self.navigationItem.title = "Twitter検索"
            self.searchBarField = UISearchBar()
            self.searchBarField.delegate = self
            self.searchBarField.frame = CGRect(x: 10, y: 30, width: displayWidth - 20 , height: 40)
            self.searchBarField.searchBarStyle = .minimal
            self.searchBarField.enablesReturnKeyAutomatically = true
            self.searchBarField.placeholder = "Twitter ID を入力してください"
            self.view.addSubview(self.searchBarField)
            
        } else if self.palKind == .notificationSettings {
            let status = UIApplication.shared.currentUserNotificationSettings?.types
            if (status?.contains(.alert))! {
                
                
                let label = UILabel(frame: CGRect(x: 10, y: 20, width:  displayWidth - 10,height:  10));
                label.text = "Machinbo から通知を受信する設定になっています。通知を受信をしたくない場合は、アプリの設定を無効にしてください。"
                label.font = UIFont.italicSystemFont(ofSize: UIFont.labelFontSize)
                label.numberOfLines = 0
                label.sizeToFit()
                self.view.addSubview(label)
                
                
                let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: displayWidth - 20, height: 50))
                btn.trackTouchLocation = true
                btn.layer.borderColor = LayoutManager.getUIColorFromRGB(0x0D47A1).cgColor
                btn.layer.borderWidth = 1.0
                btn.setTitleColor(LayoutManager.getUIColorFromRGB(0x0D47A1), for: UIControlState())
                btn.setTitle("通知設定画面", for: UIControlState())
                btn.layer.cornerRadius = 0
                btn.layer.masksToBounds = true
                btn.layer.position = CGPoint(x: displayWidth/2, y: 200)
                btn.addTarget(self, action: #selector(openAppSettingPage), for: UIControlEvents.touchUpInside)
                
                self.view.addSubview(btn)

                
            } else{
                
                let label = UILabel(frame: CGRect(x: 10, y: 20, width:  displayWidth - 10,height:  10));
                label.text = "Machinbo から通知を受信しない設定になっています。通知を受信をしたい場合は、アプリの設定を有効にしてください。"
                label.font = UIFont.italicSystemFont(ofSize: UIFont.labelFontSize)
                label.numberOfLines = 0
                label.sizeToFit()
                self.view.addSubview(label)
                
                
                let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: displayWidth - 20, height: 50))
                btn.trackTouchLocation = true
                btn.backgroundColor = LayoutManager.getUIColorFromRGB(0x0D47A1, alpha: 0.8)
                btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0x0D47A1, alpha: 0.8)
                btn.rippleColor = LayoutManager.getUIColorFromRGB(0x1976D2)
                btn.setTitle("通知設定画面", for: UIControlState())
                //btn.addTarget(self, action: #selector(self.didClickImageView), for: UIControlEvents.touchUpInside)
                btn.layer.cornerRadius = 0
                btn.layer.masksToBounds = true
                btn.layer.position = CGPoint(x: displayWidth/2, y: 200)
                btn.addTarget(self, action: #selector(openAppSettingPage), for: UIControlEvents.touchUpInside)
                
                self.view.addSubview(btn)
            }
        }
    }
    
    func setTableView() {
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        let rect = CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight - navBarHeight!)
        self.tableView = UITableView(frame:rect, style: .grouped)
        self.tableView.layer.backgroundColor = UIColor.lightGray.cgColor
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        self.tableView.dataSource = self   // DataSourceの設定をする.
        self.tableView.delegate = self     // Delegateを設定する.
        
        self.view.addSubview(tableView)
    }
    
    func createDatePickerField(_ displayWidth: CGFloat) {
        // UIDatePickerの設定
        self.inputMyDatePicker = UIDatePicker()
        self.inputMyDatePicker.frame = CGRect(x: 0, y: 0, width: displayWidth, height: displayWidth / 2)
        self.inputMyDatePicker.datePickerMode = .dateAndTime
        self.inputMyDatePicker.backgroundColor = UIColor.white
        self.view.addSubview(self.inputMyDatePicker)
        
        createInsertDataButton(displayWidth, displayHeight: 300)
    }
    
    func createCommentField(_ displayWidth: CGFloat, displayHeight: CGFloat) {
        
        inputTextView.frame = CGRect(x: 10, y: 20, width: displayWidth - 20 ,height: 60)
        inputTextView.text = self.inputValue as? String
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
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: displayWidth - 20, height: 50))
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0x0D47A1, alpha: 0.8)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0x0D47A1, alpha: 0.8)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0x1976D2)
        btn.setTitle("保存", for: UIControlState())
        btn.layer.cornerRadius = 0
        btn.layer.masksToBounds = true
        btn.layer.position = CGPoint(x: displayWidth/2, y: displayHeight)
        btn.addTarget(self, action: #selector(onClickSaveButton), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(btn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    internal func onClickSaveButton(_ sender: UIButton){
        if self.palKind == PickerKind.name {
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
            
            
        } else if self.palKind == PickerKind.comment {
            
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
            
        } else if self.palKind == PickerKind.imakokoDateFrom {
            self.delegate!.setSelectedDate(self.inputMyDatePicker.date)
            self.navigationController!.popViewController(animated: true)
            
        } else if self.palKind == PickerKind.imakokoDateTo {
            self.delegate!.setSelectedDate(self.inputMyDatePicker.date)
            self.navigationController!.popViewController(animated: true)
            
        } else if self.palKind == PickerKind.imakoko {
            self.delegate!.setInputValue(self.inputTextView.text, type: .comment)
            self.navigationController!.popViewController(animated: true)
            
        } else if self.palKind == PickerKind.imaiku {
            MBProgressHUDHelper.show("Loading...")

            let center = NotificationCenter.default as NotificationCenter
            LocationManager.sharedInstance.startUpdatingLocation()
            center.addObserver(self, selector: #selector(self.foundLocation(_:)), name: NSNotification.Name(rawValue: LMLocationUpdateNotification as String as String), object: nil)
            
        }
    }
    
    internal func onClickSearchButton(_ sender: UIButton){
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return sections[section]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.myItems.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "Cell" // セルのIDを定数identifierにする。

        if indexPath.section == 0 {
            var cell: UITableViewCell? // nilになることがあるので、Optionalで宣言
            
            cell = tableView.dequeueReusableCell(withIdentifier: identifier)
            if cell == nil {
                cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
            }
            
            cell?.accessoryType = .none
            
            if indexPath.row == (self.palInput as? Int) {
                cell?.accessoryType = .checkmark
            }
            
            cell?.textLabel!.text = "\(self.myItems[indexPath.row])"
            
            return cell!
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.palKind == PickerKind.age {
            if let selected = myItems[indexPath.row] as? String {
                self.delegate!.setSelectedValue(indexPath.row, selectedValue: selected.uppercased(), type: .age)
                self.navigationController!.popViewController(animated: true)
                
            }
            
        } else if self.palKind == PickerKind.gender {
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

                // イマ行く対象のIDを local DB へセット
                userInfo.targetUserID = targetUserID!
                
                
                // Send Notification
                NotificationHelper.sendSpecificDevice(name! + "さんより「いまから行く」されました", deviceTokenAsString: targetDeviceToken!, badges: 1 as Int)
                
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
            vc.targetUserInfo = result!
            
            self.navigationController!.pushViewController(vc, animated: false)
        }
        
        self.view.endEditing(true)
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
}
