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

extension MeetupViewController: TransisionProtocol {}

class MeetupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate, GADInterstitialDelegate, UITabBarDelegate {
    
    private var goNowList: [AnyObject]?
    private var meetupList: [AnyObject]?
    private var recieveList: [AnyObject]?
    private var nowSegumentIndex = 0
    private var refreshControl:UIRefreshControl!
    private let detailTableViewCellIdentifier = "GoNowCell"
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name:NSNotification.Name(rawValue: "reloadData"), object: nil)
    }
    
    override func loadView() {
        self.navigationItem.title = "いまから来る人リスト"
        self.navigationController!.navigationBar.tintColor = UIColor.darkGray
        
        if let view = UINib(nibName: "GoNowListView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.initTableView()
        self.createRefreshControl()
        self.getApprovedMeetUpList()
        self.createHeaderBottomLine()
        
        if self.isInternetConnect() {
            self.showAdmob(AdmobType.standard)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(viewWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func viewWillEnterForeground(notification: NSNotification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            self.refresh()
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let gonowCell = tableView.dequeueReusableCell(withIdentifier: detailTableViewCellIdentifier, for: indexPath) as? GoNowTableViewCell
        let userInfoObject = self.getUserInfomation(index: indexPath.row)
        
        let gonowObject = self.getGonowObject(row: indexPath.row)
        let isDeleteUser = gonowObject.object(forKey: "isDeleteUser") as! Bool
        let isDeleteTarget = gonowObject.object(forKey: "isDeleteTarget") as! Bool
        let userID = gonowObject.object(forKey: "UserID") as! String
        let targetUserID = gonowObject.object(forKey: "TargetUserID") as! String
        
        let isDelete = (userID == PersistentData.User().userID && isDeleteTarget) ||
            (targetUserID == PersistentData.User().userID && isDeleteUser)
        if isDelete {
            gonowCell?.titleLabel.text = "ユーザから拒否されました"
            gonowCell?.valueLabel.text = ""
            gonowCell?.entryTime.text = ""
            
        } else if let userInfoObject = userInfoObject {
            if let imageFile = userInfoObject.value(forKey: "ProfilePicture") as? PFFile {
                imageFile.getDataInBackground { (imageData, error) -> Void in
                    guard error == nil else { print("Error information"); return }
                    
                    gonowCell?.profileImage.image = UIImage(data: imageData!)!
                    gonowCell?.profileImage.layer.borderColor = UIColor.white.cgColor
                    gonowCell?.profileImage.layer.borderWidth = 3
                    gonowCell?.profileImage.layer.cornerRadius = 10
                    gonowCell?.profileImage.layer.masksToBounds = true
                }
            }
            
            gonowCell?.titleLabel.text = userInfoObject.object(forKey: "Name") as? String
            gonowCell?.valueLabel.text = userInfoObject.object(forKey: "Comment") as? String
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年M月d日 H:mm"
            gonowCell?.entryTime.text = dateFormatter.string(from: gonowObject.object(forKey: "gotoAt") as! Date)
            
        } else {
            gonowCell?.titleLabel.text = "このユーザは存在しません"
            gonowCell?.valueLabel.text = ""
            gonowCell?.entryTime.text = ""
        }
        
        return gonowCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userInfoObject = self.getUserInfomation(index: indexPath.row)
        
        guard userInfoObject != nil else {
            UIAlertController.showAlertView("", message: "ユーザが存在しません。")
            return
        }
        
        let gonowObject = getGonowObject(row: indexPath.row)
        let isDeleteUser = gonowObject.object(forKey: "isDeleteUser") as! Bool
        let isDeleteTarget = gonowObject.object(forKey: "isDeleteTarget") as! Bool
        
        guard !isDeleteUser && !isDeleteTarget else {
            UIAlertController.showAlertOKCancel("", message: "ユーザから拒否されました。削除しますか？", actiontitle: "削除") { action in
                guard action == .ok else { return }
                self.deleteGoNow(row: indexPath.row)
            }
            return
        }
        
        let type = nowSegumentIndex <= 1 ? ProfileType.meetupProfile : ProfileType.receiveProfile
        let vc = TargetProfileViewController(type: type)
        vc.userInfo = userInfoObject
        vc.gonowInfo = gonowObject as? PFObject

        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            UIAlertController.showAlertOKCancel("", message: "削除します。よろしいですか？", actiontitle: "削除") { action in
                guard action == .ok else { return }
                
                self.deleteAction(row: indexPath.row)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
            UIAlertController.showAlertOKCancel("", message: "削除します。よろしいですか？", actiontitle: "削除") { action in
                guard action == .ok else { return }
                
                self.deleteAction(row: indexPath.row)
            }
        }
        deleteButton.backgroundColor = UIColor.red
        
        let blockButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "ブロック") { (action, index) -> Void in
            UIAlertController.showAlertOKCancel("", message: "ブロックします。よろしいですか？", actiontitle: "ブロック") { action in
                guard action == .ok else { return }
                //Block処理を追加
                //UserInfoにブロックArrayを追加->Arrayに追加（Json形式が良さげ？）
            }
            tableView.isEditing = false
            print("ブロック")
        }
        
        return [deleteButton, blockButton]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    @IBAction func changeSegmentedControl(_ sender: UISegmentedControl) {
        self.nowSegumentIndex = sender.selectedSegmentIndex
        
        MBProgressHUDHelper.show("Loading...")
        defer { MBProgressHUDHelper.hide() }
        
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
    }
    
    private func initTableView() {
        let nibName = UINib(nibName: "GoNowTableViewCell", bundle:nil)
        self.tableView.register(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let noUseCell = UIView(frame: CGRect.zero)
        noUseCell.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = noUseCell
        self.tableView.tableHeaderView = noUseCell
        self.view.addSubview(tableView)
    }
    
    private func createHeaderBottomLine() {
        self.headerView.layer.borderWidth = 0.3
        self.headerView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func createRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    
    func reloadData(_ notification:Notification) {
        self.tableView.reloadData()
    }
    
    func refresh() {
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

//    internal func segconChanged(segcon: UISegmentedControl){
//        switch segcon.selectedSegmentIndex {
//        default:
//            print("Error")
//        }
//    }
    
    func getApprovedMeetUpList() {
        ParseHelper.getApprovedMeetupList(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            guard error == nil else { print("Error information"); return }
            self.goNowList = result
            self.tableView.reloadData()
        }
    }
    
    func getMeetUpList() {
        ParseHelper.getMeetupList(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            guard error == nil else { print("Error information"); return }
            self.meetupList = result
            self.tableView.reloadData()
        }
    }
    
    func getReceiveList() {
        ParseHelper.getReceiveList(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            guard error == nil else { print("Error information"); return }
            self.recieveList = result
            self.tableView.reloadData()
        }
    }
    
    private func deleteAction(row: Int) {
        let gonowObject = getGonowObject(row: row) as! PFObject
        let isDeleteUser = gonowObject.object(forKey: "isDeleteUser") as! Bool
        let isDeleteTarget = gonowObject.object(forKey: "isDeleteTarget") as! Bool
        
        MBProgressHUDHelper.show("Loading...")
        defer { MBProgressHUDHelper.hide() }
        
        guard !isDeleteUser && !isDeleteTarget else {
            self.deleteGoNow(row: row)
            return
        }
        
        let userID = gonowObject.object(forKey: "UserID") as! String
        let targetUserID = gonowObject.object(forKey: "TargetUserID") as! String
        
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
