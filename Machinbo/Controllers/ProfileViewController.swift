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
import TwitterKit

extension ProfileViewController: TransisionProtocol {}

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDelegate, PickerViewControllerDelegate, UITableViewDelegate, GADBannerViewDelegate, GADInterstitialDelegate{
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var startButton: ZFRippleButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var imakokoButton: UIButton!
    
    
    private let photoItems = ["フォト"]
    private let profileItems = ["名前", "性別", "生まれた年", "Twitter", "プロフィール"]
    private let otherItems = ["登録時間", "場所", "特徴"]
    private let sections = ["プロフィール", "待ち合わせ情報"]
    
    let picker = UIImagePickerController()
    var window: UIWindow?
    var FarstTimeStart = false
    
    var myItems = [String]()
    
    var gender = ""
    var age = ""
    var inputName = ""
    var selectedAge = ""
    var selectedGender = ""
    var inputComment = ""
    
    var twitterID = ""
    
    let identifier = "Cell" // セルのIDを定数identifierにする。
    var cell: UITableViewCell? // nilになることがあるので、Optionalで宣言
    let detailTableViewCellIdentifier: String = "DetailCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = UINib(nibName: "ProfileView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        setProfileGesture()
        initTableView()
        
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        let userData = PersistentData.User()
        guard userData.userID != "" else {
            //初期登録画面
            self.navigationItem.title = "プロフィールを登録してください"
            self.imakokoButton.hidden = true
            profilePicture.image = UIImage(named: "photo.png")
            return
        }
        
        self.navigationItem.title = "プロフィール"
        self.startButton.hidden = true
        
        setNavigationItemSettingButton()
        
        // 通常の画面遷移
        profilePicture.image = userData.profileImage
        inputName = userData.name
        age = userData.age
        selectedAge = userData.age
        gender = userData.gender
        selectedGender = String(userData.gender)
        inputComment = userData.comment
        
        if userData.isRecruitment {
            //募集中の場合
            self.imakokoButton.setTitle("待ち合わせ募集中", forState: .Normal)
            self.imakokoButton.layer.cornerRadius = 5.0
            self.imakokoButton.layer.borderColor = UIView().tintColor.CGColor
            self.imakokoButton.layer.borderWidth = 1.0
            self.imakokoButton.tintColor = UIView().tintColor
        } else {
            self.imakokoButton.setTitle("待ち合わせ募集停止中", forState: .Normal)
            self.imakokoButton.layer.cornerRadius = 5.0
            self.imakokoButton.layer.borderColor = UIColor.redColor().CGColor
            self.imakokoButton.layer.borderWidth = 1.0
            self.imakokoButton.tintColor = UIColor.redColor()
        }
        
        imageMolding(profilePicture)
        showAdmob()
    }
    
    private func showAdmob() {
        if self.isInternetConnect() {
            //広告を表示
            self.showAdmob(AdmobType.standard)
            
        } else {
            self.createRefreshButton()
        }
    }
    
    private func setProfileGesture() {
        // profilePicture をタップできるようにジェスチャーを設定
        profilePicture.userInteractionEnabled = true
        let myTap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        profilePicture.addGestureRecognizer(myTap)
    }
    
    private func initTableView() {
        let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle:nil)
        tableView.registerNib(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
        tableView.estimatedRowHeight = 200.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
    }
    
    private func setNavigationItemSettingButton() {
        /* 設定ボタンを付与 */
        let settingsButton: UIButton = UIButton(type: UIButtonType.Custom)
        settingsButton.setImage(UIImage(named: "santen.png"), forState: UIControlState.Normal)
        settingsButton.addTarget(self, action: #selector(ProfileViewController.onClickSettingView), forControlEvents: UIControlEvents.TouchUpInside)
        settingsButton.frame = CGRectMake(0, 0, 22, 22)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // profilePicture タップ時の処理
    internal func tapGesture(sender: UITapGestureRecognizer){
        self.picker.delegate = self
        self.picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.picker.allowsEditing = false
        
        presentViewController(self.picker, animated: true, completion: nil)
    }
    
    
    // 写真選択時の処理
    internal func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let displaySize = UIScreen.mainScreen().bounds.size.width
        let resizedSize = CGSize(width: displaySize, height: displaySize)
        UIGraphicsBeginImageContext(resizedSize)
        
        image.drawInRect(CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        profilePicture.image = resizedImage
        
        imageMolding(profilePicture)
        
        var userInfo = PersistentData.User()
        guard userInfo.userID != "" else {
            return
        }
        
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
    
    // 写真選択画面でキャンセルした場合の処理
    internal func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // PickerViewController より性別を選択した際に実行される処理
    internal func setSelectedValue(selectedindex: Int, selectedValue: String, type: SelectPickerType) {
        if type == SelectPickerType.Age {
            self.age = String(selectedindex)
            self.selectedAge = selectedValue
            // テーブル再描画
            tableView.reloadData()
            
            
        } else if type == SelectPickerType.Gender {
            self.gender = selectedValue
            self.selectedGender = selectedValue
            // テーブル再描画
            tableView.reloadData()
        }
    }
    
    internal func setInputValue(inputValue: String, type: InputPickerType) {
        if type == InputPickerType.Name {
            self.inputName = inputValue
            // テーブル再描画
            tableView.reloadData()
            
        } else if type == InputPickerType.Comment {
            self.inputComment = inputValue
            // テーブル再描画
            tableView.reloadData()
        }
    }
    
    internal func setSelectedDate(SelectedDate: NSDate) {
        
    }
    
    /*
     テーブルに表示する配列の総数を返す.
     */
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return profileItems.count
            
        } else if section == 1 {
            return otherItems.count
        }
        
        return 0
    }
    
    /*
     セクションの数を返す.
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if PersistentData.User().userID == "" {
            return 1
        }
        
        return sections.count
    }
    
    /*
     セクションのタイトルを返す.
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
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
            if indexPath.row < 4 {
                var normalCell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier)
                normalCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: tableViewCellIdentifier)
                normalCell!.textLabel!.font = UIFont(name: "Arial", size: 15)
                normalCell!.detailTextLabel!.font = UIFont(name: "Arial", size: 15)
                
                if indexPath.row == 0 {
                    normalCell?.textLabel?.text = profileItems[indexPath.row]
                    normalCell?.accessoryType = .DisclosureIndicator
                    normalCell?.detailTextLabel?.text = inputName as String
                    
                } else if indexPath.row == 1 {
                    normalCell?.textLabel?.text = profileItems[indexPath.row]
                    normalCell?.accessoryType = .DisclosureIndicator
                    normalCell?.detailTextLabel?.text = selectedGender as String
                    
                } else if indexPath.row == 2 {
                    normalCell?.textLabel?.text = profileItems[indexPath.row]
                    if !selectedAge.isEmpty {
                        normalCell?.accessoryType = .DisclosureIndicator
                        normalCell?.detailTextLabel?.text = Parser.changeAgeRange(selectedAge) as String
                    }
                    
                } else if indexPath.row == 3 {
                    normalCell?.textLabel?.text = profileItems[indexPath.row] as String
                    normalCell?.imageView?.image = UIImage(named: "logo_twitter.png")
                    normalCell?.accessoryType = .DisclosureIndicator
                    normalCell?.detailTextLabel?.text = twitterID as String
                    
                    let logInButton = TWTRLogInButton(logInCompletion:
                        { (session, error) in
                            if (session != nil) {
                                print("signed in as \(session!.userName)");
                            } else {
                                print("error: \(error!.localizedDescription)");
                            }
                    })
                    logInButton.center = self.view.center
                    self.view.addSubview(logInButton)
                }
                
                cell = normalCell
                
            } else {
                let detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell
                
                if indexPath.row == 4 {
                    detailCell?.titleLabel.text = profileItems[indexPath.row]
                    detailCell?.valueLabel.text = inputComment as String
                }
                
                cell = detailCell
            }
            
        } else if indexPath.section == 1 {
            var normalCell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier)
            if normalCell == nil {
                normalCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: tableViewCellIdentifier)
            }
            
            let userData = PersistentData.User()
            if indexPath.row == 0 {
                normalCell?.textLabel?.text = otherItems[indexPath.row]
                
                let dateFormatter = NSDateFormatter();
                dateFormatter.dateFormat = "yyyy年M月d日 H:mm"
                let formatDateString = userData.insertTime
                
                normalCell?.detailTextLabel?.text = formatDateString
                
                cell = normalCell
                
            } else if indexPath.row == 1 {
                let detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell
                
                detailCell?.titleLabel.text = otherItems[indexPath.row]
                detailCell?.valueLabel.text = userData.place
                
                cell = detailCell
                
            } else if indexPath.row == 2 {
                let detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell
                
                detailCell?.titleLabel.text = otherItems[indexPath.row]
                detailCell?.valueLabel.text = userData.mychar
                
                cell = detailCell
            }
        }
        
        return cell!
    }
    
    // セルがタップされた時
    internal func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        
        let vc = PickerViewController()
        
        myItems = []
        
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
                //                if let gender = gender{
                //
                //                    vc.palInput = gender
                //                }
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
                //                if let age = age{
                //
                //                    vc.palInput = age
                //                }
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 3 {
                //Twitter認証
                
                let sessionStore = Twitter.sharedInstance().sessionStore
                guard let userId = sessionStore.session()?.userID else {
                    Twitter.sharedInstance().logInWithCompletion { session, error in
                        if (session != nil) {
                            print("signed in as \(session!.userName)");
                            
                            self.twitterID = session!.userID
                            
                        } else {
                            print("error: \(error!.localizedDescription)");
                        }
                    }
                    
                    return
                }
                
                //TODO: 認証解除
                sessionStore.logOutUserID(userId)
                
                
            } else if indexPath.row == 4 {
                vc.palmItems = myItems
                vc.palKind = "comment"
                vc.palInput = inputComment
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    @IBAction func pushStart(sender: AnyObject) {
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
        
        // save to local db
        var userInfo = PersistentData.User()
        userInfo.userID = uuid
        userInfo.name = inputName
        userInfo.gender = selectedGender
        userInfo.age = selectedAge
        userInfo.comment = inputComment
        
        // 登録
        ParseHelper.setUserInfomation(
            uuid,
            name: inputName,
            gender: gender,
            age: selectedAge,
            comment: inputComment,
            photo: imageFile!,
            deviceToken: userInfo.deviceToken
        )
        
        let newRootVC = MapViewController()
        let navigationController = UINavigationController(rootViewController: newRootVC)
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        navigationController.navigationBar.barTintColor = UIColor.hex("2F469C", alpha: 1)
        navigationController.navigationBar.translucent = false
        navigationController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController.navigationBar.shadowImage = UIImage()
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
    
    @IBAction func imakokoAction(sender: AnyObject) {
        
        var userData = PersistentData.User()
        
        if userData.isRecruitment {
            
            UIAlertView.showAlertOKCancel("募集停止", message: "待ち合わせ募集を停止してもよろしいですか？") { action in
                if action == UIAlertView.ActionButton.Cancel {
                    return
                }
                
                self.recruitmentStop()
            }
            
        } else {
            
            UIAlertView.showAlertOKCancel("募集再開", message: "待ち合わせ募集を再開してもよろしいですか？") { action in
                if action == UIAlertView.ActionButton.Cancel {
                    return
                }
                
                self.recruitmentStart()
            }
        }
    }
    
    func recruitmentStart() {
        self.recruitmentAction(true)
    }
    
    func recruitmentStop() {
        self.recruitmentAction(false)
    }
    
    func recruitmentAction(isRecruitment: Bool) {
        
        var userData = PersistentData.User()
        
        MBProgressHUDHelper.show("Loading...")
        
        ParseHelper.getUserInfomation(userData.userID) { (error: NSError?, result: PFObject?) -> Void in
            
            defer {
                MBProgressHUDHelper.hide()
            }
            
            guard let result = result else {
                return
            }
            
            result["IsRecruitment"] = isRecruitment
            result.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                
                defer {
                    //画面再描画
                    self.viewDidLoad()
                    
                    var message = ""
                    if isRecruitment {
                        message = "募集を開始しました"
                    } else {
                        message = "募集を停止しました"
                    }
                    
                    UIAlertView.showAlertDismiss("", message: message, completion: { () -> () in })
                }
                
                userData.isRecruitment = isRecruitment
            }
        }
    }
    
    func createRefreshButton() {
        //画面リフレッシュボタン
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xB54241)
        btn.setTitle("再表示", forState: .Normal)
        btn.addTarget(self, action: #selector(self.refresh), forControlEvents: .TouchUpInside)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height - self.view.bounds.height/8.3)
        self.view.addSubview(btn)
    }
    
    func refresh() {
        self.viewDidLoad()
    }
    
    
}