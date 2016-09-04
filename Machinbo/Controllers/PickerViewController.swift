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

extension PickerViewController: TransisionProtocol {}

enum SelectPickerType { case Gender, Age }
enum InputPickerType { case Comment, Name }

protocol PickerViewControllerDelegate{
    func setInputValue(inputValue: String, type: InputPickerType)
    func setSelectedValue(selectedIndex: Int, selectedValue: String, type: SelectPickerType)
    func setSelectedDate(SelectedDate: NSDate)
}

class PickerViewController: UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    GADBannerViewDelegate,
    GADInterstitialDelegate {
    
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
    
    // Tableで使用する配列を設定する
    private var tableView: UITableView!
    private var myItems: NSArray = []
    private var kind: String = ""
    private var Input: AnyObject = ""
    var palmItems:[String] = []
    var palKind: String = ""
    var palInput: AnyObject = ""
    var palTargetUser: PFObject?
    var selectedItem: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = UINib(nibName: "PickerView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        //フル画面広告を取得
        _interstitial = showFullAdmob()
        
        self.myItems = []
        self.myItems = palmItems
        self.kind = palKind
        self.Input = palInput
        
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        
        // Viewの高さと幅を取得する.
        let displayWidth: CGFloat = UIScreen.mainScreen().bounds.size.width
        let displayHeight: CGFloat = UIScreen.mainScreen().bounds.size.height
        
        if (self.kind == "gender" || self.kind == "age") {
            // TableViewの生成す
            tableView = UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight - navBarHeight!))
            
            // Cell名の登録をおこなう.
            tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
            tableView.dataSource = self   // DataSourceの設定をする.
            tableView.delegate = self     // Delegateを設定する.
            
            // 不要行の削除
            let notUserRowView = UIView(frame: CGRectZero)
            notUserRowView.backgroundColor = UIColor.clearColor()
            tableView.tableFooterView = notUserRowView
            tableView.tableHeaderView = notUserRowView
            self.view.addSubview(tableView)
            
        } else if self.kind == "name" {
            
            inputTextField.frame = CGRectMake(10, 20, displayWidth - 20 , 30)
            inputTextField.borderStyle = UITextBorderStyle.RoundedRect
            inputTextField.text = self.Input as? String
            
            self.view.addSubview(inputTextField)
            
            createInsertDataButton(displayWidth, displayHeight: 200)
            
        } else if self.kind == "comment" {
            createCommentField(displayWidth, displayHeight: 200)
            
        } else if self.kind == "imakokoDate" {
            createDatePickerField(displayWidth)
            
        } else if self.kind == "imakoko" {
            createCommentField(displayWidth, displayHeight: 200)
            
        
        } else if self.kind == "imaiku" {
            
            self.navigationItem.title = "待ち合わせまでにかかる時間"
            self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
            
            tableView = UITableView(frame: CGRect(x: 0, y: navBarHeight!, width: displayWidth, height: displayHeight - navBarHeight!))
            
            tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
            tableView.dataSource = self
            tableView.delegate = self
            
            let view:UIView = UIView(frame: CGRectZero)
            view.backgroundColor = UIColor.clearColor()
            tableView.tableFooterView = view
            tableView.tableHeaderView = view
            self.view.addSubview(tableView)
        
        } else if self.kind == "imageView" {
            
            let displaySize = UIScreen.mainScreen().bounds.size.width
            
            let image = self.palInput as! UIImageView
            image.layer.borderWidth = 0
            image.layer.cornerRadius = 0
            image.frame = CGRectMake(0, 0, displaySize, displaySize);
            self.view.addSubview(image)
        }
    }
    
    func createDatePickerField(displayWidth: CGFloat) {
        // UIDatePickerの設定
        self.inputMyDatePicker = UIDatePicker()
        self.inputMyDatePicker.datePickerMode = UIDatePickerMode.DateAndTime
        self.view.addSubview(self.inputMyDatePicker)
        
        createInsertDataButton(displayWidth, displayHeight: 300)
    }
    
    func createCommentField(displayWidth: CGFloat, displayHeight: CGFloat) {

        inputTextView.frame = CGRectMake(10, 20, displayWidth - 20 ,80)
        inputTextView.text = self.Input as? String
        inputTextView.layer.masksToBounds = true
        inputTextView.layer.cornerRadius = 5.0
        inputTextView.layer.borderWidth = 1
        inputTextView.layer.borderColor = UIColor.grayColor().CGColor
        inputTextView.font = UIFont.systemFontOfSize(CGFloat(15))
        inputTextView.textAlignment = NSTextAlignment.Left
        inputTextView.selectedRange = NSMakeRange(0, 0)
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.view.addSubview(inputTextView)
        
        createInsertDataButton(displayWidth, displayHeight: 200)
    }
    
    func createInsertDataButton(displayWidth: CGFloat, displayHeight: CGFloat) {
        
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xB54241)
        btn.setTitle("保存", forState: .Normal)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.layer.position = CGPoint(x: displayWidth/2, y: displayHeight)
        btn.addTarget(self, action: #selector(onClickSaveButton), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(btn)
    }
    
    func onClickInsertPlace() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    internal func onClickSaveButton(sender: UIButton){
        
        if (self.kind == "name") {
            
            if self.inputTextField.text!.isEmpty {
                UIAlertView.showAlertView("", message: "名前を入力してください")
                
                return
            }
            
            var userInfo = PersistentData.User()
            if userInfo.userID == "" {
                self.delegate!.setInputValue(self.inputTextField.text!, type: .Name)
                self.navigationController!.popViewControllerAnimated(true)
                
                return
            }
            
            ParseHelper.getUserInfomation(PersistentData.User().userID) { (error: NSError?, result: PFObject?) -> Void in
                guard let result = result else {
                    return
                }
                
                result["Name"] = self.inputTextField.text
                result.saveInBackground()
                
                userInfo.name = self.inputTextField.text!
                
                self.delegate!.setInputValue(self.inputTextField.text!, type: .Name)
                self.navigationController!.popViewControllerAnimated(true)
            }
            

        } else if (self.kind == "comment") {
            
            if self.inputTextView.text.isEmpty {
                UIAlertView.showAlertView("", message: "コメントを入力してください")
                
                return
            }

            var userInfo = PersistentData.User()
            if userInfo.userID == "" {
                self.delegate!.setInputValue(self.inputTextView.text, type: .Comment)
                self.navigationController!.popViewControllerAnimated(true)
                
                return
            }
            
            //local db に値が格納されている場合、それを元にユーザ情報を検索してコメントを更新
            ParseHelper.getUserInfomation(PersistentData.User().userID) { (error: NSError?, result: PFObject?) -> Void in
                guard let result = result else {
                    return
                }
                
                result["Comment"] = self.inputTextView.text
                result.saveInBackground()
                
                userInfo.comment = self.inputTextView.text
                
                self.delegate!.setInputValue(self.inputTextView.text, type: .Comment)
                self.navigationController!.popViewControllerAnimated(true)
            }
            
        } else if self.kind == "imakokoDate" {
            self.delegate!.setSelectedDate(self.inputMyDatePicker.date)
            self.navigationController!.popViewControllerAnimated(true)
            
        } else if self.kind == "imakoko" {
            self.delegate!.setInputValue(self.inputTextView.text, type: .Comment)
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
    
    /*
    Cellが選択された際に呼び出されるデリゲートメソッド.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (self.kind == "age"){
            if let selected = myItems[indexPath.row] as? String {
                self.delegate!.setSelectedValue(indexPath.row, selectedValue: selected.uppercaseString, type: .Age)
                self.navigationController!.popViewControllerAnimated(true)
                
            }
            
        } else if (self.kind == "gender"){

            if let selected = myItems[indexPath.row] as? String {
                self.delegate!.setSelectedValue(indexPath.row, selectedValue: selected.uppercaseString, type: .Gender)
                self.navigationController!.popViewControllerAnimated(true)
            }
            
        } else if (self.kind == "imaiku") {
            
            if let selected = myItems[indexPath.row] as? String {
                
                self.selectedItem = selected
                
                MBProgressHUDHelper.show("Loading...")
                
                let center = NSNotificationCenter.defaultCenter() as NSNotificationCenter
                
                LocationManager.sharedInstance.startUpdatingLocation()
                center.addObserver(self, selector: #selector(self.foundLocation(_:)), name: LMLocationUpdateNotification as String, object: nil)
            }
            
        }
    }
    
    func foundLocation(notif: NSNotification) {
        
        defer {
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
        
        ParseHelper.getUserInfomation(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            
            guard error == nil else {
                self.errorAction()
                return
            }
            
            let userID = result?.objectForKey("UserID") as? String
            let targetUserID = self.palTargetUser?.objectForKey("UserID") as? String
            let targetUserUpdatedAt = self.palTargetUser?.updatedAt
            let targetDeviceToken = self.palTargetUser?.objectForKey("DeviceToken") as? String
            let name = result?.objectForKey("Name") as? String
            
            let query = PFObject(className: "GoNow")
            query["UserID"] = userID
            query["TargetUserID"] = targetUserID
            query["User"] = result
            query["TargetUser"] = self.palTargetUser
            query["unReadFlag"] = true
            
            let endPoint = self.selectedItem.characters.count - 1
            let selected = (self.selectedItem as NSString).substringToIndex(endPoint)
            let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
            let gotoAtMinute = Int(selected)
            let createdAtDate = NSDate()
            let arriveTime = calendar.dateByAddingUnit(.Minute, value: gotoAtMinute!, toDate: createdAtDate, options: NSCalendarOptions())!
            
            query["gotoAt"] = arriveTime
            query["imakokoAt"] = targetUserUpdatedAt
            
            let info = notif.userInfo as NSDictionary!
            var location = info[LMLocationInfoKey] as! CLLocation
            
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            query["userGPS"] = PFGeoPoint(latitude: latitude, longitude: longitude)
            
            query.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                
                defer {
                    MBProgressHUDHelper.hide()
                    
                    // user_info の未読数を取得しpush
                    ParseHelper.countUnRead(targetUserID!){ (error: NSError?, result: Int?) -> Void in
                        
                        guard error == nil else {
                            return
                        }
                        
                        // イマ行く対象のIDを local DB へセット
                        var userInfo = PersistentData.User()
                        userInfo.targetUserID = targetUserID!
                        
                        // Send Notification
                        NotificationHelper.sendSpecificDevice(name! + "さんより「いまから行く」されました。", deviceTokenAsString: targetDeviceToken!, badges: result! as Int)
                    }

                }
                
                guard error == nil else {
                    self.errorAction()
                    return
                }
                
                var userInfo = PersistentData.User()
                userInfo.imaikuFlag = true
                
                UIAlertView.showAlertDismiss("", message: "いまから行くことを送信しました") { () -> () in
                    if self._interstitial!.isReady {
                        self._interstitial!.presentFromRootViewController(self)
                    }
                    
                    self.navigationController!.popToRootViewControllerAnimated(true)
                }
            }
        }

    }
    
    func errorAction() {
        MBProgressHUDHelper.hide()
        UIAlertView.showAlertDismiss("", message: "通信エラーが発生しました。再実行してください。") { () -> () in
            self.navigationController!.popToRootViewControllerAnimated(true)
        }
    }
    
    
    /*
    Cellの総数を返すデータソースメソッド.
    (実装必須)
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myItems.count
    }
    
    /*
    Cellに値を設定するデータソースメソッド.
    (実装必須)
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier = "Cell" // セルのIDを定数identifierにする。
        var cell: UITableViewCell? // nilになることがあるので、Optionalで宣言
        
        cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil { // 再利用するセルがなかったら（不足していたら）
            // セルを新規に作成する。
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identifier)
        }
        
        
        if indexPath.section == 0 {
            
            cell?.accessoryType = .None
            
            if indexPath.row == (self.palInput as? Int) {
                cell?.accessoryType = .Checkmark
            }
            
            cell?.textLabel!.text = "\(self.myItems[indexPath.row])"
        }
        
        return cell!
    }

}