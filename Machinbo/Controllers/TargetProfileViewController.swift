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
    
    @IBOutlet var tableView: UITableView!
    
    let modalTextLabel = UILabel()
    let lblName: String = ""
    
    var userInfo: PFObject?
    var gonowInfo: PFObject?
    var targetObjectID = ""
    var targetGeoPoint = PFGeoPoint(latitude: 0, longitude: 0)

    var myHeaderView = UIView()
    var displayWidth = CGFloat()
    var displayHeight = CGFloat()
    var innerViewHeight: CGFloat!

    //Targetの情報
    fileprivate let targetProfileItems = ["名前", "性別", "年齢", "プロフィール"]
    //いまから来る人の詳細情報
    fileprivate let imakuruItems = ["到着時間"]
    //
    fileprivate let otherItems = ["登録時間", "場所", "特徴"]
    
    // Sectionで使用する配列を定義する.
    fileprivate var sections: NSArray = []

    fileprivate let detailTableViewCellIdentifier = "DetailCell"
    
    fileprivate let mapTableViewCellIdentifier = "MapCell"
    
    var type = ProfileType.targetProfile
    
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
        
        PersistentData.deleteUserIDForKey("imaikuFlag")
        
        // MAPの高さは端末Heightの1/5
        let mapViewHeight = round(UIScreen.main.bounds.size.height / 5)
        let imageSize = round(UIScreen.main.bounds.size.width / 4)
        let imageY = mapViewHeight - round(imageSize / 2)
        // TableViewに配置するViewのHeight
        let gmapsY = round(mapViewHeight / 2)
        innerViewHeight = mapViewHeight + gmapsY
        
        do {
            // UITableView
            
            let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle:nil)
            tableView.register(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
            tableView.estimatedRowHeight = 100.0
            tableView.rowHeight = UITableViewAutomaticDimension
            //tableViewの位置を 1 / 端末サイズ 下げる
            tableView.contentInset.top = innerViewHeight
            
            // 不要行の削除
            let notUserRowView = UIView(frame: CGRect.zero)
            notUserRowView.backgroundColor = UIColor.clear
            tableView.tableFooterView = notUserRowView
            tableView.tableHeaderView = notUserRowView
        
            view.addSubview(tableView)
        }
        
        self.displayWidth = UIScreen.main.bounds.size.width
        self.displayHeight = UIScreen.main.bounds.size.height
        
        //ヘッダー
        myHeaderView = UIView(frame: CGRect(x: 0, y: -innerViewHeight, width: self.self.displayHeight, height: innerViewHeight))
        myHeaderView.backgroundColor = UIColor.white
    
        tableView.addSubview(myHeaderView)
        
        do {
            //Google Map 登録

            let gmaps = GMSMapView()
            //gmaps.translatesAutoresizingMaskIntoConstraints = false
            //gmaps.frame = CGRectMake(0, statusBarHeight + navBarHeight!, UIScreen.mainScreen().bounds.size.width, mapViewHeight)
            gmaps.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: mapViewHeight)
            gmaps.isMyLocationEnabled = false
            gmaps.settings.myLocationButton = false
            //gmaps.camera = camera
            gmaps.delegate = self
            
            if type == ProfileType.meetupProfile || type == ProfileType.receiveProfile {
                GoogleMapsHelper.setUserPin(gmaps, geoPoint: targetGeoPoint)
            } else {
                GoogleMapsHelper.setUserMarker(gmaps, user: userInfo! as PFObject, isSelect: true)
                
            }
            
            myHeaderView.addSubview(gmaps)
        }
        
        do {
            // 画像表示
            
            let profileImage = UIImageView(frame: CGRect(x: 17, y: imageY, width: imageSize, height: imageSize))
            
            if let imageFile = (userInfo as AnyObject).value(forKey: "ProfilePicture") as? PFFile {
                imageFile.getDataInBackground { (imageData, error) -> Void in
                    if(error == nil) {
                        profileImage.image = UIImage(data: imageData!)!
                        profileImage.layer.borderColor = UIColor.white.cgColor
                        profileImage.layer.borderWidth = 3
                        profileImage.layer.cornerRadius = 10
                        profileImage.layer.masksToBounds = true
                        
                        profileImage.isUserInteractionEnabled = true
                        
                        let gesture = UITapGestureRecognizer(target:self, action: #selector(self.didClickImageView))
                        profileImage.addGestureRecognizer(gesture)
                        
                        self.myHeaderView.addSubview(profileImage)
                    }
                }
            }
        }
        
        if type == .imaikuTargetProfile {
            self.navigationItem.title = "いまから行く人のプロフィール"
            sections = ["プロフィール", "待ち合わせ情報"]
            
            /*
             * いま行くした場合にTargetProfileViewを開いた場合
             */
            
//            //いまココボタン追加
//            let imakokoBtn = imakokoButton()
//            let imakokoBtnX = self.displayWidth - round(self.displayWidth / 5)
//            let imakokoBtnWidth = round(self.displayWidth / 6)
//            let imakokoBtnHeight = round(self.displayHeight / 17)
//            imakokoBtn.frame = CGRect(x: imakokoBtnX, y: mapViewHeight + 10, width: imakokoBtnWidth, height: imakokoBtnHeight)
//            imakokoBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
//            //button.translatesAutoresizingMaskIntoConstraints = false
//            myHeaderView.addSubview(imakokoBtn)

            
            
        } else if type == .meetupProfile {
            
            /*
             * MeetupView から遷移した場合
             */
            
            sections = ["プロフィール", "来る情報"]
            
            let isApproved = (self.gonowInfo as AnyObject).object(forKey: "IsApproved") as! Bool
            if isApproved {
                //現在位置確認ボタンを追加
                let imakokoBtn = imakokoButton(mapViewHeight: mapViewHeight)
                myHeaderView.addSubview(imakokoBtn)
                let imadokoBtn = imadokoButton(mapViewHeight: mapViewHeight)
                myHeaderView.addSubview(imadokoBtn)
            }
            
        } else if type == .receiveProfile {
            
            /*
             * MeetupView から遷移した場合
             */
            
            sections = ["プロフィール", "来る情報"]
            let approveBtn = approvedButton(mapViewHeight: mapViewHeight)
            myHeaderView.addSubview(approveBtn)
            
        } else {
            /*
             * MapViewのいまココ一覧から遷移した場合
             */
            sections = ["プロフィール", "待ち合わせ情報"]
            
            let imaikuBtn = imaikuButton()
            let imaikuBtnX = self.displayWidth - round(self.displayWidth / 5)
            let imaikuBtnWidth = round(self.displayWidth / 7)
            let imaikuBtnHeight = round(self.displayHeight / 17)
            imaikuBtn.frame = CGRect(x: imaikuBtnX, y: mapViewHeight + 10, width: imaikuBtnWidth, height: imaikuBtnHeight)
            imaikuBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
            //button.translatesAutoresizingMaskIntoConstraints = false
            myHeaderView.addSubview(imaikuBtn)
            
        }
        
        /* 設定ボタンを付与 */
        let settingsButton: UIButton = UIButton(type: UIButtonType.custom)
        settingsButton.setImage(UIImage(named: "santen.png"), for: UIControlState())
        settingsButton.addTarget(self, action: #selector(TargetProfileViewController.onClickSettingAction), for: .touchUpInside)
        settingsButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)

        if self.isInternetConnect() {
            //広告を表示
            self.showAdmob(AdmobType.standard)
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
    
    /*
    セクションの数を返す.
    */
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        
        let returnSectionCount = sections.count
        /*
        if type == ProfileType.TargetProfile {
            returnSectionCount -= 1
        }*/
        
        return returnSectionCount
    }
    
    /*
    セクションのタイトルを返す.
    */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section] as? String
    }
    
    /*
    テーブルに表示する配列の総数を返す.
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.targetProfileItems.count
            
        } else if section == 1 {
            var tableCellCount = 0
            
            if type == ProfileType.meetupProfile {
                tableCellCount = self.imakuruItems.count
            
            } else {
                tableCellCount = self.otherItems.count
            }
            
            return tableCellCount
            
        }
        
        return 0
    }
    
    /*
    Cellに値を設定する.
    */
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCellIdentifier = "Cell"
        
        var cell: UITableViewCell? // nilになることがあるので、Optionalで宣言
        if indexPath.section == 0 {
            
            if indexPath.row < 3 {
                // セルを再利用する
                var normalCell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier)
                if normalCell == nil { // 再利用するセルがなかったら（不足していたら）
                    // セルを新規に作成する。
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
            
            if type == ProfileType.meetupProfile {
                //待ち合わせ画面用の処理
                
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
                    let detailCell = tableView.dequeueReusableCell(withIdentifier: detailTableViewCellIdentifier, for: indexPath) as? DetailProfileTableViewCell
                    
                    detailCell?.titleLabel.text = otherItems[indexPath.row]
                    detailCell?.valueLabel.text = (self.userInfo as AnyObject).object(forKey: "PlaceDetail") as? String
                    
                    cell = detailCell
                    
                } else if indexPath.row == 2 {
                    let detailCell = tableView.dequeueReusableCell(withIdentifier: detailTableViewCellIdentifier, for: indexPath) as? DetailProfileTableViewCell
                    
                    detailCell?.titleLabel.text = otherItems[indexPath.row]
                    detailCell?.valueLabel.text = (self.userInfo as AnyObject).object(forKey: "MyChar") as? String

                    cell = detailCell
                }
            }

        }
        
        return cell!
    }
    
    func clickImaikuButton() {
        
        UIAlertController.showAlertOKCancel("いまから行くことを送信", message: "いまから行くことを相手に送信します。") { action in
            
            guard action == .ok else {
                return
            }
            
//            var userInfo = PersistentData.User()
//            if userInfo.imaikuFlag {
//                UIAlertController.showAlertView("", message: "既にいまから行く対象の人がいます。「いま行く」画面から取消を行ってください。") { _ in
//                    return
//                }
//            }
            
            let vc = PickerViewController()
            vc.palTargetUser = self.userInfo! as PFObject
            vc.palKind = "imaiku"
            vc.palmItems = ["5分","10分", "15分", "20分", "25分", "30分", "35分", "40分", "45分", "50分", "55分", "60分"]
            
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func imaikuButton() -> ZFRippleButton {
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        btn.trackTouchLocation = true
        btn.backgroundColor = UIColor.hex("55acee", alpha: 1)
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 3
        btn.layer.cornerRadius = 7
        btn.layer.masksToBounds = true
        
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0x2196F3)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xBBDEFB)
        btn.addTarget(self, action: #selector(clickImaikuButton), for: .touchUpInside)
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        btn.setImage(UIImage(named: "imaiku.png"), for: UIControlState())
        btn.imageView?.contentMode = .scaleAspectFit
        
        return btn
    }
    
    
    /**
     * 承認ボタン
     */
    func approvedButton(mapViewHeight: CGFloat) -> UIButton {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(clickApproveButton), for: UIControlEvents.touchUpInside)
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
        
        return btn
    }
    
    /**
     * いまここだよボタン
     */
    func imakokoButton(mapViewHeight: CGFloat) -> UIButton {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(clickimakokoButton), for: UIControlEvents.touchUpInside)
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
        
        return btn
    }
    
    /**
     * いま何処ボタン
     */
    func imadokoButton(mapViewHeight: CGFloat) -> UIButton {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(clickimadokoButton), for: UIControlEvents.touchUpInside)
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
        
        return btn
    }
    
    func clickimakokoButton() {
        
        UIAlertController.showAlertOKCancel("", message: "現在位置を相手だけに送信します") { action in
            
            if action == .cancel {
                return
            }
            
            MBProgressHUDHelper.show("Loading...")
            
            let center = NotificationCenter.default as NotificationCenter
            
            LocationManager.sharedInstance.startUpdatingLocation()
            
            center.addObserver(self, selector: #selector(self.foundLocation), name: NSNotification.Name(rawValue: LMLocationUpdateNotification as String as String), object: nil)
        }
    }
    
    func foundLocation(_ notif: Notification) {
        
        defer {
            NotificationCenter.default.removeObserver(self)
        }
        
        //TODO:この処理だといまから行くが複数ある場合、送信する対象が異なってしまう恐れあり。ParseIDで見ないと駄目かも
        
        ParseHelper.getMyGoNow(PersistentData.User().userID) { (error: NSError?, result) -> Void in

            guard error == nil else {
                return
            }
            
            let info = notif.userInfo as NSDictionary!
            let location = info?[LMLocationInfoKey] as! CLLocation
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            let query = result! as PFObject
            query["userGPS"] = PFGeoPoint(latitude: latitude, longitude: longitude)
            query.saveInBackground { (success: Bool, error: Error?) -> Void in
                
                defer {
                    MBProgressHUDHelper.hide()
                }
                
                guard error == nil else {
                    return
                }
                
                UIAlertController.showAlertView("", message: "現在位置を相手に送信しました")
            }
        }
    }
    
    func clickimadokoButton() {
        UIAlertController.showAlertOKCancel("現在位置確認", message: "相手が、いまドコにいるのかを確認する通知を送信します") { action in
            
            if action == .cancel {
                return
            }
            
            MBProgressHUDHelper.show("Loading...")
            
            ParseHelper.getMyGoNow(PersistentData.User().userID) { (error: NSError?, result) -> Void in
                
                defer {
                    MBProgressHUDHelper.hide()
                }
                
                guard error == nil else {
                    return
                }
                
                //result?.objectForKey("userGPS") =
                

                UIAlertController.showAlertView("", message: "相手に現在位置確認を送信しました")
            }
        }
    }
    
    func clickApproveButton() {
        let query = PFQuery(className: "GoNow")
        if let id = (gonowInfo! as PFObject).objectId {
            do {
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
    
    func clickTorikesiButton() {
    
//        let alert = UIAlertController(title: "取消", message: "いまから行くことを取り消しますか？", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default) { action in
//            MBProgressHUDHelper.show("Loading...")
//            
//            ParseHelper.deleteGoNow(self.targetObjectID) { () -> () in
//                
//                defer {
//                    MBProgressHUDHelper.hide()
//                }
//                
//                //imaiku flag delete
//                PersistentData.deleteUserIDForKey("imaikuFlag")
//                
//                self.navigationController!.popToRootViewController(animated: true)
//                
//                UIAlertController.showAlertDismiss("", message: "取り消しました", completion: { () -> () in })
//            }
//            self.present(alert, animated: true, completion: nil)
//        }
//        alert.addAction(okAction)
//        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
//        alert.addAction(cancelAction)
        
        //imaiku delete
        UIAlertController.showAlertOKCancel("いま行くことを取消", message: "いまから行くことを取り消しますか？") { action in
            
            if action == .cancel {
                return
            }
            
            MBProgressHUDHelper.show("Loading...")
            
            ParseHelper.deleteGoNow(self.targetObjectID) { () -> () in

                PersistentData.deleteUserIDForKey("imaikuFlag")
                MBProgressHUDHelper.hide()
                self.navigationController!.popToRootViewController(animated: true)
                
                UIAlertController.showAlertView("", message: "取り消しました") { _ in }
            }
        }
    }

    
    func reportManager() {
        //メールを送信できるかチェック
        if !MFMailComposeViewController.canSendMail() {
            print("Email Send Failed")
            return
        }
        
        let mail = MFMailComposeViewController()
        let address = ConfigHelper.getPlistKey("MACHINBO_MAIL") as String
        let toRecipients = [address]
        let userObjectId = (userInfo as AnyObject).objectId as String!
        let mailBody = "報告" + "¥r¥n" + "報告者：" + userObjectId!
        
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
        
        if type == .imaikuTargetProfile {
            // 取り消しボタン
            let destructiveAction_1: UIAlertAction = UIAlertAction(title: "いま行くを取り消し", style: UIAlertActionStyle.destructive, handler:{
                (action: UIAlertAction!) -> Void in
                
                self.clickTorikesiButton()
            })
            myAlert.addAction(destructiveAction_1)
        }
        
        let destructiveAction_2: UIAlertAction = UIAlertAction(title: "報告", style: UIAlertActionStyle.destructive, handler:{
            (action: UIAlertAction!) -> Void in
            
            self.reportManager()
        })
        myAlert.addAction(destructiveAction_2)

        
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
            scrollView.contentOffset.y >= -innerViewHeight &&
            scrollView.contentOffset.y <= innerViewHeight
        
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
}
