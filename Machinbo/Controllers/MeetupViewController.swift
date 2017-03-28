//
//  GoNowListViewController.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2015/12/24.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import UIKit
import Parse
import GoogleMobileAds
import MBProgressHUD

enum MeetType {
    case match, send, receive
}

class MeetupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate, GADInterstitialDelegate, UITabBarDelegate, TransisionProtocol, TargetProfileViewControllerDelegate, UIWebViewDelegate {
    
    private var goNowList: [AnyObject]?
    private var meetupList: [AnyObject]?
    private var recieveList: [AnyObject]?
    private var nowSegumentIndex = 0
    private var refreshControl:UIRefreshControl!
    private let detailTableViewCellIdentifier = "GoNowCell"
//    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    private lazy var segment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["マッチング", "送信済み", "受信済み"])
        segment.setTitleTextAttributes(NSDictionary(object: UIFont.boldSystemFont(ofSize: 15), forKey: NSFontAttributeName as NSCopying) as? [AnyHashable : Any], for: .normal)
        Array(0..<3).forEach {
            segment.setWidth((UIScreen.main.bounds.size.width - 20) / 3, forSegmentAt: $0)
        }
        segment.backgroundColor = .white
        segment.layer.cornerRadius = 5.0
        segment.clipsToBounds = true
        segment.tintColor = LayoutManager.getUIColorFromRGB(0x0D47A1, alpha: 0.8)
        segment.sizeToFit()
        segment.selectedSegmentIndex = 0;
        segment.addTarget(self, action: #selector(self.segmentChanged), for: .valueChanged)

        return segment
    }()
    
    init(type: MeetType) {
        super.init(nibName: nil, bundle: nil)
        
        if type == .match {
            self.navigationItem.hidesBackButton = true
            self.nowSegumentIndex = 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name:NSNotification.Name(rawValue: "reloadData"), object: nil)
    }
    
    override func loadView() {
//        self.navigationItem.title = "いまから来る人リスト"
//        self.navigationController!.navigationBar.tintColor = UIColor.darkGray
        
        
        self.navigationItem.titleView = segment
        
        if let view = UINib(nibName: "GoNowListView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.initTableView()
        self.createRefreshControl()
        
        let AdMobUnitID = ConfigData(type: .adMobUnit).getPlistKey
        bannerView.adUnitID = AdMobUnitID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        NotificationCenter.default.addObserver(self, selector: #selector(viewWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        self.getApprovedMeetUpList()
    }
    
    func viewWillEnterForeground(notification: NSNotification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            self.refreshAction()
            print("foreground........................>")
        }
    }
    
    func setNoMeetupTableView(count: Int) {
        if count == 0 {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            noDataLabel.text = "待ち合わせ情報がありません"
            noDataLabel.textColor        = UIColor.darkGray
            noDataLabel.textAlignment    = .center
            self.tableView.backgroundView = noDataLabel
            self.tableView.separatorStyle = .none
            
        } else {
            self.tableView.separatorStyle = .singleLine
            self.tableView.backgroundView = nil
        }

    }
    
    // TargetProfileViewから戻ってきた時の処理
    func postTargetViewControllerDismissionAction() {
        refreshAction()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.nowSegumentIndex == 0 {
            if let list = self.goNowList {
                self.setNoMeetupTableView(count: list.count)
                return list.count
            }
            
        } else if self.nowSegumentIndex == 1 {
            if let list = self.meetupList {
                self.setNoMeetupTableView(count: list.count)
                return list.count
            }
            
        } else if self.nowSegumentIndex == 2 {
            if let list = self.recieveList {
                self.setNoMeetupTableView(count: list.count)
                return list.count
            }
            
        }

        return 0
    }
    
    func getGonowObject(row: Int) -> AnyObject {
        if self.nowSegumentIndex == 0 {
            if let list = self.goNowList { return list[row] }
            
        } else if self.nowSegumentIndex == 1 {
            if let list = self.meetupList { return list[row] }
            
        } else if self.nowSegumentIndex == 2 {
            if let list = self.recieveList { return list[row] }
        }
        
        return PFObject()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section != 0 {
            return UITableViewCell()
        }
        
        let gonowCell = tableView.dequeueReusableCell(withIdentifier: detailTableViewCellIdentifier, for: indexPath) as? GoNowTableViewCell
        
        let userInfoObject = self.getUserInfomation(index: indexPath.row)
        
        let gonowObject = self.getGonowObject(row: indexPath.row)
        let isDeleteUser = gonowObject.object(forKey: "isDeleteUser") as! Bool
        let isDeleteTarget = gonowObject.object(forKey: "isDeleteTarget") as! Bool
        let userID = gonowObject.object(forKey: "UserID") as! String
        let targetUserID = gonowObject.object(forKey: "TargetUserID") as! String
        
        //相手から削除された場合（自分で削除した場合は、Parseの取得で弾く）
        let isDelete = (userID == PersistentData.User().userID && isDeleteTarget) ||
            (targetUserID == PersistentData.User().userID && isDeleteUser)
        
        guard !isDelete else {
            gonowCell?.titleLabel.text = "ユーザから削除されました"
            gonowCell?.valueLabel.text = ""
            gonowCell?.entryTime.text = ""
            gonowCell?.profileImage.image = UIImage(named: "photo@2x.png")
            gonowCell?.profileImage.layer.borderColor = UIColor.white.cgColor
            gonowCell?.profileImage.layer.borderWidth = 3
            gonowCell?.profileImage.layer.cornerRadius = 10
            gonowCell?.profileImage.layer.masksToBounds = true
            
            return gonowCell!
            
        }
        
        guard let userInfoNotNil = userInfoObject else {
            gonowCell?.titleLabel.text = "このユーザは存在しません"
            gonowCell?.valueLabel.text = ""
            gonowCell?.entryTime.text = ""
            gonowCell?.profileImage.image = UIImage(named: "photo@2x.png")
            gonowCell?.profileImage.layer.borderColor = UIColor.white.cgColor
            gonowCell?.profileImage.layer.borderWidth = 3
            gonowCell?.profileImage.layer.cornerRadius = 10
            gonowCell?.profileImage.layer.masksToBounds = true
            
            return gonowCell!
        }

        if let imageFile = userInfoNotNil.value(forKey: "ProfilePicture") as? PFFile {
            imageFile.getDataInBackground { (imageData, error) -> Void in
                guard error == nil else { print("Error information"); return }
                
                gonowCell?.profileImage.image = UIImage(data: (imageData)!)
                gonowCell?.profileImage.layer.borderColor = UIColor.white.cgColor
                gonowCell?.profileImage.layer.borderWidth = 3
                gonowCell?.profileImage.layer.cornerRadius = 10
                gonowCell?.profileImage.layer.masksToBounds = true
            }
        }
        
        gonowCell?.titleLabel.text = userInfoNotNil.object(forKey: "Name") as? String
        gonowCell?.valueLabel.text = userInfoNotNil.object(forKey: "Comment") as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月d日 H:mm"
        gonowCell?.entryTime.text = dateFormatter.string(from: gonowObject.object(forKey: "gotoAt") as! Date)
        
        return gonowCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.isInternetConnect() else {
            self.errorAction()
            return
        }
        
        let userInfoObject = self.getUserInfomation(index: indexPath.row)
        
        guard userInfoObject != nil else {
            UIAlertController.showAlertOKCancel("", message: "ユーザが存在しません。削除しますか？", actiontitle: "削除") { action in
                guard action == .ok else { return }
                self.deleteGoNow(row: indexPath.row)
            }
            return
        }
        
        let gonowObject = getGonowObject(row: indexPath.row)
        let gonowData = GonowData(parseObject: gonowObject as! PFObject)
        
        guard !gonowData.IsDeleteUser && !gonowData.IsDeleteTarget else {
            UIAlertController.showAlertOKCancel("", message: "ユーザから拒否されました。削除しますか？", actiontitle: "削除") { action in
                guard action == .ok else { return }
                self.deleteGoNow(row: indexPath.row)
            }
            return
        }
        
        let type = nowSegumentIndex <= 1 ? ProfileType.meetupProfile : ProfileType.receiveProfile
        let vc = TargetProfileViewController(type: type)
        vc.targetUserInfo = userInfoObject
        vc.gonowInfo = gonowData
        vc.type = type

        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            UIAlertController.showAlertOKCancel("", message: "削除します。よろしいですか？", actiontitle: "削除") { action in
//                guard action == .ok else { return }
//                
//                self.deleteAction(row: indexPath.row)
//            }
//        }
//    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        guard self.isInternetConnect() else {
            self.errorAction()
            return nil
        }
        
        let deleteButton = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
            UIAlertController.showAlertOKCancel("", message: "削除します。よろしいですか？", actiontitle: "削除") { action in
                guard action == .ok else { return }
                
                self.deleteAction(row: indexPath.row)
            }
        }
        deleteButton.backgroundColor = UIColor.red
        
        let blockButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "ブロック") { (action, index) -> Void in
            UIAlertController.showAlertOKCancel("", message: "ブロックしたら二度と表示されません。よろしいですか？", actiontitle: "ブロック") { action in
                guard action == .ok else { return }
                //User Block
                if let userInfoObject = self.getUserInfomation(index: indexPath.row) {
                    if let myUserInfo = self.getMyUserInfo(index: indexPath.row) {
                        myUserInfo.add(userInfoObject.objectId!, forKey: "blockUserList")
                        myUserInfo.saveInBackground()
                        
                        var data = PersistentData.User()
                        data.blockUserList = myUserInfo.object(forKey: "blockUserList") as! [String]
                    }
                }
                
                self.deleteAction(row: indexPath.row)
            }
//            tableView.isEditing = false
//            print("ブロック")
        }
        
        return [deleteButton, blockButton]
    }
    
    func segmentChanged(_ segcon: UISegmentedControl){
        guard self.isInternetConnect() else {
            self.errorAction()
            return
        }
        
        self.nowSegumentIndex = segcon.selectedSegmentIndex
        
        switch self.nowSegumentIndex {
        case 0:
            if self.goNowList == nil { self.getApprovedMeetUpList() }
        case 1:
            if self.meetupList == nil { self.getMeetUpList() }
        case 2:
            if self.recieveList == nil { self.getReceiveList() }
        default:
            break
        }
        
        self.tableView.reloadData()
    }
    
    private func initTableView() {
        let nibName = UINib(nibName: "GoNowTableViewCell", bundle:nil)
        self.tableView.register(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.rowHeight = 85.0
        self.tableView.sectionHeaderHeight = 1
    }

    private func createRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(self.refreshAction), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    
    func reloadData(_ notification:Notification) {
        self.tableView.reloadData()
    }
    
    func refreshAction() {
        guard self.isInternetConnect() else {
            self.errorAction()
            self.refreshControl.endRefreshing()
            return
        }
        
        switch self.nowSegumentIndex {
        case 0:
            self.getApprovedMeetUpList()
        case 1:
            self.getMeetUpList()
        case 2:
            self.getReceiveList()
        default:
            break
        }
        self.refreshControl.endRefreshing()
    }
    
    private func getUserInfomation(index: Int) -> PFObject? {
        let gonowObject = getGonowObject(row: index)
        var userInfoObject: PFObject?
        
        if nowSegumentIndex == 0 {
            let userID = gonowObject.object(forKey: "UserID") as! String
            let targetUserID = gonowObject.object(forKey: "TargetUserID") as! String
            
            if userID == PersistentData.User().userID {
                userInfoObject = gonowObject.object(forKey: "TargetUser") as? PFObject
                
            } else if targetUserID == PersistentData.User().userID {
                userInfoObject = gonowObject.object(forKey: "User") as? PFObject
            }
            
        } else if nowSegumentIndex == 1 {
            userInfoObject = gonowObject.object(forKey: "TargetUser") as? PFObject
            
        } else {
            userInfoObject = gonowObject.object(forKey: "User") as? PFObject
        }
        
        return userInfoObject
    }
    
    private func getMyUserInfo(index: Int) -> PFObject? {
        let gonowObject = getGonowObject(row: index)
        let userID = gonowObject.object(forKey: "UserID") as! String
        let targetUserID = gonowObject.object(forKey: "TargetUserID") as! String
        var userInfoObject: PFObject?
    
        if userID == PersistentData.User().userID {
            userInfoObject = gonowObject.object(forKey: "User") as? PFObject

        } else if targetUserID == PersistentData.User().userID {
            userInfoObject = gonowObject.object(forKey: "TargetUser") as? PFObject
        }
        
        return userInfoObject
    }
    
    func getApprovedMeetUpList() {
        guard self.isInternetConnect() else {
            self.errorAction()
            return
        }
        
        MBProgressHUDHelper.sharedInstance.show(self.view)
        
        ParseHelper.getApprovedMeetupList(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            MBProgressHUDHelper.sharedInstance.hide()
            
            guard error == nil else { print("Error information"); return }
            
            self.goNowList = result
            self.tableView.reloadData()
        }
    }
    
    func getMeetUpList() {
        MBProgressHUDHelper.sharedInstance.show(self.view)
        
        ParseHelper.getMeetupList(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            MBProgressHUDHelper.sharedInstance.hide()
            
            guard error == nil else { print("Error information"); return }
            
            self.meetupList = result
            self.tableView.reloadData()
        }
    }
    
    func getReceiveList() {
        MBProgressHUDHelper.sharedInstance.show(self.view)
        
        ParseHelper.getReceiveList(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            MBProgressHUDHelper.sharedInstance.hide()
            
            guard error == nil else { print("Error information"); return }
            
            self.recieveList = result
            self.tableView.reloadData()
        }
    }
    
    private func deleteAction(row: Int) {
        let gonowObject = getGonowObject(row: row) as! PFObject
        let isDeleteUser = gonowObject.object(forKey: "isDeleteUser") as! Bool
        let isDeleteTarget = gonowObject.object(forKey: "isDeleteTarget") as! Bool
        
        MBProgressHUDHelper.sharedInstance.show(self.view)
        
        defer { MBProgressHUDHelper.sharedInstance.hide() }
        
        guard !isDeleteUser && !isDeleteTarget else {
            self.deleteGoNow(row: row)
            return
        }
        
        let userID = gonowObject.object(forKey: "UserID") as! String
        let targetUserID = gonowObject.object(forKey: "TargetUserID") as! String
        let targetUserObjectId = gonowObject.object(forKey: "TargetUser") as! PFObject
        
        if userID == PersistentData.User().userID {
            gonowObject["isDeleteUser"] = true
            
        } else if targetUserID == PersistentData.User().userID {
            gonowObject["isDeleteTarget"] = true
        }
        
        gonowObject.saveInBackground()

        switch self.nowSegumentIndex {
        case 0:
            self.goNowList?.remove(at: row)
        case 1:
            self.meetupList?.remove(at: row)
        case 2:
            self.recieveList?.remove(at: row)
        default:
            break
        }
        
        // イマ行くリストの削除
        var userInfo = PersistentData.User()
        print("imaikuUserList \(userInfo.imaikuUserList)")

        userInfo.imaikuUserList.removeValue(forKey: targetUserObjectId.objectId!)
        
        
        self.tableView.reloadData()
    }
    
    private func deleteGoNow(row: Int) {
        let gonowObject = getGonowObject(row: row) as! PFObject
        
        ParseHelper.deleteGoNow(gonowObject.objectId!) { () -> () in
            switch self.nowSegumentIndex {
            case 0:
                self.goNowList?.remove(at: row)
            case 1:
                self.meetupList?.remove(at: row)
            case 2:
                self.recieveList?.remove(at: row)
            default:
                break
            }
            
            self.tableView.reloadData()
        }
    }
}
