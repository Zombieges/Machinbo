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
    case TargetProfile, ImaikuTargetProfile, ImakuruTargetProfile
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
    
    var userInfo: AnyObject = []
    var gonowInfo: AnyObject = []
    var targetObjectID = ""
    var targetGeoPoint = PFGeoPoint(latitude: 0, longitude: 0)

    var myHeaderView = UIView()
    var displayWidth = CGFloat()
    var displayHeight = CGFloat()
    var innerViewHeight: CGFloat!

    //Targetの情報
    private let targetProfileItems = ["名前", "性別", "年齢", "プロフィール"]
    //いまから来る人の詳細情報
    private let imakuruItems = ["到着時間"]
    //
    private let otherItems = ["登録時間", "場所", "特徴"]
    
    // Sectionで使用する配列を定義する.
    private var sections: NSArray = []

    private let detailTableViewCellIdentifier = "DetailCell"
    
    private let mapTableViewCellIdentifier = "MapCell"
    
    var type = ProfileType.TargetProfile
    
    init (type: ProfileType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        if let view = UINib(nibName: "TargetProfileView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        PersistentData.deleteUserIDForKey("imaikuFlag")
        
        // MAPの高さは端末Heightの1/5
        let mapViewHeight = round(UIScreen.mainScreen().bounds.size.height / 5)
        let imageSize = round(UIScreen.mainScreen().bounds.size.width / 4)
        let imageY = mapViewHeight - round(imageSize / 2)
        // TableViewに配置するViewのHeight
        let gmapsY = round(mapViewHeight / 2)
        innerViewHeight = mapViewHeight + gmapsY
        
        do {
            // UITableView
            
            let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle:nil)
            tableView.registerNib(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
            tableView.estimatedRowHeight = 100.0
            tableView.rowHeight = UITableViewAutomaticDimension
            //tableViewの位置を 1 / 端末サイズ 下げる
            tableView.contentInset.top = innerViewHeight
            
            // 不要行の削除
            let notUserRowView = UIView(frame: CGRectZero)
            notUserRowView.backgroundColor = UIColor.clearColor()
            tableView.tableFooterView = notUserRowView
            tableView.tableHeaderView = notUserRowView
        
            view.addSubview(tableView)
        }
        
        self.displayWidth = UIScreen.mainScreen().bounds.size.width
        self.displayHeight = UIScreen.mainScreen().bounds.size.height
        
        //ヘッダー
        myHeaderView = UIView(frame: CGRect(x: 0, y: -innerViewHeight, width: self.self.displayHeight, height: innerViewHeight))
        myHeaderView.backgroundColor = UIColor.whiteColor()
    
        tableView.addSubview(myHeaderView)
        
        do {
            //Google Map 登録

            let gmaps = GMSMapView()
            //gmaps.translatesAutoresizingMaskIntoConstraints = false
            //gmaps.frame = CGRectMake(0, statusBarHeight + navBarHeight!, UIScreen.mainScreen().bounds.size.width, mapViewHeight)
            gmaps.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, mapViewHeight)
            gmaps.myLocationEnabled = false
            gmaps.settings.myLocationButton = false
            //gmaps.camera = camera
            gmaps.delegate = self
            
            if type == ProfileType.ImakuruTargetProfile {
                GoogleMapsHelper.setUserPin(gmaps, geoPoint: targetGeoPoint)
            } else {
                GoogleMapsHelper.setUserMarker(gmaps, user: userInfo as! PFObject, isSelect: true)
                
            }
            
            myHeaderView.addSubview(gmaps)
        }
        
        do {
            // 画像表示
            
            let profileImage = UIImageView(frame: CGRectMake(17, imageY, imageSize, imageSize))
            
            if let imageFile = userInfo.valueForKey("ProfilePicture") as? PFFile {
                imageFile.getDataInBackgroundWithBlock { (imageData, error) -> Void in
                    if(error == nil) {
                        profileImage.image = UIImage(data: imageData!)!
                        profileImage.layer.borderColor = UIColor.whiteColor().CGColor
                        profileImage.layer.borderWidth = 3
                        profileImage.layer.cornerRadius = 10
                        profileImage.layer.masksToBounds = true
                        
                        profileImage.userInteractionEnabled = true
                        
                        let gesture = UITapGestureRecognizer(target:self, action: #selector(self.didClickImageView))
                        profileImage.addGestureRecognizer(gesture)
                        
                        self.myHeaderView.addSubview(profileImage)
                    }
                }
            }
        }
        
        if type == ProfileType.ImaikuTargetProfile {
            self.navigationItem.title = "いまから行く人のプロフィール"
            sections = ["プロフィール", "待ち合わせ情報"]
            
            /*
             * いま行くした場合にTargetProfileViewを開いた場合
             */
            
            //いまココボタン追加
            let imakokoBtn = imakokoButton()
            let imakokoBtnX = self.displayWidth - round(self.displayWidth / 5)
            let imakokoBtnWidth = round(self.displayWidth / 6)
            let imakokoBtnHeight = round(self.displayHeight / 17)
            imakokoBtn.frame = CGRect(x: imakokoBtnX, y: mapViewHeight + 10, width: imakokoBtnWidth, height: imakokoBtnHeight)
            imakokoBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
            //button.translatesAutoresizingMaskIntoConstraints = false
            myHeaderView.addSubview(imakokoBtn)

            
            
        } else if type == ProfileType.ImakuruTargetProfile {
            
            /*
             * GoNowListViewから遷移した場合
             */
            
            sections = ["プロフィール", "来る情報"]
            
            //いま何処ボタン追加
            let imadokoBtn = imadokoButton()
            let imadokoBtnX = self.displayWidth - round(self.displayWidth / 2.5)
            let imadokoBtnWidth = round(self.displayWidth / 3)
            let imadokotnHeight = round(self.displayHeight / 17)
            imadokoBtn.frame = CGRect(x: imadokoBtnX, y: mapViewHeight + 10, width: imadokoBtnWidth, height: imadokotnHeight)
            myHeaderView.addSubview(imadokoBtn)
            
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
        let settingsButton: UIButton = UIButton(type: UIButtonType.Custom)
        settingsButton.setImage(UIImage(named: "santen.png"), forState: UIControlState.Normal)
        settingsButton.addTarget(self, action: #selector(TargetProfileViewController.onClickSettingAction), forControlEvents: .TouchUpInside)
        settingsButton.frame = CGRectMake(0, 0, 22, 22)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)

        if self.isInternetConnect() {
            //広告を表示
            self.showAdmob(AdmobType.standard)
        }
    }
    
    func didClickImageView(recognizer: UIGestureRecognizer) {
        
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
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
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section] as? String
    }
    
    /*
    テーブルに表示する配列の総数を返す.
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.targetProfileItems.count
            
        } else if section == 1 {
            var tableCellCount = 0
            
            if type == ProfileType.ImakuruTargetProfile {
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
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tableViewCellIdentifier = "Cell"
        
        var cell: UITableViewCell? // nilになることがあるので、Optionalで宣言
        if indexPath.section == 0 {
            
            if indexPath.row < 3 {
                // セルを再利用する
                var normalCell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier)
                if normalCell == nil { // 再利用するセルがなかったら（不足していたら）
                    // セルを新規に作成する。
                    normalCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: tableViewCellIdentifier)
                    normalCell!.textLabel!.font = UIFont(name: "Arial", size: 15)
                    normalCell!.detailTextLabel!.font = UIFont(name: "Arial", size: 15)
                }
                
                if indexPath.row == 0 {
                    normalCell?.textLabel?.text = targetProfileItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = self.userInfo.objectForKey("Name") as? String
                    
                } else if indexPath.row == 1 {
                    normalCell?.textLabel?.text = targetProfileItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = self.userInfo.objectForKey("Gender") as? String
                    
                } else if indexPath.row == 2 {
                    normalCell?.textLabel?.text = targetProfileItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = Parser.changeAgeRange((self.userInfo.objectForKey("Age") as? String)!)
                }
                
                cell = normalCell
                
            } else {
                
                let detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell
                
                if indexPath.row == 3 {
                    detailCell?.titleLabel.text = targetProfileItems[indexPath.row]
                    detailCell?.valueLabel.text = self.userInfo.objectForKey("Comment") as? String
                    
                }
                
                cell = detailCell
            }
            
        } else if indexPath.section == 1 {
            
            var normalCell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier)
            if normalCell == nil { // 再利用するセルがなかったら（不足していたら）
                // セルを新規に作成する。
                normalCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: tableViewCellIdentifier)
                normalCell!.textLabel!.font = UIFont(name: "Arial", size: 14)
                normalCell!.detailTextLabel!.font = UIFont(name: "Arial", size: 14)
            }
            
            if type == ProfileType.ImakuruTargetProfile {
                //いまから来る画面用の処理
                
                if indexPath.row == 0 {
                    
                    normalCell?.textLabel?.text = imakuruItems[indexPath.row]
                    
                    let dateFormatter = NSDateFormatter();
                    dateFormatter.dateFormat = "yyyy年M月d日 H:mm"
                    let formatDateString = dateFormatter.stringFromDate(self.gonowInfo.objectForKey("gotoAt") as! NSDate)
                    
                    normalCell?.detailTextLabel?.text = formatDateString
                    
                    cell = normalCell
                    
                }
                
                return cell!
                
            } else {
            
                if indexPath.row == 0 {
                    
                    normalCell?.textLabel?.text = otherItems[indexPath.row]
                    
                    let dateFormatter = NSDateFormatter();
                    dateFormatter.dateFormat = "yyyy年M月d日 H:mm"
                    if let mark = self.userInfo.objectForKey("MarkTime") {
                        let formatDateString = dateFormatter.stringFromDate(mark as! NSDate)
                        normalCell?.detailTextLabel?.text = formatDateString
                    }
                    
                    cell = normalCell
                    
                } else if indexPath.row == 1 {
                    let detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell
                    
                    detailCell?.titleLabel.text = otherItems[indexPath.row]
                    detailCell?.valueLabel.text = self.userInfo.objectForKey("PlaceDetail") as? String
                    
                    cell = detailCell
                    
                } else if indexPath.row == 2 {
                    let detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell
                    
                    detailCell?.titleLabel.text = otherItems[indexPath.row]
                    detailCell?.valueLabel.text = self.userInfo.objectForKey("MyChar") as? String

                    cell = detailCell
                }
            }

        }
        
        return cell!
    }
    
    func imaikuButton() -> ZFRippleButton {
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        btn.trackTouchLocation = true
        btn.backgroundColor = UIColor.hex("55acee", alpha: 1)
        btn.layer.borderColor = UIColor.whiteColor().CGColor
        btn.layer.borderWidth = 3
        btn.layer.cornerRadius = 7
        btn.layer.masksToBounds = true
        
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0x2196F3)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xBBDEFB)
        btn.addTarget(self, action: #selector(clickImaikuButton), forControlEvents: .TouchUpInside)
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        btn.setImage(UIImage(named: "imaiku.png"), forState: .Normal)
        btn.imageView?.contentMode = .ScaleAspectFit
        
        return btn
    }
    
    /**
     * いまここだよボタン
     */
    func imakokoButton() -> ZFRippleButton {
        
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        btn.trackTouchLocation = true
        btn.backgroundColor = UIColor.hex("55acee", alpha: 1)
        btn.layer.borderColor = UIColor.whiteColor().CGColor
        btn.layer.borderWidth = 3
        btn.layer.cornerRadius = 7
        btn.layer.masksToBounds = true
        
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0x2196F3)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xBBDEFB)
//        btn.setTitle("いまココ", forState: .Normal)
        btn.addTarget(self, action: #selector(clickimakokoButton), forControlEvents: .TouchUpInside)
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        btn.setImage(UIImage(named: "pin.png"), forState: .Normal)
        btn.imageView?.contentMode = .ScaleAspectFit
        
        
        return btn
    }
    
    
    /**
     * いま何処ボタン
     */
    func imadokoButton() -> UIButton {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(clickimadokoButton), forControlEvents: UIControlEvents.TouchUpInside)
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        
        btn.setTitle("現在位置確認", forState: .Normal)
        btn.titleLabel!.font = UIFont.systemFontOfSize(15)
        btn.layer.cornerRadius = 5.0
        btn.layer.borderColor = UIView().tintColor.CGColor
        btn.layer.borderWidth = 1.0
        btn.tintColor = UIView().tintColor
        btn.setTitleColor(UIView().tintColor, forState: .Normal)
        
        return btn
    }
    
    func clickimakokoButton() {
        
        UIAlertView.showAlertOKCancel("", message: "現在位置を相手だけに送信します") { action in
            
            if action == UIAlertView.ActionButton.Cancel {
                return
            }
            
            MBProgressHUDHelper.show("Loading...")
            
            let center = NSNotificationCenter.defaultCenter() as NSNotificationCenter
            
            LocationManager.sharedInstance.startUpdatingLocation()
            
            center.addObserver(self, selector: #selector(self.foundLocation), name: LMLocationUpdateNotification as String, object: nil)
        }
    }
    
    func foundLocation(notif: NSNotification) {
        
        defer {
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
        
        ParseHelper.getMyGoNow(PersistentData.User().userID) { (error: NSError?, result) -> Void in

            guard error == nil else {
                return
            }
            
            let info = notif.userInfo as NSDictionary!
            var location = info[LMLocationInfoKey] as! CLLocation
            
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            let query = result! as PFObject
            query["userGPS"] = PFGeoPoint(latitude: latitude, longitude: longitude)
            
            query.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                
                defer {
                    MBProgressHUDHelper.hide()
                }
                
                guard error == nil else {
                    return
                }
                
                UIAlertView.showAlertView("", message: "現在位置を相手に送信しました")
            }
        }
    }
    
    func clickimadokoButton() {
        UIAlertView.showAlertOKCancel("現在位置確認", message: "相手が、いまドコにいるのかを確認する通知を送信します") { action in
            
            if action == UIAlertView.ActionButton.Cancel {
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
                

                
            }
        }
    }
    
    func clickImaikuButton() {
        
        UIAlertView.showAlertOKCancel("いまから行くことを送信", message: "いまから行くことを相手に送信します。") { action in
            
            if action == UIAlertView.ActionButton.Cancel {
                return
            }
            
            var userInfo = PersistentData.User()
            if userInfo.imaikuFlag {
                UIAlertView.showAlertDismiss("", message: "既にいまから行く対象の人がいます。「いま行く」画面から取消を行ってください。", completion: { () -> () in })
                return
            }
            
            let vc = PickerViewController()
            vc.palTargetUser = self.userInfo as? PFObject
            vc.palKind = "imaiku"
            vc.palmItems = ["5分","10分", "15分", "20分", "25分", "30分", "35分", "40分", "45分", "50分", "55分", "60分"]
            
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func clickTorikesiButton() {
    
        //imaiku delete
        UIAlertView.showAlertOKCancel("いま行くことを取消", message: "いまから行くことを取り消しますか？") { action in
            
            if action == UIAlertView.ActionButton.Cancel {
                return
            }
            
            MBProgressHUDHelper.show("Loading...")
            
            ParseHelper.deleteGoNow(self.targetObjectID) { () -> () in
                
                defer {
                    MBProgressHUDHelper.hide()
                }
                
                //imaiku flag delete
                PersistentData.deleteUserIDForKey("imaikuFlag")
                
                self.navigationController!.popToRootViewControllerAnimated(true)
                
                UIAlertView.showAlertDismiss("", message: "取り消しました", completion: { () -> () in })
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
        let userObjectId = userInfo.objectId as String!
        let mailBody = "報告" + "¥r¥n" + "報告者：" + userObjectId
        
        mail.mailComposeDelegate = self
        mail.setSubject("報告")
        mail.setToRecipients(toRecipients) //Toアドレスの表示
        mail.setMessageBody(mailBody, isHTML: false)
        
        self.presentViewController(mail, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result {
        case MFMailComposeResultCancelled:
            print("Mail cancelled")
            break
        case MFMailComposeResultSaved:
            print("Mail saved")
            break
        case MFMailComposeResultSent:
            print("Mail sent")
            break
        case MFMailComposeResultFailed:
            print("Mail sent failure: \(error!.localizedDescription)")
            break
        default:
            break
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onClickSettingAction() {
        
        let myAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        if type == ProfileType.ImaikuTargetProfile {
            // 取り消しボタン
            let destructiveAction_1: UIAlertAction = UIAlertAction(title: "いま行くを取り消し", style: UIAlertActionStyle.Destructive, handler:{
                (action: UIAlertAction!) -> Void in
                
                self.clickTorikesiButton()
            })
            myAlert.addAction(destructiveAction_1)
        }
        
        let destructiveAction_2: UIAlertAction = UIAlertAction(title: "報告", style: UIAlertActionStyle.Destructive, handler:{
            (action: UIAlertAction!) -> Void in
            
            self.reportManager()
        })
        myAlert.addAction(destructiveAction_2)

        
        // Cancelボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("cancelAction")
        })
        myAlert.addAction(cancelAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    /*
     スクロール時
     */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
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