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

enum ProfileType {
    case targetProfile, imaikuTargetProfile, meetupProfile, receiveProfile, entryTarget
}

protocol TargetProfileViewControllerDelegate {
    func postTargetViewControllerDismissionAction()
}

class TargetProfileViewController:
    UIViewController,
    UITableViewDelegate,
    GADBannerViewDelegate,
    GADInterstitialDelegate,
    MFMailComposeViewControllerDelegate,
    CLLocationManagerDelegate,
    GMSMapViewDelegate,
    TransisionProtocol {
    
    var interstitial: GADInterstitial?
    
    var targetUserInfo: PFObject?
    var type = ProfileType.targetProfile
    //var targetGeoPoint = PFGeoPoint(latitude: 0, longitude: 0)
    var gonowInfo: GonowData?
    var delegate: TargetProfileViewControllerDelegate?
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    private var refreshControl:UIRefreshControl!
    private var myHeaderView = UIView()
    private var displayWidth = CGFloat()
    private var displayHeight = CGFloat()
    private var innerViewHeight: CGFloat!
    private var sections = ["", "プロフィール", "待ち合わせ"]
    private var mapViewHeight: CGFloat!
    private let targetProfileItems = ["名前", "性別", "年齢", "プロフィール"]
    private let imakuruItems = ["到着時間"]
    private let otherItems = ["待ち合わせ開始時間", "待ち合わせ終了時間", "到着時間", "場所", "特徴"]
    private let detailTableViewCellIdentifier = "DetailCell"
    private let mapTableViewCellIdentifier = "MapCell"
    
    private lazy var dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 H:mm"
        return formatter
    }()

    private lazy var dateFormatterYYYYMMDD: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy-M-d"
        return formatter
    }()
    
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
        
        PersistentData().deleteUserIDForKey("imaikuFlag")
        
        self.setHeader()
        self.createRefreshControl()
        self.setNavigationButton()
        self.initTableView()
        self.setImageProfile()
        self.setGoogleMap()
        
        guard self.isInternetConnect() else {
            self.errorAction()
            return
        }
        
        //バナー広告
        bannerView.adUnitID = ConfigData(type: .adMobUnit).getPlistKey
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        //フル画面広告を取得
        interstitial = GADInterstitial(adUnitID: ConfigData(type: .adMobFull).getPlistKey)
        interstitial?.delegate = self
        let admobRequest:GADRequest = GADRequest()
        admobRequest.testDevices = [kGADSimulatorID]
        interstitial?.load(admobRequest)
        
        // 相手が自分のことをブロックしている場合
        if let targetUserBlockList = self.targetUserInfo?.object(forKey: "blockUserList") {
            guard !(targetUserBlockList as! [String]).contains(PersistentData.objectId) else {
                self.createBlockLabel()
                return
            }
        }
        
        // 自分が相手をブロックしている場合
        let targetUserObjectId = self.targetUserInfo?.objectId
        guard !PersistentData.blockUserList.contains(targetUserObjectId!) else {
            return
        }
        
        if type == .meetupProfile {
            if (self.gonowInfo?.IsApproved)! {
                self.createSendGeoPointButton(mapViewHeight: self.mapViewHeight)
                self.createConfirmGeoPointButton(mapViewHeight: self.mapViewHeight)
            }
            
        } else if type == .receiveProfile {
            self.createApprovedButton(mapViewHeight: self.mapViewHeight)
            
        } else if type == .entryTarget {
            self.navigationItem.hidesBackButton = true
            self.navigationItem.title = "登録情報"
            
        } else {
            if type == .entryTarget {
                self.navigationItem.hidesBackButton = true
            }
            
            self.createGoNowButton()
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
            return 0
            
        } else if section == 1 {
            return self.targetProfileItems.count
            
        } else if section == 2 {
            return self.otherItems.count
        }
        
        return 0
    }
    
    func fontForHeader() -> UIFont? {
        return UIFont(name: "BrandonGrotesque-Medium", size: 12.0)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        
        return StyleConst.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel(frame: CGRect(x: 8, y: 0, width: tableView.frame.size.width - 16, height: StyleConst.sectionHeaderHeight))
        label.font = UIFont(name: "Helvetica-Bold",size: CGFloat(13))
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textColor = StyleConst.textColorForHeader
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let tableViewCellIdentifier = "Cell"
        var cell: UITableViewCell?
        
        if indexPath.section == 1 {
            if indexPath.row < 3 {
                // セルを再利用する
                var normalCell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier)
                if normalCell == nil {
                    normalCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: tableViewCellIdentifier)
                }
                normalCell!.textLabel!.font = UIFont.systemFont(ofSize: 16)
                normalCell!.detailTextLabel!.font = UIFont.systemFont(ofSize: 16)
                
                if indexPath.row == 0 {
                    normalCell?.textLabel?.text = targetProfileItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = (self.targetUserInfo as AnyObject).object(forKey: "Name") as? String
                    
                } else if indexPath.row == 1 {
                    normalCell?.textLabel?.text = targetProfileItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = (self.targetUserInfo as AnyObject).object(forKey: "Gender") as? String
                    
                } else if indexPath.row == 2 {
                    normalCell?.textLabel?.text = targetProfileItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = Parser.changeAgeRange(((self.targetUserInfo as AnyObject).object(forKey: "Age") as? String)!)
                }
                
                cell = normalCell
                
            } else {
                let detailCell = tableView.dequeueReusableCell(withIdentifier: detailTableViewCellIdentifier, for: indexPath) as? DetailProfileTableViewCell
                
                if indexPath.row == 3 {
                    detailCell?.titleLabel.text = targetProfileItems[indexPath.row]
                    detailCell?.valueLabel.text = (self.targetUserInfo as AnyObject).object(forKey: "Comment") as? String
                    
                }
                
                cell = detailCell
            }
            
            return cell!
            
        } else if indexPath.section == 2 {
            
            var normalCell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier)
            if normalCell == nil {
                normalCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: tableViewCellIdentifier)
            }
            normalCell!.textLabel!.font = UIFont.systemFont(ofSize: 16)
            normalCell!.detailTextLabel!.font = UIFont.systemFont(ofSize: 16)
            
            if indexPath.row == 0 {
                normalCell?.textLabel?.text = otherItems[indexPath.row]
                normalCell?.detailTextLabel?.text = self.getDateformatStringForUserInfo(keyString: "MarkTime")
                
                cell = normalCell
                
            } else if indexPath.row == 1 {
                normalCell?.textLabel?.text = otherItems[indexPath.row]
                normalCell?.detailTextLabel?.text = self.getDateformatStringForUserInfo(keyString: "MarkTimeTo")
                
                cell = normalCell
                
            } else if indexPath.row == 2 {
                normalCell?.textLabel?.text = otherItems[indexPath.row]
                if let data = self.gonowInfo?.GotoAt {
                    normalCell?.detailTextLabel?.text = dateFormatter.string(from: data)
                }
                
                cell = normalCell
                
            } else if indexPath.row == 3 {
                let detailCell = tableView.dequeueReusableCell(withIdentifier: detailTableViewCellIdentifier, for: indexPath) as? DetailProfileTableViewCell
                
                detailCell?.titleLabel.text = otherItems[indexPath.row]
                detailCell?.valueLabel.text = (self.targetUserInfo as AnyObject).object(forKey: "PlaceDetail") as? String
                
                cell = detailCell
                
            } else if indexPath.row == 4 {
                let detailCell = tableView.dequeueReusableCell(withIdentifier: detailTableViewCellIdentifier, for: indexPath) as? DetailProfileTableViewCell
                
                detailCell?.titleLabel.text = otherItems[indexPath.row]
                detailCell?.valueLabel.text = (self.targetUserInfo as AnyObject).object(forKey: "MyChar") as? String
                
                cell = detailCell
            }
            
            return cell!
        }
        
        return UITableViewCell()
    }
    
    func setNavigationButton() {
        let settingsButton = UIButton(type: .custom)
        settingsButton.setImage(UIImage(named: "santen"), for: UIControlState())
        settingsButton.addTarget(self, action: #selector(self.onClickSettingAction), for: .touchUpInside)
        settingsButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }
    
    func createBlockLabel() {
        let imadokoBtnX = self.displayWidth - round(self.displayWidth / 2)
        let imadokoBtnWidth = round(self.displayWidth / 2)
        let imadokotnHeight = round(self.displayHeight / 17)
        
        let label = UILabel(frame: CGRect(x: imadokoBtnX, y: mapViewHeight + 10, width: imadokoBtnWidth, height: imadokotnHeight))
        label.text = "ブロックされています"
        label.textColor = UIColor.red
        
        self.myHeaderView.addSubview(label)
    }
    
    func createGoNowButton() {
        let imadokoBtnX = self.displayWidth - round(self.displayWidth / 3.5)
        let imadokoBtnWidth = round(self.displayWidth / 4)
        let imadokotnHeight = round(self.displayHeight / 17)
        
        let btn = ZFRippleButton(frame: CGRect(x: imadokoBtnX, y: mapViewHeight + 10, width: imadokoBtnWidth, height: imadokotnHeight))
        btn.setTitle("約束", for: UIControlState())
        btn.addTarget(self, action: #selector(self.clickGoNowButton), for: .touchUpInside)
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0x0D47A1)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0x0D47A1)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0x1976D2)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        
        self.myHeaderView.addSubview(btn)
    }
    
    func createRemoveBlockButton() {
        let imadokoBtnX = self.displayWidth - round(self.displayWidth / 3.5)
        let imadokoBtnWidth = round(self.displayWidth / 4)
        let imadokotnHeight = round(self.displayHeight / 17)
        
        let btn = ZFRippleButton(frame: CGRect(x: imadokoBtnX, y: mapViewHeight + 10, width: imadokoBtnWidth, height: imadokotnHeight))
        btn.setTitle("ブロック解除", for: UIControlState())
        btn.addTarget(self, action: #selector(self.clickRemoveBlock), for: .touchUpInside)
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0x0D47A1)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0x0D47A1)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0x1976D2)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        
        self.myHeaderView.addSubview(btn)
    }
    
    func clickGoNowButton() {
        // 既にイマ行く済みの相手には「約束」できない
        print("imaikuUserList \(PersistentData.imaikuUserList)")
        
        if let imaikuClickDate = PersistentData.isImaikuClick {
            let imaikuClickDateYYYYMMDD = dateFormatterYYYYMMDD.string(from: imaikuClickDate)
            let nowDateYYYYMMDD = dateFormatterYYYYMMDD.string(from: Date())
            
            if imaikuClickDateYYYYMMDD == nowDateYYYYMMDD {
                UIAlertController.showAlertOKCancel("", message: "一日に複数回約束をすることができません", actiontitle: "動画を見て約束を開放する") { action in
                    if action == .cancel { return }
                    
                    if self.interstitial!.isReady {
                        //isImaikuClick update
                        PersistentData.isImaikuClick = nil
                        self.interstitial!.present(fromRootViewController: self)
                    }
                }
                
                return
            }
        }
        
        if let timeTargetAvailable = PersistentData.imaikuUserList[(self.targetUserInfo?.objectId)!] {
            // 現在日付取得 && 比較
            if timeTargetAvailable > Date() {
                UIAlertController.showAlertView("", message: "既にこのユーザへ約束を送信済みです")
                return
            }
        }
        
        //isImaikuClick
        
        self.dismiss(animated: true, completion: {
            self.delegate?.postTargetViewControllerDismissionAction()
        })
        
        let vc = PickerViewController(kind: .imaiku, targetUser: self.targetUserInfo!)
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func interstitialWillDismissScreen(ad: GADInterstitial!) {
        UIAlertController.showAlertView("", message: "約束できるようになりました！")
    }
    
    func createApprovedButton(mapViewHeight: CGFloat) {
        let btn = ZFRippleButton()
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0x0D47A1, alpha: 0.8)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0x0D47A1, alpha: 0.8)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0x1976D2)
        btn.setTitle("承認する", for: UIControlState())
        btn.addTarget(self, action: #selector(self.clickApproveButton), for: .touchUpInside)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height - self.view.bounds.height/7.3)
        
        let imadokoBtnX = self.displayWidth - round(self.displayWidth / 3.8)
        let imadokoBtnWidth = round(self.displayWidth / 4)
        let imadokotnHeight = round(self.displayHeight / 17)
        btn.frame = CGRect(x: imadokoBtnX, y: mapViewHeight + 10, width: imadokoBtnWidth, height: imadokotnHeight)
        
        self.myHeaderView.addSubview(btn)
    }
    
    func clickApproveButton() {
        if let id = self.gonowInfo?.ObjectId {
            do {
                let query = PFQuery(className: "GoNow")
                let loadedObject = try query.getObjectWithId(id)
                loadedObject["IsApproved"] = true
                loadedObject.saveInBackground()
                
                self.gonowInfo = GonowData(parseObject: loadedObject)
                
                NotificationHelper.sendSpecificDevice( PersistentData.name + "さんより「承認」されました", deviceTokenAsString: self.targetUserInfo?.object(forKey: "DeviceToken") as! String, badges: 0 as Int)
                
            } catch {}
            
            UIAlertController.showAlertView("", message: "承認しました") { _ in
                let vc = MeetupViewController(type: .match)
                self.navigationController!.pushViewController(vc, animated: true)
            }
        }
    }
    
    func createSendGeoPointButton(mapViewHeight: CGFloat) {
        let btn = ZFRippleButton()
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0x0D47A1, alpha: 0.8)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0x0D47A1, alpha: 0.8)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0x1976D2)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.setTitle("位置送信", for: UIControlState())
        btn.addTarget(self, action: #selector(self.clickimakokoButton), for: .touchUpInside)
        
        let imadokoBtnX = self.displayWidth - round(self.displayWidth / 3.5)
        let imadokoBtnWidth = round(self.displayWidth / 4)
        let imadokotnHeight = round(self.displayHeight / 17)
        btn.frame = CGRect(x: imadokoBtnX, y: mapViewHeight + 10, width: imadokoBtnWidth, height: imadokotnHeight)
        
        self.myHeaderView.addSubview(btn)
    }
    
    func createConfirmGeoPointButton(mapViewHeight: CGFloat) {
        let imadokoBtnX = self.displayWidth - round(self.displayWidth / 1.8)
        let imadokoBtnWidth = round(self.displayWidth / 4)
        let imadokotnHeight = round(self.displayHeight / 17)
        
        let btn = UIButton(frame:  CGRect(x: imadokoBtnX, y: mapViewHeight + 10, width: imadokoBtnWidth, height: imadokotnHeight))
        btn.addTarget(self, action: #selector(self.clickimadokoButton), for: .touchUpInside)
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        btn.setTitle("位置確認", for: UIControlState())
        btn.layer.borderColor = LayoutManager.getUIColorFromRGB(0x0D47A1).cgColor
        btn.layer.borderWidth = 1.0
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.setTitleColor(LayoutManager.getUIColorFromRGB(0x0D47A1), for: UIControlState())
        
        self.myHeaderView.addSubview(btn)
    }
    
    func clickimakokoButton() {
        UIAlertController.showAlertOKCancel("", message: "現在のあなたの位置情報を相手だけに送信します", actiontitle: "送信") { action in
            if action == .cancel { return }
            
            LocationManager.sharedInstance.startUpdatingLocation()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.imaikuAction),
                name: NSNotification.Name(rawValue: LMLocationUpdateNotification as String as String),
                object: nil
            )
            // Notification push
            if let deviceToken = self.targetUserInfo?.object(forKey: "DeviceToken"){
                print("Device token = \(deviceToken)")
                
                NotificationHelper.sendSpecificDevice(PersistentData.name + "さんが現在地を送信しました", deviceTokenAsString: deviceToken as! String, badges: 1 as Int)
                
            }
        }
    }
    
    func imaikuAction(_ notif: Notification) {
        defer { NotificationCenter.default.removeObserver(self) }
        
        MBProgressHUDHelper.sharedInstance.show(self.view)
        
        let info = notif.userInfo as NSDictionary!
        let location = info?[LMLocationInfoKey] as! CLLocation
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let objectid = self.gonowInfo?.ObjectId
        
        let userID = self.gonowInfo?.UserID
        let targetUserID = self.gonowInfo?.TargetUserID
        
        ParseHelper.getTargetUserGoNow(objectid!) { (error: NSError?, result) -> Void in
            guard let result = result, error == nil else {
                self.errorAction()
                return
            }
            
            self.gonowInfo = GonowData(parseObject: result)
            
            let userID = self.gonowInfo?.UserID
            let targetUserID = self.gonowInfo?.TargetUserID
            let geoPoint = PFGeoPoint(latitude: latitude, longitude: longitude)
            
            //現在位置確認をする際、この待ち合わせを募集した人はuserGoNow→GoNowReceiveへ値を更新し、
            //募集に対していまから行くをした人は、targetGoNow→GoNowSendへ値を更新する
            if userID == PersistentData.userID {
                if let query = self.gonowInfo?.UserGoNow {
                    query["userGeoPoint"] = geoPoint
                    query.saveInBackground { (success: Bool, error: Error?) -> Void in
                        defer { MBProgressHUDHelper.sharedInstance.hide() }
                        guard error == nil else { return }

                        UIAlertController.showAlertView("", message: "現在位置を相手に送信しました")
                    }
                    
                    result["updateAt"] = Date()
                    result.saveInBackground()
                    
                } else {
                    defer { MBProgressHUDHelper.sharedInstance.hide() }
                    
                    let gonowReceiveObject = PFObject(className: "GoNowReceive")
                    gonowReceiveObject["userGeoPoint"] = geoPoint
                    gonowReceiveObject.saveInBackground { (success: Bool, error: Error?) -> Void in
                        defer { MBProgressHUDHelper.sharedInstance.hide() }
                        guard success, error == nil else {
                            self.errorAction()
                            return
                        }
                    }
                    
                    result["userGoNow"] = gonowReceiveObject
                    result["updateAt"] = Date()
                    result.saveInBackground { (success: Bool, error: Error?) -> Void in
                        defer { MBProgressHUDHelper.sharedInstance.hide() }
                        guard success, error == nil else {
                            self.errorAction()
                            return
                        }
                    }
                }
                
            } else if targetUserID == PersistentData.userID {
                if let query = self.gonowInfo?.TargetGoNow {
                    query["userGeoPoint"] = geoPoint
                    query.saveInBackground { (success: Bool, error: Error?) -> Void in
                        defer { MBProgressHUDHelper.sharedInstance.hide() }
                        guard success, error == nil else {
                            self.errorAction()
                            return
                        }
                        
                        UIAlertController.showAlertView("", message: "現在位置を相手に送信しました")
                    }
                    
                    result["updateAt"] = Date()
                    result.saveInBackground()
                    
                } else {
                    let gonowReceiveObject = PFObject(className: "GoNowSend")
                    gonowReceiveObject["userGeoPoint"] = geoPoint
                    gonowReceiveObject.saveInBackground { (success: Bool, error: Error?) -> Void in
                        defer { MBProgressHUDHelper.sharedInstance.hide() }
                        guard success, error == nil else {
                            self.errorAction()
                            return
                        }
                    }
                    
                    result["targetGoNow"] = gonowReceiveObject
                    result["updateAt"] = Date()
                    result.saveInBackground { (success: Bool, error: Error?) -> Void in
                        defer { MBProgressHUDHelper.sharedInstance.hide() }
                        guard success, error == nil else {
                            self.errorAction()
                            return
                        }
                    }
                }
            }
            
            self.setGoogleMap()
            self.setImageProfile()
            self.refreshControl.endRefreshing()
        }
    }
    
    func clickimadokoButton() {
        UIAlertController.showAlertOKCancel("", message: "相手に、現在位置を送信してもらう依頼をします", actiontitle: "送信") { action in
            
            if action == .cancel { return }
            
            //MBProgressHUDHelper.show("Loading...")
            
            //            ParseHelper.getMyGoNow(PersistentData.userID) { (error: NSError?, result) -> Void in
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
            
            MBProgressHUDHelper.sharedInstance.show(self.view)
            // Notification push
            if let deviceToken = self.targetUserInfo?.object(forKey: "DeviceToken"){
                print("Device token = \(deviceToken)")
                
                NotificationHelper.sendSpecificDevice(PersistentData.name + "さんから現在地確認を受信しました", deviceTokenAsString: deviceToken as! String, badges: 1 as Int)
                
                UIAlertController.showAlertView("", message: "相手に現在位置確認を送信しました")
                
                MBProgressHUDHelper.sharedInstance.hide()
                
            }

        }
    }
    
    func reportManager() {
        //メールを送信できるかチェック
        guard MFMailComposeViewController.canSendMail() else { print("Email Send Failed"); return }
        
        let address = ConfigData(type: .mail).getPlistKey
        let toRecipients = [address]
        let userObjectId = (targetUserInfo as AnyObject).objectId as String!
        let mailBody = "報告" + "\n" + "報告者：" + userObjectId! + "\n\n" + "報告内容（入力してください）："
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject("報告")
        mail.setToRecipients(toRecipients) //Toアドレスの表示
        mail.setMessageBody(mailBody, isHTML: false)
        
        self.present(mail, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case MFMailComposeResult.cancelled: print("Mail cancelled");break
        case MFMailComposeResult.saved: print("Mail saved"); break
        case MFMailComposeResult.sent: print("Mail sent"); break
        case MFMailComposeResult.failed: print("Mail sent failure: \(error!.localizedDescription)") ;break
        default: break
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
    
    func setHeader() {
        self.mapViewHeight = round(UIScreen.main.bounds.size.height / 3)
        self.innerViewHeight = self.mapViewHeight + round(self.mapViewHeight / 3)
        self.displayWidth = UIScreen.main.bounds.size.width
        self.displayHeight = UIScreen.main.bounds.size.height
        
        self.myHeaderView = UIView(frame: CGRect(x: 0, y: -innerViewHeight, width: self.self.displayHeight, height: innerViewHeight))
        self.myHeaderView.backgroundColor = UIColor.white
        self.tableView.addSubview(self.myHeaderView)
    }
    
    func initTableView() {
        let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle: nil)
        self.tableView.register(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
        self.tableView.estimatedRowHeight = 200.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.backgroundColor = StyleConst.backgroundColorForHeader
        //tableViewの位置を 1 / 端末サイズ 下げる
        self.tableView.contentInset.top = self.innerViewHeight
    }
    
    func setImageProfile() {
        let imageSize = round(UIScreen.main.bounds.size.width / 4)
        let imageY = mapViewHeight - round(imageSize / 2)
        
        if let imageFile = (targetUserInfo as AnyObject).value(forKey: "ProfilePicture") as? PFFile {
            imageFile.getDataInBackground { (imageData, error) -> Void in
                guard let imageData = imageData, error == nil else {
                    self.errorAction()
                    return
                }
                
                let profileImage = UIImageView(frame: CGRect(x: 17, y: imageY, width: imageSize, height: imageSize))
                profileImage.image = UIImage(data: imageData)
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
            let vc = PickerViewController(kind: .imageView, inputValue: UIImageView(image: imageView.image))
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func setGoogleMap() {
        let gmaps = GMSMapView()
        gmaps.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: mapViewHeight)
        gmaps.isMyLocationEnabled = false
        gmaps.settings.myLocationButton = false
        gmaps.delegate = self
        do {
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "geojson") {
                gmaps.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        if type == ProfileType.meetupProfile || type == ProfileType.receiveProfile {
            //↓こっちは待ち合わせ画面から来た場合
            GoogleMapsHelper.setUserPin(gmaps, gonowInfo: (self.gonowInfo?.pfObject)!)
            
        } else {
            GoogleMapsHelper.setUserMarker(gmaps, user: targetUserInfo! as PFObject, isSelect: true)
        }
        
        self.myHeaderView.addSubview(gmaps)
    }
    
    func getDateformatStringForUserInfo(keyString: String) -> String {
        if let data = (self.targetUserInfo as AnyObject).object(forKey: keyString) {
            return dateFormatter.string(from: data as! Date)
        }
        
        return ""
    }

    func clickRemoveBlock() {
        UIAlertController.showAlertOKCancel("", message: "ブロックしています。ブロックを解除しますか？", actiontitle: "解除") { action in
            guard action == .ok else { return }
            
            MBProgressHUDHelper.sharedInstance.show(self.view)
            ParseHelper.getMyUserInfomation(PersistentData.objectId) { (error: Error?, result: PFObject?) -> Void in
                defer {  MBProgressHUDHelper.sharedInstance.hide() }
                guard let result = result, error == nil else {
                    self.errorAction()
                    return
                }
                
                result.remove(self.targetUserInfo?.objectId! as Any, forKey: "blockUserList")
                result.saveInBackground()
                self.viewDidLoad()
            }
        }
    }
    
    private func createRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func refresh() {
        guard self.gonowInfo != nil else {
            MBProgressHUDHelper.sharedInstance.hide()
            self.refreshControl.endRefreshing()
            return
        }
        
        ParseHelper.getTargetUserGoNow(self.gonowInfo!.ObjectId) { (error: Error?, result: PFObject?) -> Void in
            defer {  MBProgressHUDHelper.sharedInstance.hide() }
            guard let result = result, error == nil else {
                self.errorAction()
                return
            }

            self.gonowInfo = GonowData(parseObject: result)
            self.setGoogleMap()
            self.setImageProfile()
            self.refreshControl.endRefreshing()
        }
    }
    
    func createRefreshButton() {
        let btn: ZFRippleButton = StyleConst.displayWideZFRippleButton("再描画")
        btn.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width / 2, height: 50)
        btn.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.touchUpInside)
        btn.layer.position = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
        self.view.addSubview(btn)
    }

}
