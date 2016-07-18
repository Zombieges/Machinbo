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

extension GoNowListViewController: TransisionProtocol {}

class GoNowListViewController: UIViewController,
    UITableViewDelegate,
    GADBannerViewDelegate,
    GADInterstitialDelegate {

    var goNowList: AnyObject = []
    var refreshControl:UIRefreshControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    let detailTableViewCellIdentifier: String = "GoNowCell"
    
    override func loadView() {
        if let view = UINib(nibName: "GoNowListView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.navigationItem.title = "いまから来る人リスト"
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        let nibName = UINib(nibName: "GoNowTableViewCell", bundle:nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // 不要行の削除
        let noUseCell: UIView = UIView(frame: CGRectZero)
        noUseCell.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = noUseCell
        tableView.tableHeaderView = noUseCell
        
        // set up the refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        self.refreshControl.addTarget(self, action: #selector(GoNowListViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.view.addSubview(tableView)
        
        if self.isInternetConnect() {
            //広告を表示
            self.showAdmob(AdmobType.standard)
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
    
    /*
     画面を下に引っ張った際に呼び出される.
     */
    func refresh()
    {
        // Parse よりデータ取得し、 tableView 再描画
        getGoNowMeList()
        refreshControl.endRefreshing()
        tableView.reloadData()
        
    }
    
    /*
     Parse より、イマクルした人を取得する
     */
    func getGoNowMeList(){
        
        ParseHelper.getGoNowMeList(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            
            defer {
                MBProgressHUDHelper.hide()
            }
            
            guard error == nil else {
                return
            }
            self.goNowList = result!
            
            // このタイミングで reloadData() を行わないと、引っ張って更新時に画面に反映されない
            self.tableView.reloadData()
        }
    }
    
}