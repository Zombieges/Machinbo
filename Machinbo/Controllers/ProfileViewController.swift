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
import JTSImageViewController
import TOCropViewController

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIPickerViewDelegate, PickerViewControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate, TransisionProtocol {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var startButton: ZFRippleButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imakokoButton: UIButton!
    
    let photoItems = ["フォト"]
    let profileItems = ["名前", "プロフィール"]
    let snsItems = ["Twitter"]
    let otherItems = ["何時から", "何時まで", "待ち合わせ場所", "私の特徴"]
    var sections = ["", "プロフィール", "SNS", "待ち合わせ情報"]
    
    let imagePicker = UIImagePickerController()
    
    var inputName = ""
    var inputComment = ""
    var twitterName = ""
    var inputDateFrom = ""
    var inputDateTo = ""
    var inputPlace = ""
    var inputChar = ""
    var selectedRow: Int = 0
    
    var cell: UITableViewCell?
    let identifier = "Cell"
    let detailTableViewCellIdentifier: String = "DetailCell"
    
    var cropViewController = TOCropViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewType = PersistentData.userID == "" ? "EntryView" : "ProfileView"
        if let view = UINib(nibName: viewType, bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.setProfileGesture()
        self.initTableView()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.darkGray]
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        
        guard PersistentData.userID != "" else {
            //初期登録画面
            self.navigationItem.title = "プロフィールを登録してください"
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.darkGray]
            self.imakokoButton.isHidden = true
            self.profilePicture.image = UIImage(named: "photo")
            
            self.sections = ["", "プロフィール", "SNS"]
            
            return
        }
        
        self.tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        
        // 通常の画面遷移
        self.profilePicture.image = PersistentData.profileImage
        self.inputName = PersistentData.name
        self.inputComment = PersistentData.comment
        self.twitterName = PersistentData.twitterName
        self.inputDateFrom = PersistentData.markTimeFrom
        self.inputDateTo = PersistentData.markTimeTo
        self.inputPlace = PersistentData.place
        self.inputChar = PersistentData.mychar
        
        self.navigationItem.title = self.inputName
        
        setNavigationItemSettingButton()
        setRecruitment()
        imageMolding(profilePicture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // profilePicture タップ時の処理
    internal func tapGesture(_ sender: UITapGestureRecognizer){
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.allowsEditing = false
        self.imagePicker.modalPresentationStyle = .overFullScreen
        
        present(self.imagePicker, animated: true, completion: nil)
    }
    
    internal func setInputValue(_ inputValue: String, type: InputPickerType) {
        if type == .name {
            self.inputName = inputValue
            self.navigationItem.title = inputValue
            tableView.reloadData()
            
        } else if type == .comment {
            self.inputComment = inputValue
            tableView.reloadData()
            
        } else if type == .place {
            self.inputPlace = inputValue
            tableView.reloadData()
            
        } else if type == .char {
            self.inputChar = inputValue
            tableView.reloadData()
        }
    }
    
    internal func setSelectedDate(_ selectedDate: Date) {
        if selectedRow == 0 {
            self.inputDateFrom  = selectedDate.formatter(format: .JP)
            
        } else if selectedRow == 1 {
            self.inputDateTo  = selectedDate.formatter(format: .JP)
        }
        
        self.tableView.reloadData()
    }
    
    func onClickSettingView() {
        let vc = SettingsViewController()
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func pushStart(_ sender: AnyObject) {
        guard self.isInternetConnect() else {
            self.errorAction()
            return
        }
        
        guard !inputName.isEmpty else {
            UIAlertController.showAlertView("", message: "名前を入力してください")
            return
        }
        
        UIAlertController.showAlertOKCancel("注意事項", message: "本アプリの利用規約に反した行為を行った場合、アカウントを凍結いたします。\n利用規約は「利用規約」ボタンから確認いただけます。\n\n安全なサービス作りにご協力ください", actiontitle: "規約に同意") { action in
            if action == .cancel { return }

            guard let uuid = UIDevice.current.identifierForVendor?.uuidString else {
                return
            }
            
            MBProgressHUDHelper.sharedInstance.show(self.view)
            
            ParseHelper.isBlocked(userID: uuid) { (error: NSError?, isBlocked: Bool) -> Void in
                guard isBlocked == true else {
                    MBProgressHUDHelper.sharedInstance.hide()
                    UIAlertController.showAlertView("", message: "利用規約違反により、アカウントが凍結されました")
                    return
                }
                
                ParseHelper.createUserInfomation(
                    uuid,
                    name: self.inputName,
                    twitter: self.twitterName,
                    comment: self.inputComment,
                    photo: self.profilePicture.image!,
                    deviceToken: PersistentData.deviceToken
                )
            }
        }
    }
    
    @IBAction func displayRuleAction(_ sender: Any) {
        if let url = URL(string: ConfigData(type: .rule).getPlistKey) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    @IBAction func imakokoAction(_ sender: AnyObject) {
        if PersistentData.isRecruitment! {
            UIAlertController.showAlertOKCancel("", message: "登録した待ち合わせ募集を停止してもよろしいですか？", actiontitle: "停止") { action in
                if action == .cancel { return }
                self.recruitmentAction(false)
            }
            
        } else {
            UIAlertController.showAlertOKCancel("", message: "登録した待ち合わせ募集を再開してもよろしいですか？", actiontitle: "再開") { action in
                if action == .cancel { return }
                self.recruitmentAction(true)
            }
        }
    }
    
    fileprivate func setRecruitment() {
        guard !PersistentData.markTimeFrom.isEmpty else {
            //待ち合わせ募集をしていない場合
            self.imakokoButton.isHidden = true
            return
        }
        
        if PersistentData.isRecruitment! {
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
    
    fileprivate func setProfileGesture() {
        // profilePicture をタップできるようにジェスチャーを設定
        profilePicture.isUserInteractionEnabled = true
        let myTap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        profilePicture.addGestureRecognizer(myTap)
    }
    
    fileprivate func initTableView() {
        let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle:nil)
        self.tableView.register(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
        self.tableView.estimatedRowHeight = 200.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.backgroundColor = StyleConst.backgroundColorForHeader
        
        view.addSubview(tableView)
    }
    
    fileprivate func setNavigationItemSettingButton() {
        /* 設定ボタンを付与 */
        let settingsButton: UIButton = UIButton(type: .custom)
        settingsButton.setImage(UIImage(named: "settings"), for: UIControlState())
        settingsButton.addTarget(self, action: #selector(onClickSettingView), for: UIControlEvents.touchUpInside)
        settingsButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }
    
    fileprivate func imageMolding(_ target : UIImageView){
        target.layer.borderColor = UIColor.white.cgColor
        target.layer.borderWidth = 3
        target.layer.cornerRadius = 10
        target.layer.masksToBounds = true
    }
    
    fileprivate func recruitmentAction(_ isRecruitment: Bool) {
        guard self.isInternetConnect() else {
            self.errorAction()
            return
        }
        
        MBProgressHUDHelper.sharedInstance.show(self.view)
        
        ParseHelper.getMyUserInfomation(PersistentData.userID) { (error: NSError?, result: PFObject?) -> Void in
            defer {  MBProgressHUDHelper.sharedInstance.hide() }
            
            guard let result = result, error == nil else {
                self.errorAction()
                return
            }
            
            result["IsRecruitment"] = isRecruitment
            result.saveInBackground { (success: Bool, error: Error?) -> Void in
                guard success, error == nil else {
                    self.errorAction()
                    return
                }
                
                PersistentData.isRecruitment = isRecruitment
                let message = isRecruitment ? "募集を開始しました" : "募集を停止しました"
                UIAlertController.showAlertView("", message: message) { _ in
                    self.viewDidLoad()
                }
                
            }
        }
    }
    
    fileprivate func loginTwitter() {
        guard self.twitterName.isEmpty else {
            let sessionStore = Twitter.sharedInstance().sessionStore
            onClickSettingAction(sessionStore)
            return
        }
        
        Twitter.sharedInstance().logIn { session, error in
            guard session != nil, error == nil else {
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
        guard self.isInternetConnect() else {
            self.viewDidLoad()
            return
        }
        
        PersistentData.twitterName = self.twitterName
        
        guard PersistentData.userID != "" else {
            let alertMessage = self.twitterName == "" ? "認証を解除しました" : "連携が完了しました"
            UIAlertController.showAlertView("", message: alertMessage) { _ in
                self.tableView.reloadData()
            }
            return
        }
        
        MBProgressHUDHelper.sharedInstance.show(self.view)
        
        ParseHelper.getMyUserInfomation(PersistentData.userID) { (error: NSError?, result: PFObject?) -> Void in
            guard let result = result, error == nil else {
                self.errorAction()
                return
            }
            
            result["Twitter"] = self.twitterName
            result.saveInBackground { (success: Bool, error: Error?) -> Void in
                defer { MBProgressHUDHelper.sharedInstance.hide() }
                
                guard success, error == nil else {
                    self.errorAction()
                    return
                }
                
                
                let alertMessage = self.twitterName == "" ? "認証を解除しました" : "連携が完了しました"
                UIAlertController.showAlertView("", message: alertMessage) { _ in
                    self.viewDidLoad()
                }
            }
        }
    }
    
    internal func errorAction() {
        MBProgressHUDHelper.sharedInstance.hide()
        UIAlertController.showAlertParseConnectionError()
    }
}


extension ProfileViewController:  UITableViewDelegate {
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 0
        case 1: return profileItems.count
        case 2: return snsItems.count
        case 3: return otherItems.count
        default: return 0
        }
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section] as? String
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel(frame: CGRect(x: 8, y: 0, width: tableView.frame.size.width - 16, height: StyleConst.sectionHeaderHeight))
        label.font = UIFont(name: "Helvetica-Bold",size: CGFloat(15))
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textColor = StyleConst.textColorForHeader
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return StyleConst.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCellIdentifier = "Cell"
        
        var normalCell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier)
        if normalCell == nil {
            normalCell = UITableViewCell(style: .value1, reuseIdentifier: tableViewCellIdentifier)
        }
        normalCell?.imageView?.image = nil
        
        normalCell?.textLabel?.adjustsFontForContentSizeCategory = true
        normalCell?.detailTextLabel?.adjustsFontForContentSizeCategory = true
        
        let detailCell = tableView.dequeueReusableCell(withIdentifier: detailTableViewCellIdentifier, for: indexPath) as? DetailProfileTableViewCell
        
        if indexPath.section == 1 {
            if indexPath.row < 1 {
                if indexPath.row == 0 {
                    normalCell?.textLabel?.text = profileItems[indexPath.row]
                    normalCell?.accessoryType = .disclosureIndicator
                    normalCell?.detailTextLabel?.text = inputName as String
                }
                
                return normalCell!
                
            } else {
                if indexPath.row == 1 {
                    detailCell?.titleLabel.text = profileItems[indexPath.row]
                    detailCell?.accessoryType = .disclosureIndicator
                    detailCell?.valueLabel.text = inputComment as String
                }
                
                return detailCell!
            }
            
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                normalCell?.textLabel?.text = snsItems[indexPath.row] as String
                normalCell?.imageView?.image = UIImage(named: "logo_twitter")
                normalCell?.accessoryType = .disclosureIndicator
                normalCell?.detailTextLabel?.text = twitterName as String
            }
            
            return normalCell!
            
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                normalCell?.textLabel?.text = otherItems[indexPath.row]
                normalCell?.accessoryType = .disclosureIndicator
                normalCell?.detailTextLabel?.text = self.inputDateFrom
                
                return normalCell!
                
            } else if indexPath.row == 1 {
                normalCell?.textLabel?.text = otherItems[indexPath.row]
                normalCell?.accessoryType = .disclosureIndicator
                normalCell?.detailTextLabel?.text = self.inputDateTo
                
                return normalCell!
                
            } else if indexPath.row == 2 {
                detailCell?.titleLabel.text = otherItems[indexPath.row]
                detailCell?.accessoryType = .disclosureIndicator
                detailCell?.valueLabel.text = self.inputPlace
                
                return detailCell!
                
            } else if indexPath.row == 3 {
                detailCell?.titleLabel.text = otherItems[indexPath.row]
                detailCell?.accessoryType = .disclosureIndicator
                detailCell?.valueLabel.text = self.inputChar
                
                return detailCell!
            }
        }
        
        return UITableViewCell()
    }
    
    // セルがタップされた時
    internal func tableView(_ table: UITableView, didSelectRowAt indexPath:IndexPath) {
        self.selectedRow = indexPath.row
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let vc = PickerViewController(kind: .name, inputValue: inputName as AnyObject)
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 1 {
                let vc = PickerViewController(kind: .comment, inputValue: inputComment as AnyObject)
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
            }
            
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                //Twitter認証
                loginTwitter()
            }
            
        } else if indexPath.section == 3 {
            
            if PersistentData.isRecruitment! {
                if indexPath.row == 0 {
                    let vc = PickerViewController(kind: .imakokoDateFrom, inputValue: inputDateFrom as AnyObject)
                    vc.delegate = self
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                } else if indexPath.row == 1 {
                    let vc = PickerViewController(kind: .imakokoDateTo, inputValue: inputDateTo as AnyObject)
                    vc.delegate = self
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                } else if indexPath.row == 2 {
                    let vc = PickerViewController(kind: .place, inputValue: inputPlace as AnyObject)
                    vc.delegate = self
                    
                    navigationController?.pushViewController(vc, animated: true)
                    
                } else if indexPath.row == 3 {
                    let vc = PickerViewController(kind: .char, inputValue: inputChar as AnyObject)
                    vc.delegate = self
                    
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}


extension ProfileViewController: UIImagePickerControllerDelegate {
    // 写真選択時の処理
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        guard self.isInternetConnect() else {
            self.errorAction()
            return
        }
        
        let screenWidth = UIScreen.main.bounds.size.width
        let imageSize = profilePicture.image?.size.width
        let image = (info[UIImagePickerControllerOriginalImage] as! UIImage).resize(newWidth: screenWidth)
        self.cropViewController = TOCropViewController(image: image)
        self.cropViewController.imageCropFrame = CGRect(x: 0, y: 0, width: imageSize!, height: imageSize!)
        self.cropViewController.delegate = self
        self.cropViewController.aspectRatioLockEnabled = true
        self.cropViewController.resetAspectRatioEnabled = false
        self.cropViewController.rotateButtonsHidden = true
        self.cropViewController.aspectRatioPreset = .presetSquare
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    // 写真選択画面でキャンセルした場合の処理
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


extension ProfileViewController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        self.profilePicture.image = image
        
        if PersistentData.userID == ""  {
            PersistentData.profileImage = self.profilePicture.image!
            cropViewController.dismiss(animated: true, completion: nil)
            return
        }
        
        ParseHelper.getMyUserInfomation(PersistentData.userID) { (error: NSError?, result: PFObject?) -> Void in
            guard let result = result, error == nil else {
                self.errorAction()
                return
            }
            
            let imageData = UIImagePNGRepresentation(self.profilePicture.image!)
            let imageFile = PFFile(name:"image", data:imageData!)
            
            result["ProfilePicture"] = imageFile
            result.saveInBackground { (success: Bool, error: Error?) -> Void in
                guard success, error == nil else {
                    self.errorAction()
                    return
                }
                
                PersistentData.profileImage = self.profilePicture.image!
            }
        }
        
        cropViewController.dismiss(animated: true, completion: nil)
    }
}
