//
//  ProfileViewController.swift
//  Machinbo
//
//  Created by Kazuhiro Watanabe on 2015/07/05.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import UIKit
import Photos
import Parse
import SpriteKit
import MBProgressHUD
import GoogleMobileAds

extension ProfileViewController: TransisionProtocol {}

class ProfileViewController: UIViewController, UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    UIPickerViewDelegate,
    PickerViewControllerDelegate ,
    UITableViewDelegate,
    GADBannerViewDelegate{
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var startButton: ZFRippleButton!
    @IBOutlet weak var TableView: UITableView!
    
    let photoItems: [String] = ["フォト"]
    let otherItems: [String] = ["名前", "性別", "生まれた年", "プロフィール"]
    
    let sections: NSArray = ["プロフィール"]
    
    var mainNavigationCtrl: UINavigationController?
    var picker: UIImagePickerController?
    var window: UIWindow?
    var FarstTimeStart : Bool = false
    
    var myItems:[String] = []
    
    var gender: String?
    var age: String?
    var inputName: String = ""
    var selectedAge: String = ""
    var selectedGender: String = ""
    var inputComment: String = ""
    
    let identifier = "Cell" // セルのIDを定数identifierにする。
    var cell: UITableViewCell? // nilになることがあるので、Optionalで宣言
    let detailTableViewCellIdentifier: String = "DetailCell"
    
    
    //var userInfo: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = UINib(nibName: "ProfileView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        // profilePicture をタップできるように設定
        profilePicture.userInteractionEnabled = true
        let myTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.tapGesture(_:)))
        profilePicture.addGestureRecognizer(myTap)
        
        let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle:nil)
        TableView.registerNib(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
        TableView.estimatedRowHeight = 200.0
        TableView.rowHeight = UITableViewAutomaticDimension
        
        // 余分な境界線を消す
        TableView.tableFooterView = UIView()
        
        view.addSubview(TableView)
        
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        let userData = PersistentData.User()
        if userData.userID == "" {
            self.navigationItem.title = "プロフィールを登録してください"
            // 初期画像
            profilePicture.image = UIImage(named: "photo.png")
            
        } else {
            self.navigationItem.title = "プロフィール"
            //スタートボタンは非表示
            startButton.hidden = true
            
            /* 設定ボタンを付与 */
            let settingsButton: UIButton = UIButton(type: UIButtonType.Custom)
            settingsButton.setImage(UIImage(named: "santen.png"), forState: UIControlState.Normal)
            settingsButton.addTarget(self, action: #selector(ProfileViewController.onClickSettingView), forControlEvents: UIControlEvents.TouchUpInside)
            settingsButton.frame = CGRectMake(0, 0, 22, 22)
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
            
            // 通常の画面遷移
            profilePicture.image = userData.profileImage
            inputName = userData.name
            age = userData.age
            selectedAge = userData.age
            gender = userData.gender
            selectedGender = String(userData.gender)
            inputComment = userData.comment
        }

        imageMolding(profilePicture)
        
        if self.isInternetConnect() {
            //広告を表示
            self.showAdmob()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // profilePicture タップ時の処理
    internal func tapGesture(sender: UITapGestureRecognizer){
        
        picker = UIImagePickerController()
        picker?.delegate = self
        picker?.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker?.allowsEditing = false
        
        presentViewController(picker!, animated: true, completion: nil)
    }
    
    
    // 写真選択時の処理
    internal func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let resizedSize = CGSize(width: 93, height: 93)
        UIGraphicsBeginImageContext(resizedSize)
        
        image.drawInRect(CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        profilePicture.image = resizedImage
        
        imageMolding(profilePicture)
        
        var userInfo = PersistentData.User()
        if userInfo.userID != "" {

            ParseHelper.getUserInfomation(userInfo.userID) { (error: NSError?, result: PFObject?) -> Void in
                if let result = result {
                    let imageData = UIImagePNGRepresentation(self.profilePicture.image!)
                    let imageFile = PFFile(name:"image.png", data:imageData!)
                    
                    result["ProfilePicture"] = imageFile
                    result.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                        
                        userInfo.profileImage = self.profilePicture.image!
                        //self.navigationController!.popViewControllerAnimated(true)
                    }
                    
                }
            }
        }
    }
    
    // 写真選択画面でキャンセルした場合の処理
    internal func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // PickerViewController より性別を選択した際に実行される処理
    internal func setGender(selectedIndex: Int,selected: String) {
        
        gender = selected
        selectedGender = selected
        
        // テーブル再描画
        TableView.reloadData()
    }
    
    // PickerViewController より年齢を選択した際に実行される処理
    internal func setAge(selectedIndex: Int,selected: String) {
        
        age = String(selectedIndex)
        selectedAge = selected
        
        // テーブル再描画
        TableView.reloadData()
    }
    
    // PickerViewController よりを保存ボタンを押下した際に実行される処理
    internal func setName(name: String) {
        
        inputName = name
        
        // テーブル再描画
        TableView.reloadData()
    }
    
    // PickerViewController よりを保存ボタンを押下した際に実行される処理
    internal func setComment(comment: String) {
        
        inputComment = comment
        
        // テーブル再描画
        TableView.reloadData()
    }
    
    /*
    テーブルに表示する配列の総数を返す.
    */
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return otherItems.count
    }
    
    /*
    セクションの数を返す.
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    /*
    セクションのタイトルを返す.
    */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section] as? String
    }
    /*
    Cellに値を設定する.
    */
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tableViewCellIdentifier = "Cell"
        
        // セルを再利用する。
        cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil { // 再利用するセルがなかったら（不足していたら）
            // セルを新規に作成する。
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identifier)
        }
        
        
        if indexPath.section == 0 {
            if indexPath.row < 3 {
                
                var normalCell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier)
                if normalCell == nil { // 再利用するセルがなかったら（不足していたら）
                    // セルを新規に作成する。
                    normalCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: tableViewCellIdentifier)
                }
                
                if indexPath.row == 0 {
                    normalCell?.textLabel?.text = otherItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = inputName as String
                    
                } else if indexPath.row == 1 {
                    normalCell?.textLabel?.text = otherItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = selectedGender as String
                    
                } else if indexPath.row == 2 {
                    normalCell?.textLabel?.text = otherItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = selectedAge as String
                    
                }
                
                
                cell = normalCell
                
            } else {
                
                let detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell
                
                if indexPath.row == 3 {
                    
                    detailCell?.titleLabel.text = otherItems[indexPath.row]
                    detailCell?.valueLabel.text = inputComment as String
                    
                }
                
                cell = detailCell
            }
        }
        
        return cell!
    }
    
    // セルがタップされた時
    internal func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        
        myItems = []
        let vc = PickerViewController()
        
        if PersistentData.User().userID != "" {
            if indexPath.row == 1 {
                UIAlertView.showAlertDismiss("", message: "性別は変更することができません") {}
                return
                
            } else if indexPath.row == 2 {
                UIAlertView.showAlertDismiss("", message: "生まれた年は変更することができません") {}
                return
            }
        }
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
                vc.palmItems = myItems
                vc.palKind = "name"
                vc.palInput = inputName
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 1 {
                
                myItems = ["男性","女性"]
                vc.palmItems = myItems
                vc.palKind = "gender"
                if let gender = gender{
                    
                    vc.palInput = gender
                }
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 2 {
                
                let date = NSDate()      // 現在日時
                let calendar = NSCalendar.currentCalendar()
                let comp : NSDateComponents = calendar.components(
                    NSCalendarUnit.Year, fromDate: date)
                
                for i in 0...50 {
                    myItems.append((String(comp.year - i)))
                }
                
                vc.palmItems = myItems
                vc.palKind = "age"
                if let age = age{
                    
                    vc.palInput = age
                }
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 3 {
                
                
                vc.palmItems = myItems
                vc.palKind = "comment"
                vc.palInput = inputComment
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    @IBAction func pushStart(sender: AnyObject) {
        
        MBProgressHUDHelper.show("Loading...")

        // 必須チェック
        if inputName.isEmpty {
            UIAlertView.showAlertView("", message: "名前を入力してください")
            return
        }
        
        if selectedGender.isEmpty {
            UIAlertView.showAlertView("", message: "性別を選択してください")
            return
        }
        
        if selectedAge.isEmpty {
            UIAlertView.showAlertView("", message: "生まれた年を選択してください")
            return
        }
        
        MBProgressHUDHelper.show("Loading...")
        
        let imageData = UIImagePNGRepresentation(profilePicture.image!)
        let imageFile = PFFile(name:"image.png", data:imageData!)
        let uuid = NSUUID().UUIDString
        
        NSLog("UUID" + uuid)
        
        // 登録
        ParseHelper.setUserInfomation(
            uuid,
            name: inputName,
            gender: gender!,
            age: selectedAge,
            comment: inputComment,
            photo: imageFile!
        )
        
        var userInfo = PersistentData.User()
        userInfo.userID = uuid
        userInfo.name = inputName
        userInfo.gender = selectedGender
        userInfo.age = selectedAge
        userInfo.comment = inputComment
        
        let newRootVC = MapViewController()
        let navigationController = UINavigationController(rootViewController: newRootVC)
        navigationController.navigationBar.barTintColor = LayoutManager.getUIColorFromRGB(0x3949AB)
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        UIApplication.sharedApplication().keyWindow?.rootViewController = navigationController
        
        MBProgressHUDHelper.hide()
        
    }
    
    private func imageMolding(target : UIImageView){
        target.layer.borderColor = UIColor.whiteColor().CGColor
        target.layer.borderWidth = 3
        target.layer.cornerRadius = 10
        target.layer.masksToBounds = true
    }
    
    func onClickSettingView() {
        let vc = SettingsViewController()
        self.navigationController!.pushViewController(vc, animated: true)
    }
}