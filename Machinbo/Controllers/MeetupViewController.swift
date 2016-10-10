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

class MeetupViewController: UIViewController,
    UITableViewDelegate,
    GADBannerViewDelegate,
    GADInterstitialDelegate {

    var goNowList = [AnyObject]()
    var refreshControl:UIRefreshControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    let detailTableViewCellIdentifier: String = "GoNowCell"
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadData), name:"reloadData", object: nil)
    }
    
    override func loadView() {
        
        defer {
            if self.isInternetConnect() {
                //広告を表示
                self.showAdmob(AdmobType.standard)
            }
        }
        
        self.navigationItem.title = "いまから来る人リスト"
        self.navigationController!.navigationBar.tintColor = UIColor.darkGrayColor()
        
        if let view = UINib(nibName: "GoNowListView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        ParseHelper.getMeetupList(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            defer {
                MBProgressHUDHelper.hide()
            }
            
            guard error == nil else { return }
            
            guard result!.count != 0 else {
                UIAlertView.showAlertView("", message: "いまから来る人が存在しません。相手から待ち合わせ希望があった場合、リストに表示されます。")
                return
            }
        }
        do {
            let nibName = UINib(nibName: "GoNowTableViewCell", bundle:nil)
            self.tableView.registerNib(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
            self.tableView.estimatedRowHeight = 100.0
            self.tableView.rowHeight = UITableViewAutomaticDimension
            
            let noUseCell = UIView(frame: CGRectZero)
            noUseCell.backgroundColor = UIColor.clearColor()
            self.tableView.tableFooterView = noUseCell
            self.tableView.tableHeaderView = noUseCell
            self.view.addSubview(tableView)
        }
        
        do {
            self.refreshControl = UIRefreshControl()
            self.refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
            self.refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
            self.tableView.addSubview(refreshControl)
        }
    }
    
    /*
    テーブルに表示する配列の総数を返す.
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.goNowList.count
            
        } else {
            return 0
        }
    }
    
    /*
    Cellに値を設定する.
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let gonowCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? GoNowTableViewCell
        
        let gonow: AnyObject! = goNowList[indexPath.row]
        
        if let imageFile = gonow.objectForKey("User")?.valueForKey("ProfilePicture") as? PFFile {
            imageFile.getDataInBackgroundWithBlock { (imageData, error) -> Void in
                
                guard error == nil else {
                    return
                }
                
                gonowCell?.profileImage.image = UIImage(data: imageData!)!
                gonowCell?.profileImage.layer.borderColor = UIColor.whiteColor().CGColor
                gonowCell?.profileImage.layer.borderWidth = 3
                gonowCell?.profileImage.layer.cornerRadius = 10
                gonowCell?.profileImage.layer.masksToBounds = true
            }
        }
        
        gonowCell?.titleLabel.text = gonow.objectForKey("User")?.objectForKey("Name") as? String
        gonowCell?.valueLabel.text = gonow.objectForKey("User")?.objectForKey("Comment") as? String
        
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy年M月d日 H:mm"
        gonowCell?.entryTime.text = dateFormatter.stringFromDate(gonow.objectForKey("gotoAt") as! NSDate)
        
        return gonowCell!
    }
    
    /*
    Cellが選択された際に呼び出される.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Num: \(indexPath.row)")
        print("Edeintg: \(tableView.editing)")
        
        let vc = TargetProfileViewController(type: ProfileType.ImakuruTargetProfile)
        
        if let tempGeoPoint = goNowList[indexPath.row].objectForKey("userGPS") {
            vc.targetGeoPoint = tempGeoPoint as! PFGeoPoint
        }
        
        vc.userInfo = goNowList[indexPath.row].objectForKey("User")!
        vc.gonowInfo = goNowList[indexPath.row]
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func tableView(tableView: UITableView,canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            let goNowObj = self.goNowList[indexPath.row] as! PFObject
            
            MBProgressHUDHelper.show("Loading...")
            
            ParseHelper.deleteGoNow(goNowObj.objectId!) { () -> () in
                
                defer {
                    MBProgressHUDHelper.hide()
                    
                    let name = goNowObj.objectForKey("User")?.objectForKey("Name") as! String
                    UIAlertView.showAlertDismiss("", message: name + "の「いまから行く」を拒否しました", completion: { () -> () in })
                }
                
                self.goNowList.removeAtIndex(indexPath.row)
                self.loadView()
                self.tableView.reloadData()
            }
        }
    }
    
    func reloadData(notification:NSNotification){
        
        self.tableView.reloadData()
    }
    
    func someFunction(success: ((success: Bool) -> Void)) {
        //Perform some tasks here
        success(success: true)
    }
    
    /*
     画面を下に引っ張った際に呼び出される.
     */
    func refresh()
    {
        self.getGoNowMeList()
        self.loadView()
        self.tableView.reloadData()
    }
    
    /*
     Parse より、イマクルした人を取得する
     */
    func getGoNowMeList(){
        
        ParseHelper.getMeetupList(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            
            defer {
                MBProgressHUDHelper.hide()
            }
            
            guard error == nil else {
                return
            }
            self.goNowList = result!
            
            if self.goNowList.count == 0 {
                let label = UILabel(frame: CGRectMake(0, 0, 100, 20));
                label.textAlignment = NSTextAlignment.Center
                self.view.addSubview(label)
            }
            
            // このタイミングで reloadData() を行わないと、引っ張って更新時に画面に反映されない
            self.tableView.reloadData()
        }
    }
}