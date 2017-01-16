//
//  TargetProfileViewController.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2015/09/08.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import UIKit
import Parse
import MBProgressHUD
import GoogleMobileAds
import MessageUI
import GoogleMaps
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


enum ProfileType {
    case targetProfile, imaikuTargetProfile, meetupProfile, receiveProfile
}

extension TargetProfileViewController: TransisionProtocol {}

class TargetProfileViewController:
    UIViewController,
    UITableViewDelegate,
    GADBannerViewDelegate,
    GADInterstitialDelegate,
    MFMailComposeViewControllerDelegate,
    CLLocationManagerDelegate,
    GMSMapViewDelegate {
    
    var userInfo: PFObject?
    var type = ProfileType.targetProfile
    var targetGeoPoint = PFGeoPoint(latitude: 0, longitude: 0)
    var gonowInfo: PFObject?
    
    @IBOutlet var tableView: UITableView!
    private let modalTextLabel = UILabel()
    private let lblName: String = ""
    private var targetObjectID = ""
    private var myHeaderView = UIView()
    private var displayWidth = CGFloat()
    private var displayHeight = CGFloat()
    private var innerViewHeight: CGFloat!
    private var sections: NSArray = []
    private var mapViewHeight: CGFloat!
    private let targetProfileItems = ["名前", "性別", "年齢", "プロフィール"]
    private let imakuruItems = ["到着時間"]
    private let otherItems = ["待ち合わせ開始時間", "待ち合わせ終了時間", "場所", "特徴"]
    private let detailTableViewCellIdentifier = "DetailCell"
    private let mapTableViewCellIdentifier = "MapCell"
    
    init (type: ProfileType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        if let view = UINib(nibName: "TargetProfileView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.mapViewHeight = round(UIScreen.main.bounds.size.height / 5)
        self.innerViewHeight = self.mapViewHeight + round(self.mapViewHeight / 2)
        self.displayWidth = UIScreen.main.bounds.size.width
        self.displayHeight = UIScreen.main.bounds.size.height
        
        PersistentData.deleteUserIDForKey("imaikuFlag")
        
        self.setHeader()
        self.setNavigationButton()
        self.initTableView()
        self.setImageProfile()
        self.setGoogleMap()
        
        if type == .meetupProfile {
            self.sections = ["プロフィール", "来る情報"]
            let isApproved = (self.gonowInfo as AnyObject).object(forKey: "IsApproved") as! Bool
            if isApproved {
                self.createSendGeoPointButton(mapViewHeight: self.mapViewHeight)
                self.createConfirmGeoPointButton(mapViewHeight: self.mapViewHeight)
            }
            
        } else if type == .receiveProfile {
            self.sections = ["プロフィール", "来る情報"]
            self.createApprovedButton(mapViewHeight: self.mapViewHeight)
            
        } else {
            self.sections = ["プロフィール", "待ち合わせ情報"]
            self.createGoNowButton()
        }
        
        if self.isInternetConnect() {
            //広告を表示
            self.showAdmob(AdmobType.standard)
        }
    }

    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section] as? String
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.targetProfileItems.count
        } else if section == 1 {
            return type == ProfileType.meetupProfile ? imakuruItems.count : otherItems.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let tableViewCellIdentifier = "Cell"
        var cell: UITableViewCell? // nilになることがあるので、Optionalで宣言
        
        if indexPath.section == 0 {
            if indexPath.row < 3 {
                // セルを再利用する
                var normalCell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier)
                if normalCell == nil {
                    normalCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: tableViewCellIdentifier)
                    normalCell!.textLabel!.font = UIFont(name: "Arial", size: 15)
                    normalCell!.detailTextLabel!.font = UIFont(name: "Arial", size: 15)
                }
                
                if indexPath.row == 0 {
                    normalCell?.textLabel?.text = targetProfileItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = (self.userInfo as AnyObject).object(forKey: "Name") as? String
                    
                } else if indexPath.row == 1 {
                    normalCell?.textLabel?.text = targetProfileItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = (self.userInfo as AnyObject).object(forKey: "Gender") as? String
                    
                } else if indexPath.row == 2 {
                    normalCell?.textLabel?.text = targetProfileItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = Parser.changeAgeRange(((self.userInfo as AnyObject).object(forKey: "Age") as? String)!)
                }
                
                cell = normalCell
                
            } else {
                let detailCell = tableView.dequeueReusableCell(withIdentifier: detailTableViewCellIdentifier, for: indexPath) as? DetailProfileTableViewCell
                
                if indexPath.row == 3 {
                    detailCell?.titleLabel.text = targetProfileItems[indexPath.row]
                    detailCell?.valueLabel.text = (self.userInfo as AnyObject).object(forKey: "Comment") as? String
                    
                }
                
                cell = detailCell
            }
            
        } else if indexPath.section == 1 {
            
            var normalCell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier)
            if normalCell == nil { // 再利用するセルがなかったら（不足していたら）
                // セルを新規に作成する。
                normalCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: tableViewCellIdentifier)
                normalCell!.textLabel!.font = UIFont(name: "Arial", size: 14)
                normalCell!.detailTextLabel!.font = UIFont(name: "Arial", size: 14)
            }
            
            if type == .meetupProfile {
                if indexPath.row == 0 {
                    normalCell?.textLabel?.text = imakuruItems[indexPath.row]
                    
                    let dateFormatter = DateFormatter();
                    dateFormatter.dateFormat = "yyyy年M月d日 H:mm"
                    let formatDateString = dateFormatter.string(from: (self.gonowInfo as AnyObject).object(forKey: "gotoAt") as! Date)
                    
                    normalCell?.detailTextLabel?.text = formatDateString
                    
                    cell = normalCell
                }
                
                return cell!
                
            } else {
                
                if indexPath.row == 0 {
                    normalCell?.textLabel?.text = otherItems[indexPath.row]
                    
                    let dateFormatter = DateFormatter();
                    dateFormatter.dateFormat = "yyyy年M月d日 H:mm"
                    if let mark = (self.userInfo as AnyObject).object(forKey: "MarkTime") {
                        let formatDateString = dateFormatter.string(from: mark as! Date)
                        normalCell?.detailTextLabel?.text = formatDateString
                    }
                    
                    cell = normalCell
                    
                } else if indexPath.row == 1 {
                    normalCell?.textLabel?.text = otherItems[indexPath.row]
                    
                    let dateFormatter = DateFormatter();
                    dateFormatter.dateFormat = "yyyy年M月d日 H:mm"
                    if let mark = (self.userInfo as AnyObject).object(forKey: "MarkTimeTo") {
                        let formatDateString = dateFormatter.string(from: mark as! Date)
                        normalCell?.detailTextLabel?.text = formatDateString
                    }
                    
                    cell = normalCell
                    
                } else if indexPath.row == 2 {
                    let detailCell = tableView.dequeueReusableCell(withIdentifier: detailTableViewCellIdentifier, for: indexPath) as? DetailProfileTableViewCell
                    
                    detailCell?.titleLabel.text = otherItems[indexPath.row]
                    detailCell?.valueLabel.text = (self.userInfo as AnyObject).object(forKey: "PlaceDetail") as? String
                    
                    cell = detailCell
                    
                } else if indexPath.row == 3 {
                    let detailCell = tableView.dequeueReusableCell(withIdentifier: detailTableViewCellIdentifier, for: indexPath) as? DetailProfileTableViewCell
                    
                    detailCell?.titleLabel.text = otherItems[indexPath.row]
                    detailCell?.valueLabel.text = (self.userInfo as AnyObject).object(forKey: "MyChar") as? String
                    
                    cell = detailCell
                }
            }
            
        }
        
        return cell!
    }
    
    func setNavigationButton() {
        let settingsButton = UIButton(type: .custom)
        settingsButton.setImage(UIImage(named: "santen.png"), for: UIControlState())
        settingsButton.addTarget(self, action: #selector(TargetProfileViewController.onClickSettingAction), for: .touchUpInside)
        settingsButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }
    
    func createGoNowButton() {
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        btn.trackTouchLocation = true
        btn.backgroundColor = UIColor.hex("55acee", alpha: 1)
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 3
        btn.layer.cornerRadius = 7
        btn.layer.masksToBounds = true
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0x2196F3)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xBBDEFB)
        btn.addTarget(self, action: #selector(self.clickGoNowButton), for: .touchUpInside)
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        btn.setImage(UIImage(named: "imaiku.png"), for: UIControlState())
        btn.imageView?.contentMode = .scaleAspectFit
        let imaikuBtnX = self.displayWidth - round(self.displayWidth / 5)
        let imaikuBtnWidth = round(self.displayWidth / 7)
        let imaikuBtnHeight = round(self.displayHeight / 17)
        btn.frame = CGRect(x: imaikuBtnX, y: mapViewHeight + 10, width: imaikuBtnWidth, height: imaikuBtnHeight)
        btn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        
        self.myHeaderView.addSubview(btn)
    }
    
    func clickGoNowButton() {
        UIAlertController.showAlertOKCancel("いまから行くことを送信", message: "いまから行くことを相手に送信します。") { action in
            guard action == .ok else { return }
            
            let vc = PickerViewController()
            vc.palTargetUser = self.userInfo! as PFObject
            vc.palKind = "imaiku"
            
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func createApprovedButton(mapViewHeight: CGFloat) {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(self.clickApproveButton), for: .touchUpInside)
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        btn.setTitle("承認する", for: UIControlState())
        btn.titleLabel!.font = UIFont.systemFont(ofSize: 15)
        btn.layer.cornerRadius = 5.0
        btn.layer.borderColor = UIView().tintColor.cgColor
        btn.layer.borderWidth = 1.0
        btn.tintColor = UIView().tintColor
        btn.setTitleColor(UIView().tintColor, for: UIControlState())
        
        let imadokoBtnX = self.displayWidth - round(self.displayWidth / 3.8)
        let imadokoBtnWidth = round(self.displayWidth / 4)
        let imadokotnHeight = round(self.displayHeight / 17)
        btn.frame = CGRect(x: imadokoBtnX, y: mapViewHeight + 10, width: imadokoBtnWidth, height: imadokotnHeight)
        
        self.myHeaderView.addSubview(btn)
    }
    
    func clickApproveButton() {
        if let id = (gonowInfo! as PFObject).objectId {
            do {
                let query = PFQuery(className: "GoNow")
                let loadedObject = try query.getObjectWithId(id)
                loadedObject["IsApproved"] = true
                loadedObject.saveInBackground()
                self.gonowInfo = loadedObject
                
            } catch {}
            
            UIAlertController.showAlertView("", message: "承認しました") { _ in
                self.navigationController!.popToRootViewController(animated: true)
            }
        }
    }
    
    func createSendGeoPointButton(mapViewHeight: CGFloat) {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(self.clickimakokoButton), for: .touchUpInside)
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        
        btn.setTitle("位置送信", for: UIControlState())
        btn.titleLabel!.font = UIFont.systemFont(ofSize: 15)
        btn.layer.cornerRadius = 5.0
        btn.layer.borderColor = UIView().tintColor.cgColor
        btn.layer.borderWidth = 1.0
        btn.tintColor = UIView().tintColor
        btn.setTitleColor(UIView().tintColor, for: UIControlState())
        
        let imadokoBtnX = self.displayWidth - round(self.displayWidth / 3.5)
        let imadokoBtnWidth = round(self.displayWidth / 4)
        let imadokotnHeight = round(self.displayHeight / 17)
        btn.frame = CGRect(x: imadokoBtnX, y: mapViewHeight + 10, width: imadokoBtnWidth, height: imadokotnHeight)
        
        self.myHeaderView.addSubview(btn)
    }
    
    func createConfirmGeoPointButton(mapViewHeight: CGFloat) {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(self.clickimadokoButton), for: .touchUpInside)
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        btn.setTitle("位置確認", for: UIControlState())
        btn.titleLabel!.font = UIFont.systemFont(ofSize: 15)
        btn.layer.cornerRadius = 5.0
        btn.layer.borderColor = UIView().tintColor.cgColor
        btn.layer.borderWidth = 1.0
        btn.tintColor = UIView().tintColor
        btn.setTitleColor(UIView().tintColor, for: UIControlState())
        
        let imadokoBtnX = self.displayWidth - round(self.displayWidth / 1.8)
        let imadokoBtnWidth = round(self.displayWidth / 4)
        let imadokotnHeight = round(self.displayHeight / 17)
        btn.frame = CGRect(x: imadokoBtnX, y: mapViewHeight + 10, width: imadokoBtnWidth, height: imadokotnHeight)
        
       self.myHeaderView.addSubview(btn)
    }
    
    func clickimakokoButton() {
        UIAlertController.showAlertOKCancel("現在位置の送信", message: "現在のあなたの位置情報を相手だけに送信します") { action in
            if action == .cancel { return }
            
            LocationManager.sharedInstance.startUpdatingLocation()
            let center = NotificationCenter.default as NotificationCenter
            center.addObserver(self, selector: #selector(self.foundLocation), name: NSNotification.Name(rawValue: LMLocationUpdateNotification as String as String), object: nil)
        }
    }
    
    func foundLocation(_ notif: Notification) {
        defer { NotificationCenter.default.removeObserver(self) }
        
        //TODO:この処理だといまから行くが複数ある場合、送信する対象が異なってしまう恐れあり。ParseIDで見ないと駄目かも
        
        MBProgressHUDHelper.show("Loading...")
        
        let info = notif.userInfo as NSDictionary!
        let location = info?[LMLocationInfoKey] as! CLLocation
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let objectid = (gonowInfo! as PFObject).objectId
        
        ParseHelper.getTargetUserGoNow(objectid!) { (error: NSError?, result) -> Void in
            guard error == nil else { print("Error information"); return }
            guard let result = result else { print("no data"); return }
            
            let userID = result.object(forKey: "UserID") as! String
            let targetUserID = result.object(forKey: "TargetUserID") as! String
            let geoPoint = PFGeoPoint(latitude: latitude, longitude: longitude)
            
            //現在位置確認をする際、この待ち合わせを募集した人はuserGoNow→GoNowReceiveへ値を更新し、
            //募集に対していまから行くをした人は、targetGoNow→GoNowSendへ値を更新する
            if userID == PersistentData.User().userID {
                if let query = result.object(forKey: "userGoNow") as? PFObject {
                    query["userGeoPoint"] = geoPoint
                    query.saveInBackground { (success: Bool, error: Error?) -> Void in
                        defer { MBProgressHUDHelper.hide() }
                        guard error == nil else { return }
                        
                        UIAlertController.showAlertView("", message: "現在位置を相手に送信しました")
                    }
                    
                } else {
                    defer { MBProgressHUDHelper.hide() }
                    
                    let gonowReceiveObject = PFObject(className: "GoNowReceive")
                    gonowReceiveObject["userGeoPoint"] = geoPoint
                    gonowReceiveObject.saveInBackground { (success: Bool, error: Error?) -> Void in
                        defer { MBProgressHUDHelper.hide() }
                        guard error == nil else { return }
                    }
                    result["userGoNow"] = gonowReceiveObject
                    result.saveInBackground { (success: Bool, error: Error?) -> Void in
                        defer { MBProgressHUDHelper.hide() }
                        guard error == nil else { return }
                    }
                }
                
            } else if targetUserID == PersistentData.User().userID {
                if let query = result.object(forKey: "targetGoNow") as? PFObject {
                    query["userGeoPoint"] = geoPoint
                    query.saveInBackground { (success: Bool, error: Error?) -> Void in
                        defer { MBProgressHUDHelper.hide() }
                        guard error == nil else { return }
                        
                        UIAlertController.showAlertView("", message: "現在位置を相手に送信しました")
                    }
                    
                } else {
                    let gonowReceiveObject = PFObject(className: "GoNowSend")
                    gonowReceiveObject["userGeoPoint"] = geoPoint
                    gonowReceiveObject.saveInBackground { (success: Bool, error: Error?) -> Void in
                        defer { MBProgressHUDHelper.hide() }
                        guard error == nil else { return }
                    }
                    result["userGoNow"] = gonowReceiveObject
                    result.saveInBackground { (success: Bool, error: Error?) -> Void in
                        defer { MBProgressHUDHelper.hide() }
                        guard error == nil else { return }
                    }
                }
            }
        }
    }
    
    func clickimadokoButton() {
        UIAlertController.showAlertOKCancel("現在位置確認", message: "相手が、いまドコにいるのかを確認する通知を送信します") { action in
            
            if action == .cancel { return }
            
            //MBProgressHUDHelper.show("Loading...")
            
            //            ParseHelper.getMyGoNow(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            //
            //                defer {
            //                    MBProgressHUDHelper.hide()
            //                }
            //
            //                guard error == nil else {
            //                    return
            //                }
            //
            //                //result?.objectForKey("userGPS") =
            //
            //
            //                UIAlertController.showAlertView("", message: "相手に現在位置確認を送信しました")
            //            }
        }
    }
    
    func reportManager() {
        //メールを送信できるかチェック
        guard MFMailComposeViewController.canSendMail() else { print("Email Send Failed"); return }
        
        let address = ConfigHelper.getPlistKey("MACHINBO_MAIL") as String
        let toRecipients = [address]
        let userObjectId = (userInfo as AnyObject).objectId as String!
        let mailBody = "報告" + "¥r¥n" + "報告者：" + userObjectId!
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject("報告")
        mail.setToRecipients(toRecipients) //Toアドレスの表示
        mail.setMessageBody(mailBody, isHTML: false)
        
        self.present(mail, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case MFMailComposeResult.cancelled:
            print("Mail cancelled")
            break
        case MFMailComposeResult.saved:
            print("Mail saved")
            break
        case MFMailComposeResult.sent:
            print("Mail sent")
            break
        case MFMailComposeResult.failed:
            print("Mail sent failure: \(error!.localizedDescription)")
            break
        default:
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func onClickSettingAction() {
        let myAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let destructiveAction = UIAlertAction(title: "報告", style: UIAlertActionStyle.destructive, handler:{
            (action: UIAlertAction!) -> Void in
            self.reportManager()
        })
        myAlert.addAction(destructiveAction)
        
        // Cancelボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "cancel", style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("cancelAction")
        })
        myAlert.addAction(cancelAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }
    
    /*
     スクロール時
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isOutSectionHeaderScroll =
            scrollView.contentOffset.y >= -innerViewHeight && scrollView.contentOffset.y <= innerViewHeight
        let isInSectionHeaderScroll =
            scrollView.contentOffset.y >= self.tableView.sectionHeaderHeight
        
        if isOutSectionHeaderScroll {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0)
            
        } else if isInSectionHeaderScroll {
            scrollView.contentInset = UIEdgeInsetsMake(-self.tableView.sectionHeaderHeight, 0, 0, 0)
        }
        
        if scrollView.contentOffset.y < -innerViewHeight {
            self.myHeaderView.frame = CGRect(x: 0, y: scrollView.contentOffset.y, width: self.self.displayWidth, height: innerViewHeight)
        }
    }
    
    func setHeader() {
        self.myHeaderView = UIView(frame: CGRect(x: 0, y: -innerViewHeight, width: self.self.displayHeight, height: innerViewHeight))
        self.myHeaderView.backgroundColor = UIColor.white
        self.tableView.addSubview(self.myHeaderView)
    }
    
    func initTableView() {
        let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle: nil)
        self.tableView.register(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        //tableViewの位置を 1 / 端末サイズ 下げる
        self.tableView.contentInset.top = self.innerViewHeight
        
        // 不要行の削除
        let notUserRowView = UIView(frame: CGRect.zero)
        notUserRowView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = notUserRowView
        self.tableView.tableHeaderView = notUserRowView
        self.view.addSubview(self.tableView)
    }
    
    func setImageProfile() {
        let imageSize = round(UIScreen.main.bounds.size.width / 4)
        let imageY = mapViewHeight - round(imageSize / 2)
        
        if let imageFile = (userInfo as AnyObject).value(forKey: "ProfilePicture") as? PFFile {
            imageFile.getDataInBackground { (imageData, error) -> Void in
                guard error == nil else { print("image no data error."); return }

                let profileImage = UIImageView(frame: CGRect(x: 17, y: imageY, width: imageSize, height: imageSize))
                profileImage.image = UIImage(data: imageData!)!
                profileImage.layer.borderColor = UIColor.white.cgColor
                profileImage.layer.borderWidth = 3
                profileImage.layer.cornerRadius = 10
                profileImage.layer.masksToBounds = true
                profileImage.isUserInteractionEnabled = true
                profileImage.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(self.didClickImageView)))
                self.myHeaderView.addSubview(profileImage)
            }
        }
    }

    func didClickImageView(_ recognizer: UIGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView {
            let vc = PickerViewController()
            vc.palKind = "imageView"
            vc.palInput = UIImageView(image: imageView.image)
            
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func setGoogleMap() {
        let gmaps = GMSMapView()
        gmaps.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: mapViewHeight)
        gmaps.isMyLocationEnabled = false
        gmaps.settings.myLocationButton = false
        gmaps.delegate = self
        
        if type == ProfileType.meetupProfile || type == ProfileType.receiveProfile {
            GoogleMapsHelper.setUserPin(gmaps, geoPoint: targetGeoPoint)
        } else {
            GoogleMapsHelper.setUserMarker(gmaps, user: userInfo! as PFObject, isSelect: true)
        }
        
        self.myHeaderView.addSubview(gmaps)
    }
}
