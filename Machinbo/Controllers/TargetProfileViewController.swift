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
    
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var ImageAreaView: UIView!
    
    //let mapView: MapViewController = MapViewController()
    let modalTextLabel = UILabel()
    let lblName: String = ""
    
    //var actionInfo: AnyObject?
    var userInfo: AnyObject = []
    var targetObjectID: String?
    //遷移元の画面IDを指定
    var kind: String = ""

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var ProfileImage: UIImageView!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var myHeaderView: UIView!
    var displayWidth: CGFloat!
    var displayHeight: CGFloat!
    
    var innerViewHeight: CGFloat!
    
    
    //@IBOutlet weak var targetButton: ZFRippleButton!
    
    //Targetの情報
    var targetProfileItems: [String] = ["名前", "性別", "年齢", "プロフィール"]
    //いまから来る人の詳細情報
    var imakuruItems: [String] = ["登録時間", "到達時間", "現在位置"]
    //
    var otherItems: [String] = ["登録時間", "場所", "特徴"]
    
    // Sectionで使用する配列を定義する.
    private var sections: NSArray = []

    let detailTableViewCellIdentifier: String = "DetailCell"
    
    let mapTableViewCellIdentifier: String = "MapCell"
    
    var type: ProfileType = ProfileType.TargetProfile
    
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
        
        // MAPの高さは端末Heightの1/5
        let mapViewHeight = round(UIScreen.mainScreen().bounds.size.height / 5)
        let imageSize = round(UIScreen.mainScreen().bounds.size.width / 4)
        let imageY = mapViewHeight - round(imageSize / 2)
        // TableViewに配置するViewのHeight
        let gmapsY = round(mapViewHeight / 2)
        innerViewHeight = mapViewHeight + gmapsY
        
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController!.navigationBar.shadowImage = UIImage()
        
        let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle:nil)
        tableView.registerNib(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        //tableViewの位置を 1 / 端末サイズ 下げる
        tableView.contentInset.top = innerViewHeight
        view.addSubview(tableView)
        
        displayWidth = UIScreen.mainScreen().bounds.size.width
        displayHeight = UIScreen.mainScreen().bounds.size.height
        
        //ヘッダー
        myHeaderView = UIView(frame: CGRect(x: 0, y: -innerViewHeight, width: displayHeight, height: innerViewHeight))
        myHeaderView.backgroundColor = UIColor.whiteColor()
    
        tableView.addSubview(myHeaderView)
        
        let gmaps = GMSMapView()
        //gmaps.translatesAutoresizingMaskIntoConstraints = false
        //gmaps.frame = CGRectMake(0, statusBarHeight + navBarHeight!, UIScreen.mainScreen().bounds.size.width, mapViewHeight)
        gmaps.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, mapViewHeight)
        gmaps.myLocationEnabled = false
        gmaps.settings.myLocationButton = false
        //gmaps.camera = camera
        gmaps.delegate = self
        GoogleMapsHelper.setUserMarker(gmaps, user: userInfo as! PFObject, isSelect: true)
        
        //let profileImage = UIImageView(frame: CGRectMake(17, statusBarHeight + navBarHeight! + 10 + mapViewHeight, 93, 93))
        let profileImage = UIImageView(frame: CGRectMake(17, imageY, imageSize, imageSize))
        //profileImage.translatesAutoresizingMaskIntoConstraints = false
        if let imageFile = userInfo.valueForKey("ProfilePicture") as? PFFile {
                imageFile.getDataInBackgroundWithBlock { (imageData, error) -> Void in
                    if(error == nil) {
                        profileImage.image = UIImage(data: imageData!)!
                        profileImage.layer.borderColor = UIColor.whiteColor().CGColor
                        profileImage.layer.borderWidth = 3
                        profileImage.layer.cornerRadius = 10
                        profileImage.layer.masksToBounds = true
                    }
            }
        }
        
        myHeaderView.addSubview(gmaps)
        myHeaderView.addSubview(profileImage)
        
//        self.myHeaderView.addConstraints([
////
////            /* GoogleMap AutoLayout */
//            NSLayoutConstraint(item: gmaps, attribute: .Top, relatedBy: .Equal, toItem: self.myHeaderView, attribute: .Top, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: gmaps, attribute: .Left, relatedBy: .Equal, toItem: self.myHeaderView, attribute: .Left, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: gmaps, attribute: .Width, relatedBy: .Equal, toItem: self.myHeaderView, attribute: .Width, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: gmaps, attribute: .Height, relatedBy: .Equal, toItem: self.myHeaderView, attribute: .Height, multiplier: 0.5, constant: 0),
////
//            /* Imakoko Button AutoLayout */
//            NSLayoutConstraint(item: button, attribute: .Top,    relatedBy: .Equal, toItem: self.myHeaderView,   attribute: .Top, multiplier: 1, constant: mapViewHeight + 5),
//            NSLayoutConstraint(item: button, attribute: .Right,   relatedBy: .Equal, toItem: self.myHeaderView, attribute: .Right,   multiplier: 1, constant: -10),
//            NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: self.myHeaderView, attribute: .Width, multiplier: 0.15, constant: 0),
//            NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 34)
//        ])
        
        if type == ProfileType.ImaikuTargetProfile {
            self.navigationItem.title = "いまから行く人のプロフィール"
            sections = ["プロフィール", "待ち合わせ情報"]
            
            /*
             * いま行くした場合にTargetProfileViewを開いた場合
             */
            
            //いまココボタン追加
            let imakokoBtn = imakokoButton()
            let imakokoBtnX = displayWidth - round(displayWidth / 5)
            let imakokoBtnWidth = round(displayWidth / 6)
            let imakokoBtnHeight = round(displayHeight / 17)
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
            let imadokoBtnX = displayWidth - round(displayWidth / 5)
            let imadokoBtnWidth = round(displayWidth / 7)
            let imadokotnHeight = round(displayHeight / 17)
            imadokoBtn.frame = CGRect(x: imadokoBtnX, y: mapViewHeight + 10, width: imadokoBtnWidth, height: imadokotnHeight)
            imadokoBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
            //button.translatesAutoresizingMaskIntoConstraints = false
            myHeaderView.addSubview(imadokoBtn)
            
        } else {
            /*
             * MapViewのいまココ一覧から遷移した場合
             */
            sections = ["プロフィール", "待ち合わせ情報"]
            
            let imaikuBtn = imaikuButton()
            let imaikuBtnX = displayWidth - round(displayWidth / 5)
            let imaikuBtnWidth = round(displayWidth / 7)
            let imaikuBtnHeight = round(displayHeight / 17)
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
        
//        tableView.tableHeaderView = UIView()
//        tableView.tableFooterView = UIView()
//        
        if self.isInternetConnect() {
            //広告を表示
            self.showAdmob(AdmobType.standard)
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
                }
                
                if indexPath.row == 0 {
                    normalCell?.textLabel?.text = targetProfileItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = self.userInfo.objectForKey("Name") as? String
                    
                } else if indexPath.row == 1 {
                    normalCell?.textLabel?.text = targetProfileItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = self.userInfo.objectForKey("Gender") as? String
                    
                } else if indexPath.row == 2 {
                    normalCell?.textLabel?.text = targetProfileItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = self.userInfo.objectForKey("Age") as? String
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
            }
            
            if type == ProfileType.ImakuruTargetProfile {
                //いまから来る画面用の処理
                
                if indexPath.row == 0 {
                    
                    normalCell?.textLabel?.text = imakuruItems[indexPath.row]
                    
                    let dateFormatter = NSDateFormatter();
                    dateFormatter.dateFormat = "yyyy年M月d日 H:m"
                    let formatDateString = dateFormatter.stringFromDate(self.userInfo.objectForKey("MarkTime") as! NSDate)
                    
                    normalCell?.detailTextLabel?.text = formatDateString
                    
                    cell = normalCell
                    
                } else if indexPath.row == 1 {
                    let detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell
                    
                    detailCell?.titleLabel.text = imakuruItems[indexPath.row]
                    detailCell?.valueLabel.text = self.userInfo.objectForKey("PlaceDetail") as? String
                    
                    cell = detailCell
                    
                } else if indexPath.row == 2 {
                    let detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell
                    
                    detailCell?.titleLabel.text = imakuruItems[indexPath.row]
                    detailCell?.valueLabel.text = self.userInfo.objectForKey("MyChar") as? String
                    
                    cell = detailCell
                }
                
                return cell!
                
            } else {
            
                if indexPath.row == 0 {
                    
                    normalCell?.textLabel?.text = otherItems[indexPath.row]
                    
                    let dateFormatter = NSDateFormatter();
                    dateFormatter.dateFormat = "yyyy年M月d日 H:m"
                    let formatDateString = dateFormatter.stringFromDate(self.userInfo.objectForKey("MarkTime") as! NSDate)
                    
                    normalCell?.detailTextLabel?.text = formatDateString
                    
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
        btn.addTarget(self, action: #selector(TargetProfileViewController.clickImaikuButton), forControlEvents: .TouchUpInside)
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
        btn.addTarget(self, action: #selector(TargetProfileViewController.clickimakokoButton), forControlEvents: .TouchUpInside)
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        btn.setImage(UIImage(named: "pin.png"), forState: .Normal)
        btn.imageView?.contentMode = .ScaleAspectFit
        
        
        return btn
    }
    
    
    /**
     * いま何処ボタン
     */
    func imadokoButton() -> ZFRippleButton {
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
        btn.addTarget(self, action: #selector(TargetProfileViewController.clickimadokoButton), forControlEvents: UIControlEvents.TouchUpInside)
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        btn.setImage(UIImage(named: "imadoko.png"), forState: .Normal)
        btn.imageView?.contentMode = .ScaleAspectFit
        
        return btn
    }
    
    func clickimakokoButton() {
        UIAlertView.showAlertOKCancel("", message: "現在位置を相手だけに送信します") { action in
            
            if action == UIAlertView.ActionButton.Cancel {
                return
            }
            
            let center = NSNotificationCenter.defaultCenter() as NSNotificationCenter
            
            LocationManager.sharedInstance.startUpdatingLocation()
            center.addObserver(self, selector: #selector(TargetProfileViewController.foundLocation(_:)), name: LMLocationUpdateNotification as String, object: nil)
        }
    }
    
    func foundLocation(notif: NSNotification) {
        
        ParseHelper.getMyGoNow(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            
            defer {
                MBProgressHUDHelper.hide()
            }
            
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
            }
            
            
        }
    }
    
    func clickimadokoButton() {
        UIAlertView.showAlertOKCancel("", message: "相手が、いまドコにいるのかを確認する通知を送信します") { action in
            
            if action == UIAlertView.ActionButton.Cancel {
                return
            }
            
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
            
            ParseHelper.deleteGoNow(self.targetObjectID!) { () -> () in
                
                //imaiku flag delete
                PersistentData.deleteUserIDForKey("imaikuFlag")
                
                self.navigationController!.popToRootViewControllerAnimated(true)
                
                MBProgressHUDHelper.hide()
                
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
        
//        if type == ProfileType.TargetProfile {
//            let imaikuAction: UIAlertAction = UIAlertAction(title: "いまから行く", style: UIAlertActionStyle.Default, handler:{
//                (action: UIAlertAction!) -> Void in
//                
//                self.clickImaikuButton()
//            })
//            myAlert.addAction(imaikuAction)
//        }
        
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
        
        if scrollView.contentOffset.y < -innerViewHeight {
            self.myHeaderView.frame = CGRect(x: 0, y: scrollView.contentOffset.y, width: self.displayWidth, height: innerViewHeight)
        }
    }
}