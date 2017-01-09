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

class MeetupViewController:
    UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    GADBannerViewDelegate,
    GADInterstitialDelegate,
    UITabBarDelegate {

    var goNowList = [AnyObject]()
    var nowSegumentIndex = 0
    var refreshControl:UIRefreshControl!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let detailTableViewCellIdentifier = "GoNowCell"
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name:NSNotification.Name(rawValue: "reloadData"), object: nil)
    }
    
    override func loadView() {
        defer {
            if self.isInternetConnect() {
                self.showAdmob(AdmobType.standard)
            }
        }
        
        self.navigationItem.title = "いまから来る人リスト"
        self.navigationController!.navigationBar.tintColor = UIColor.darkGray

        if let view = UINib(nibName: "GoNowListView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        //承認済みリストを表示
        getApprovedMeetUpList()
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: bottomLine.frame.size.height - 1, width: bottomLine.frame.size.width, height: bottomLine.frame.size.height)
        bottomLine.borderWidth = 1
        bottomLine.backgroundColor = UIColor.red.cgColor
        headerView.layer.addSublayer(bottomLine)
        headerView.layer.masksToBounds = true
        
        do {
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
        
        do {
            self.refreshControl = UIRefreshControl()
            self.refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
            self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
            self.tableView.addSubview(refreshControl)
        }
    }
    
    /*
    テーブルに表示する配列の総数を返す.
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.goNowList.count : 0
    }
    
    func getUserInfomation(index: Int) -> PFObject? {
        let gonowObject = goNowList[index] as! PFObject
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
    
    /*
    Cellに値を設定する.
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let gonowCell = tableView.dequeueReusableCell(withIdentifier: detailTableViewCellIdentifier, for: indexPath) as? GoNowTableViewCell
        
        let userInfoObject = getUserInfomation(index: indexPath.row)
        
        if let userInfoObject = userInfoObject {
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
            gonowCell?.entryTime.text = dateFormatter.string(from: goNowList[indexPath.row].object(forKey: "gotoAt") as! Date)
            
        } else {
            gonowCell?.titleLabel.text = "このユーザは存在しません"
            gonowCell?.valueLabel.text = ""
            gonowCell?.entryTime.text = ""
            
        }

        return gonowCell!
    }
    
    /*
    Cellが選択された際に呼び出される.
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Edeintg: \(tableView.isEditing)")
        
        let vc : TargetProfileViewController
        if nowSegumentIndex <= 1 {
            vc = TargetProfileViewController(type: ProfileType.meetupProfile)
        } else {
            vc = TargetProfileViewController(type: ProfileType.receiveProfile)
        }
        
        if let tempGeoPoint = goNowList[indexPath.row].object(forKey: "userGPS") {
            vc.targetGeoPoint = tempGeoPoint as! PFGeoPoint
        }
        
        let gonowObject = goNowList[indexPath.row] as! PFObject
        let userInfoObject = getUserInfomation(index: indexPath.row)
        
        guard userInfoObject != nil else {
            UIAlertController.showAlertView("", message: "ユーザが存在しません。")
            return
        }
        
        vc.userInfo = userInfoObject
        vc.gonowInfo = gonowObject
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let gonowObject = goNowList[indexPath.row] as! PFObject
            let userInfoObject = getUserInfomation(index: indexPath.row)
            let name = userInfoObject?.object(forKey: "Name") as! String
            
            UIAlertController.showAlertOKCancel("", message: name + "の「いまから行く」を拒否しますか？") { action in
                guard action == .ok else { return }
                
                MBProgressHUDHelper.show("Loading...")
                ParseHelper.deleteGoNow(gonowObject.objectId!) { () -> () in
                    MBProgressHUDHelper.hide()
                    self.goNowList.remove(at: indexPath.row)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func reloadData(_ notification:Notification) {
        self.tableView.reloadData()
    }
    
    func someFunction(_ success: ((_ success: Bool) -> Void)) {
        //Perform some tasks here
        success(true)
    }
    
    /*
     画面を下に引っ張った際に呼び出される.
     */
    func refresh() {
        self.getGoNowMeList()
        self.loadView()
        self.tableView.reloadData()
    }
    
    /*
     Parse より、イマクルした人を取得する
     */
    func getGoNowMeList(){
        
        ParseHelper.getMeetupList(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            defer { MBProgressHUDHelper.hide() }
            guard error == nil else { print("Error information"); return }
            
            self.goNowList = result!
            if self.goNowList.count == 0 {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20));
                label.textAlignment = NSTextAlignment.center
                self.view.addSubview(label)
            }
            
            // このタイミングで reloadData() を行わないと、引っ張って更新時に画面に反映されない
            self.tableView.reloadData()
        }
    }
    
    /*
     SwgmentedControlの値が変わったときに呼び出される.
     */
    internal func segconChanged(segcon: UISegmentedControl){
        switch segcon.selectedSegmentIndex {
        default:
            print("Error")
        }
    }
    
    @IBAction func changeSegmentedControl(_ sender: UISegmentedControl) {
        nowSegumentIndex = sender.selectedSegmentIndex
        
        switch sender.selectedSegmentIndex {
        case 0:
            getApprovedMeetUpList()
        case 1:
            getMeetUpList()
        case 2:
            getReceiveList()
        default:
            break
        }
    }
 
    func getApprovedMeetUpList() {
        MBProgressHUDHelper.show("Loading...")
        
        ParseHelper.getApprovedMeetupList(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            defer { MBProgressHUDHelper.hide() }
            
            guard error == nil else { print("Error information"); return }
            
            if result!.count == 0 {
                UIAlertController.showAlertView("", message: "マッチングした人が存在しません。"){ _ in }
            }
            
            self.goNowList = result!
            self.tableView.reloadData()
        }
    }
    
    func getMeetUpList() {
        MBProgressHUDHelper.show("Loading...")
        
        ParseHelper.getMeetupList(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            defer { MBProgressHUDHelper.hide() }
            guard error == nil else { print("Error information"); return }
            
            if result!.count == 0 {
                UIAlertController.showAlertView("", message: "待ち合わせ申請した人がいません。") { _ in }
            }
            
            self.goNowList = result!
            self.tableView.reloadData()
        }
    }
    
    func getReceiveList() {
        MBProgressHUDHelper.show("Loading...")
        
        ParseHelper.getReceiveList(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            defer { MBProgressHUDHelper.hide() }
            
            guard error == nil else { print("Error information"); return }
            
            if result!.count == 0 {
                UIAlertController.showAlertView("", message: "相手からの受信がありません。相手から待ち合わせ希望があった場合、リストに表示されます。") { _ in }
            }
            
            self.goNowList = result!
            self.tableView.reloadData()
        }
    }
}
