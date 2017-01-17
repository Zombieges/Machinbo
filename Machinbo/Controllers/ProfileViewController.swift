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
    
    fileprivate let photoItems = ["フォト"]
    fileprivate let profileItems = ["名前", "性別", "生まれた年", "Twitter", "プロフィール"]
    fileprivate let otherItems = ["待ち合わせ（何時から〜）", "待ち合わせ（〜何時まで）", "場所", "特徴"]
    fileprivate let sections = ["プロフィール", "待ち合わせ情報"]
    
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
    var twitterName = ""
    
    let identifier = "Cell"
    var cell: UITableViewCell?
    let detailTableViewCellIdentifier: String = "DetailCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = UINib(nibName: "ProfileView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        setProfileGesture()
        initTableView()
        
        
        self.navigationItem.title = "プロフィール"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.darkGray]
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        
        let userData = PersistentData.User()
        guard userData.userID != "" else {
            //初期登録画面
            self.navigationItem.title = "プロフィールを登録してください"
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.darkGray]
            self.imakokoButton.isHidden = true
            profilePicture.image = UIImage(named: "photo.png")
            return
        }

        self.startButton.isHidden = true
        setNavigationItemSettingButton()
        
        // 通常の画面遷移
        profilePicture.image = userData.profileImage
        inputName = userData.name
        age = userData.age
        selectedAge = userData.age
        gender = userData.gender
        selectedGender = String(userData.gender)
        inputComment = userData.comment
        twitterName = userData.twitterName
        
        setRecruitment()
        imageMolding(profilePicture)
        showAdmob()
    }
    
    fileprivate func setRecruitment() {
        let userData = PersistentData.User()
        
        guard !userData.markTimeFrom.isEmpty else {
            //待ち合わせ募集をしていない場合
             self.imakokoButton.isHidden = true
            return
        }
        
        if userData.isRecruitment! {
            //募集中の場合
            self.imakokoButton.setTitle("待ち合わせ募集中", for: UIControlState())
            self.imakokoButton.layer.cornerRadius = 5.0
            self.imakokoButton.layer.borderColor = UIView().tintColor.cgColor
            self.imakokoButton.layer.borderWidth = 1.0
            self.imakokoButton.tintColor = UIView().tintColor
        } else {
            self.imakokoButton.setTitle("待ち合わせ募集停止中", for: UIControlState())
            self.imakokoButton.layer.cornerRadius = 5.0
            self.imakokoButton.layer.borderColor = UIColor.red.cgColor
            self.imakokoButton.layer.borderWidth = 1.0
            self.imakokoButton.tintColor = UIColor.red
        }
    }
    
    fileprivate func showAdmob() {
        if self.isInternetConnect() {
            //広告を表示
            self.showAdmob(AdmobType.standard)
            
        } else {
            self.createRefreshButton()
        }
    }
    
    fileprivate func setProfileGesture() {
        // profilePicture をタップできるようにジェスチャーを設定
        profilePicture.isUserInteractionEnabled = true
        let myTap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        profilePicture.addGestureRecognizer(myTap)
    }
    
    fileprivate func initTableView() {
        let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle:nil)
        tableView.register(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
        tableView.estimatedRowHeight = 200.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
    }
    
    fileprivate func setNavigationItemSettingButton() {
        /* 設定ボタンを付与 */
        let settingsButton: UIButton = UIButton(type: .custom)
        settingsButton.setImage(UIImage(named: "santen.png"), for: UIControlState())
        settingsButton.addTarget(self, action: #selector(ProfileViewController.onClickSettingView), for: UIControlEvents.touchUpInside)
        settingsButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // profilePicture タップ時の処理
    internal func tapGesture(_ sender: UITapGestureRecognizer){
        self.picker.delegate = self
        self.picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.picker.allowsEditing = false
        
        present(self.picker, animated: true, completion: nil)
    }
    
    
    // 写真選択時の処理
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let displaySize = UIScreen.main.bounds.size.width
        let resizedSize = CGSize(width: displaySize, height: displaySize)
        UIGraphicsBeginImageContext(resizedSize)
        
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        profilePicture.image = resizedImage
        imageMolding(profilePicture)
        
        var userInfo = PersistentData.User()
        guard userInfo.userID != "" else {
            userInfo.profileImage = self.profilePicture.image!
            return
        }
        
        ParseHelper.getMyUserInfomation(userInfo.userID) { (error: Error?, result: PFObject?) -> Void in
            if let result = result {
                let imageData = UIImagePNGRepresentation(self.profilePicture.image!)
                let imageFile = PFFile(name:"image.png", data:imageData!)
                
                result["ProfilePicture"] = imageFile
                result.saveInBackground { (success: Bool, error: Error?) -> Void in
                    
                    userInfo.profileImage = self.profilePicture.image!
                    //self.navigationController!.popViewControllerAnimated(true)
                }
                
            }
        }
    }
    
    // 写真選択画面でキャンセルした場合の処理
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // PickerViewController より性別を選択した際に実行される処理
    internal func setSelectedValue(_ selectedindex: Int, selectedValue: String, type: SelectPickerType) {
        if type == .age {
            self.age = String(selectedindex)
            self.selectedAge = selectedValue
            tableView.reloadData()
            
        } else if type == .gender {
            self.gender = selectedValue
            self.selectedGender = selectedValue
            tableView.reloadData()
        }
    }
    
    internal func setInputValue(_ inputValue: String, type: InputPickerType) {
        if type == .name {
            self.inputName = inputValue
            tableView.reloadData()
            
        } else if type == .comment {
            self.inputComment = inputValue
            tableView.reloadData()
        }
    }
    
    internal func setSelectedDate(_ SelectedDate: Date) {}
    
    /*
     テーブルに表示する配列の総数を返す.
     */
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return PersistentData.User().userID == "" ? 1 : sections.count
    }
    
    /*
     セクションのタイトルを返す.
     */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    /*
     Cellに値を設定する.
     */
    internal func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCellIdentifier = "Cell"
        cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        }
        
        if indexPath.section == 0 {
            if indexPath.row < 4 {
                var normalCell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier)
                if normalCell == nil {
                    normalCell = UITableViewCell(style: .value1, reuseIdentifier: tableViewCellIdentifier)
                }
                normalCell!.textLabel!.font = UIFont.systemFont(ofSize: 16)
                normalCell!.detailTextLabel!.font = UIFont.systemFont(ofSize: 16)
                
                if indexPath.row == 0 {
                    normalCell?.textLabel?.text = profileItems[indexPath.row]
                    normalCell?.accessoryType = .disclosureIndicator
                    normalCell?.detailTextLabel?.text = inputName as String
                    
                } else if indexPath.row == 1 {
                    normalCell?.textLabel?.text = profileItems[indexPath.row]
                    normalCell?.accessoryType = .disclosureIndicator
                    normalCell?.detailTextLabel?.text = selectedGender as String
                    
                } else if indexPath.row == 2 {
                    normalCell?.textLabel?.text = profileItems[indexPath.row]
                    if !selectedAge.isEmpty {
                        normalCell?.accessoryType = .disclosureIndicator
                        normalCell?.detailTextLabel?.text = Parser.changeAgeRange(selectedAge) as String
                    }
                    
                } else if indexPath.row == 3 {
                    normalCell?.textLabel?.text = profileItems[indexPath.row] as String
                    normalCell?.imageView?.image = UIImage(named: "logo_twitter.png")
                    normalCell?.accessoryType = .disclosureIndicator
                    normalCell?.detailTextLabel?.text = twitterName as String
                }
                
                cell = normalCell
                
            } else {
                let detailCell = tableView.dequeueReusableCell(withIdentifier: detailTableViewCellIdentifier, for: indexPath) as? DetailProfileTableViewCell
                
                if indexPath.row == 4 {
                    detailCell?.titleLabel.text = profileItems[indexPath.row]
                    detailCell?.valueLabel.text = inputComment as String
                }
                
                cell = detailCell
            }
            
        } else if indexPath.section == 1 {
            var normalCell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier)
            if normalCell == nil {
                normalCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: tableViewCellIdentifier)
            }
            
            let userData = PersistentData.User()
            if indexPath.row == 0 {
                normalCell?.textLabel?.text = otherItems[indexPath.row]
                normalCell?.detailTextLabel?.text = userData.markTimeFrom
                
                cell = normalCell
                
            } else if indexPath.row == 1 {
                normalCell?.textLabel?.text = otherItems[indexPath.row]
                normalCell?.detailTextLabel?.text = userData.markTimeTo
                
                cell = normalCell
                
            } else if indexPath.row == 2 {
                let detailCell = tableView.dequeueReusableCell(withIdentifier: detailTableViewCellIdentifier, for: indexPath) as? DetailProfileTableViewCell
                
                detailCell?.titleLabel.text = otherItems[indexPath.row]
                detailCell?.valueLabel.text = userData.place
                
                cell = detailCell
                
            } else if indexPath.row == 3 {
                let detailCell = tableView.dequeueReusableCell(withIdentifier: detailTableViewCellIdentifier, for: indexPath) as? DetailProfileTableViewCell
                
                detailCell?.titleLabel.text = otherItems[indexPath.row]
                detailCell?.valueLabel.text = userData.mychar
                
                cell = detailCell
            }
        }
        
        return cell!
    }
    
    // セルがタップされた時
    internal func tableView(_ table: UITableView, didSelectRowAt indexPath:IndexPath) {
        let vc = PickerViewController()
        myItems = []
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
                vc.palmItems = myItems
                vc.palKind = "name"
                vc.palInput = inputName as AnyObject
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 1 {
                
                myItems = ["男性","女性"]
                vc.palmItems = myItems
                vc.palKind = "gender"
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 2 {
                
                let date = Date()      // 現在日時
                let calendar = Calendar.current
                let comp : DateComponents = (calendar as NSCalendar).components(
                    NSCalendar.Unit.year, from: date)
                
                for i in 0...50 {
                    myItems.append((String(comp.year! - i)))
                }
                
                vc.palmItems = myItems
                vc.palKind = "age"
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 3 {
                //Twitter認証
                loginTwitter()
                
            } else if indexPath.row == 4 {
                vc.palmItems = myItems
                vc.palKind = "comment"
                vc.palInput = inputComment as AnyObject
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    @IBAction func pushStart(_ sender: AnyObject) {
        // 必須チェック
        guard !inputName.isEmpty else {
            UIAlertController.showAlertView("", message: "名前を入力してください")
            return
        }
        guard !selectedGender.isEmpty else {
            UIAlertController.showAlertView("", message: "性別を選択してください")
            return
        }
        guard !selectedAge.isEmpty else {
            UIAlertController.showAlertView("", message: "生まれた年を選択してください")
            return
        }
        
        MBProgressHUDHelper.show("Loading...")
        
        defer { MBProgressHUDHelper.hide() }
        
        let imageData = UIImagePNGRepresentation(profilePicture.image!)
        let imageFile = PFFile(name:"image.png", data:imageData!)
        let uuid = UUID().uuidString
        
        NSLog("UUID" + uuid)
        
        // save to local db
        var userInfo = PersistentData.User()
        userInfo.userID = uuid
        userInfo.name = inputName
        userInfo.gender = selectedGender
        userInfo.age = selectedAge
        userInfo.comment = inputComment
        userInfo.twitterName = twitterName
        userInfo.profileImage = profilePicture.image!
        
        ParseHelper.setUserInfomation(
            uuid,
            name: inputName,
            gender: gender,
            age: selectedAge,
            twitter: twitterName,
            comment: inputComment,
            photo: imageFile!,
            deviceToken: userInfo.deviceToken
        )
        
        LayoutManager.createNavigationAndTabItems()
    }
    
    fileprivate func imageMolding(_ target : UIImageView){
        target.layer.borderColor = UIColor.white.cgColor
        target.layer.borderWidth = 3
        target.layer.cornerRadius = 10
        target.layer.masksToBounds = true
    }
    
    func onClickSettingView() {
        let vc = SettingsViewController()
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func imakokoAction(_ sender: AnyObject) {
        if PersistentData.User().isRecruitment! {
            UIAlertController.showAlertOKCancel("募集停止", message: "待ち合わせ募集を停止してもよろしいですか？") { action in
                if action == .cancel { return }
                self.recruitmentStop()
            }
            
        } else {
            UIAlertController.showAlertOKCancel("募集再開", message: "待ち合わせ募集を再開してもよろしいですか？") { action in
                if action == .cancel { return }
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
    
    fileprivate func recruitmentAction(_ isRecruitment: Bool) {
        MBProgressHUDHelper.show("Loading...")
        
        var userData = PersistentData.User()
        ParseHelper.getMyUserInfomation(userData.userID) { (error: NSError?, result: PFObject?) -> Void in
            
            defer {  MBProgressHUDHelper.hide() }
            
            guard let result = result else { return }
            
            result["IsRecruitment"] = isRecruitment
            result.saveInBackground { (success: Bool, error: Error?) -> Void in
                userData.isRecruitment = isRecruitment
                let message = isRecruitment ? "募集を開始しました" : "募集を停止しました"
                UIAlertController.showAlertView("", message: message) { _ in
                    self.viewDidLoad()
                }

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
        btn.setTitle("再表示", for: UIControlState())
        btn.addTarget(self, action: #selector(self.refresh), for: .touchUpInside)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height - self.view.bounds.height/8.3)
        self.view.addSubview(btn)
    }
    
    func refresh() {
        self.viewDidLoad()
    }
    
    fileprivate func loginTwitter() {
        guard self.twitterName.isEmpty else {
            let sessionStore = Twitter.sharedInstance().sessionStore
            onClickSettingAction(sessionStore)
            return
        }
        
        Twitter.sharedInstance().logIn { session, error in
            guard session != nil else {
                print("error: \(error!.localizedDescription)")
                UIAlertController.showAlertView("", message: "Twitterへの接続に失敗しました。再接続してください") { _ in }
                return
            }
            
            self.twitterName = session!.userName
            self.setTwitterName()
            print("signed in as \(session!.userName)");
        }
    }
    
    fileprivate func onClickSettingAction(_ sessionStore: TWTRSessionStore) {
        let myAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let destructiveAction_1: UIAlertAction = UIAlertAction(title: "認証を解除", style: UIAlertActionStyle.destructive, handler:{
            (action: UIAlertAction!) -> Void in
            
            self.twitterName = ""
            self.setTwitterName()
            sessionStore.logOutUserID((sessionStore.session()?.userID)!)
            
        })
        myAlert.addAction(destructiveAction_1)

        let cancelAction: UIAlertAction = UIAlertAction(title: "cancel", style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("cancelAction")
        })
        myAlert.addAction(cancelAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }
    
    fileprivate func setTwitterName() {
        guard PersistentData.User().userID != "" else {
            self.viewDidLoad()
            return
        }
        
        MBProgressHUDHelper.show("Loading...")
        
        ParseHelper.getMyUserInfomation(PersistentData.User().userID) { (error: NSError?, result: PFObject?) -> Void in
            guard let result = result else {
                MBProgressHUDHelper.hide()
                return
            }
            
            result["Twitter"] = self.twitterName
            result.saveInBackground { (success: Bool, error: Error?) -> Void in
                defer { MBProgressHUDHelper.hide() }
                
                var userInfo = PersistentData.User()
                userInfo.twitterName = self.twitterName
                
                let alertMessage = self.twitterName == "" ? "認証を解除しました" : "連携が完了しました"
                UIAlertController.showAlertView("", message: alertMessage) { _ in
                    self.viewDidLoad()
                }
            }
        }
    }
}
