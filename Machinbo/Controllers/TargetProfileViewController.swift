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

enum ProfileType {
    case TargetProfile, ImaikuTargetProfile, ImakuruTargetProfile
}

extension TargetProfileViewController: TransisionProtocol {}

class TargetProfileViewController: UIViewController, UITableViewDelegate, GADBannerViewDelegate, GADInterstitialDelegate,MFMailComposeViewControllerDelegate {
    
    var _interstitial: GADInterstitial?
    
    let mapView: MapViewController = MapViewController()
    let modalTextLabel = UILabel()
    let lblName: String = ""
    
    var actionInfo: AnyObject?
    var userInfo: AnyObject = []
    var targetObjectID: String?
    //遷移元の画面IDを指定
    var kind: String = ""

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ProfileImage: UIImageView!
    //@IBOutlet weak var targetButton: ZFRippleButton!
    
    var targetProfileItems: [String] = ["名前", "性別", "年齢", "プロフィール"]
    var otherItems: [String] = ["登録時間", "場所", "特徴"]
    
    // Sectionで使用する配列を定義する.
    private var sections: NSArray = []

    let detailTableViewCellIdentifier: String = "DetailCell"
    
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

        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
   
        let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle:nil)
        tableView.registerNib(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension

        view.addSubview(tableView)
        
        if type == ProfileType.ImaikuTargetProfile {
            self.navigationItem.title = "いまから行く人のプロフィール"
            //targetButton.setTitle("取り消し", forState: .Normal)
            
//            //画面リフレッシュボタン
//            let tableHeight = self.view.bounds.height - self.view.bounds.height/8.3
//            let width = UIScreen.mainScreen().bounds.size.width - 40
//            let btn = ZFRippleButton(frame: CGRect(x: 20, y: tableHeight, width: width, height: 40))
//            btn.trackTouchLocation = true
//            btn.backgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
//            btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
//            btn.rippleColor = LayoutManager.getUIColorFromRGB(0xB54241)
//            btn.setTitle("取り消し", forState: .Normal)
//            btn.addTarget(self, action: #selector(TargetProfileViewController.clickImaikuButton), forControlEvents: UIControlEvents.TouchUpInside)
//            btn.layer.cornerRadius = 5.0
//            btn.layer.masksToBounds = true
//            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
//            tableView.addSubview(btn)
//            
//            //画面リフレッシュボタン
//            let tableHeight2 = self.view.bounds.height - self.view.bounds.height/8.3
//            let width2 = UIScreen.mainScreen().bounds.size.width - 40
//            let btn2 = ZFRippleButton(frame: CGRect(x: 20, y: tableHeight2, width: width2, height: 40))
//            btn2.trackTouchLocation = true
//            btn2.backgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
//            btn2.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
//            btn2.rippleColor = LayoutManager.getUIColorFromRGB(0xB54241)
//            btn2.setTitle("報告", forState: .Normal)
//            btn2.addTarget(self, action: #selector(TargetProfileViewController.clickImaikuButton), forControlEvents: UIControlEvents.TouchUpInside)
//            btn2.layer.cornerRadius = 5.0
//            btn2.layer.masksToBounds = true
//            btn2.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
//            tableView.addSubview(btn2)
        }
        
        if type == ProfileType.ImakuruTargetProfile {
            sections = ["プロフィール", " "]
            //targetButton.hidden = true
            
        } else {
            sections = ["プロフィール", "待ち合わせ情報", " "]
            
            if let actionInfo: AnyObject = self.actionInfo {
                userInfo = actionInfo.objectForKey("CreatedBy") as! PFObject
            }
        }
        
        
        if let imageFile = userInfo.valueForKey("ProfilePicture") as? PFFile {
            imageFile.getDataInBackgroundWithBlock { (imageData, error) -> Void in
                if(error == nil) {
                    self.ProfileImage.image = UIImage(data: imageData!)!
                    self.ProfileImage.layer.borderColor = UIColor.whiteColor().CGColor
                    self.ProfileImage.layer.borderWidth = 3
                    self.ProfileImage.layer.cornerRadius = 10
                    self.ProfileImage.layer.masksToBounds = true
                }
            }
        }
        
        tableView.tableFooterView = UIView()
        
        if self.isInternetConnect() {
            //広告を表示
            self.showAdmob(AdmobType.standard)
            
            let adMobID = ConfigHelper.getPlistKey("ADMOB_ID") as String
            _interstitial = GADInterstitial(adUnitID: adMobID)
            _interstitial!.delegate = self
            
            //TODOTEST：Admob ヘリクエスト
            let admobRequest:GADRequest = GADRequest()
            admobRequest.testDevices = [kGADSimulatorID]
            
            _interstitial!.loadRequest(admobRequest)
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
                tableCellCount = 1
            } else {
                tableCellCount = self.otherItems.count
            }
            
            return tableCellCount
            
        } else {
            return 2
        }
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
                
                //セルの線を消す
                normalCell!.separatorInset = UIEdgeInsetsMake(0, UIScreen.mainScreen().bounds.size.width, 0, 0);
                
                if indexPath.row == 0 {
                    normalCell?.accessoryView = reportButton()
                    cell = normalCell
                    
                }
                
                return cell!
            }
            
            if indexPath.row == 0 {
                
                normalCell?.textLabel?.text = otherItems[indexPath.row]
                
                let dateFormatter = NSDateFormatter();
                dateFormatter.dateFormat = "yyyy年M月d日 H:m"
                let formatDateString = dateFormatter.stringFromDate(self.actionInfo!.objectForKey("MarkTime") as! NSDate)
                
                normalCell?.detailTextLabel?.text = formatDateString
                
                cell = normalCell
                
            } else if indexPath.row == 1 {
                let detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell
                
                detailCell?.titleLabel.text = otherItems[indexPath.row]
                detailCell?.valueLabel.text = self.actionInfo!.objectForKey("PlaceDetail") as? String
                
                cell = detailCell
                
            } else if indexPath.row == 2 {
                let detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell
                
                detailCell?.titleLabel.text = otherItems[indexPath.row]
                detailCell?.valueLabel.text = self.actionInfo!.objectForKey("MyChar") as? String
                
                cell = detailCell
            }

        } else if indexPath.section == 2 {
            
            var normalCell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier)
            if normalCell == nil { // 再利用するセルがなかったら（不足していたら）
                // セルを新規に作成する。
                normalCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: tableViewCellIdentifier)

            }
            
            normalCell!.separatorInset = UIEdgeInsetsMake(0, UIScreen.mainScreen().bounds.size.width, 0, 0);
            
            
            if type == ProfileType.TargetProfile {
                // いまココ照会画面用処理
                
                if indexPath.row == 0 {
                    normalCell?.accessoryView = imaikuButton()
                    cell = normalCell
                    
                } else if indexPath.row == 1 {
                    normalCell?.accessoryView = reportButton()
                    cell = normalCell
                }
                
            } else if type == ProfileType.ImaikuTargetProfile {
                //いまから行く画面用処理
                
                if indexPath.row == 0 {
                    normalCell?.accessoryView = torikesiButton()
                    cell = normalCell
                    
                } else if indexPath.row == 1 {
                    normalCell?.accessoryView = reportButton()
                    cell = normalCell
                }
            }


        }
        
        return cell!
    }
    
    func imaikuButton() -> ZFRippleButton {
        let tableHeight = self.view.bounds.height - self.view.bounds.height/8.3
        let width = UIScreen.mainScreen().bounds.size.width - 40
        let btn = ZFRippleButton(frame: CGRect(x: 15, y: tableHeight, width: width, height: 38))
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xB54241)
        btn.setTitle("いまから行く", forState: .Normal)
        btn.addTarget(self, action: #selector(TargetProfileViewController.clickImaikuButton), forControlEvents: UIControlEvents.TouchUpInside)
        //                btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        
        return btn
    }
    
    func torikesiButton() -> ZFRippleButton {
        let tableHeight = self.view.bounds.height - self.view.bounds.height/8.3
        let width = UIScreen.mainScreen().bounds.size.width - 40
        let btn = ZFRippleButton(frame: CGRect(x: 15, y: tableHeight, width: width, height: 38))
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xB54241)
        btn.setTitle("取り消し", forState: .Normal)
        btn.addTarget(self, action: #selector(TargetProfileViewController.clickTorikesiButton), forControlEvents: UIControlEvents.TouchUpInside)
        //                btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        
        return btn
    }
    
    func reportButton() -> ZFRippleButton {
        let tableHeight = self.view.bounds.height - self.view.bounds.height/8.3
        let width = UIScreen.mainScreen().bounds.size.width - 40
        let btn = ZFRippleButton(frame: CGRect(x: 15, y: tableHeight, width: width, height: 38))
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xB54241)
        btn.setTitle("報告", forState: .Normal)
        btn.addTarget(self, action: #selector(TargetProfileViewController.reportManager), forControlEvents: UIControlEvents.TouchUpInside)
        //                btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        
        return btn
    }
    
    /*
    Cellが選択された際に呼び出される.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 選択中のセルが何番目か.
        print("Num: \(indexPath.row)")
        // 選択中のセルを編集できるか.
        print("Edeintg: \(tableView.editing)")
    }
    
    func showModal(sender: AnyObject){
        self.presentViewController(self.mapView, animated: true, completion: nil)
    }
    
    func clickImaikuButton(sender: AnyObject) {
        
        var userInfo = PersistentData.User()
        if userInfo.imaikuFlag {
            UIAlertView.showAlertDismiss("", message: "既にいまから行く対象の人がいます", completion: { () -> () in })
            return
        }
        
        let vc = PickerViewController()
        vc.palTargetUser = self.actionInfo as? PFObject
        vc.palKind = "imaiku"
        vc.palmItems = ["5分","10分", "15分", "20分", "25分", "30分", "35分", "40分", "45分", "50分", "55分", "60分"]
        
        self.navigationController!.pushViewController(vc, animated: true)
        
        if _interstitial!.isReady {
            _interstitial!.presentFromRootViewController(self)
        }

    }
    
    func clickTorikesiButton(sender: AnyObject) {
    
        //imaiku delete
        UIAlertView.showAlertOKCancel("", message: "いまから行くを取り消しますか？") { action in
            
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
        let address = ConfigHelper.getPlistKey("ZOMBIEGES_MAIL") as String
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
}