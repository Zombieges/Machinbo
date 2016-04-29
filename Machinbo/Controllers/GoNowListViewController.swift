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

class GoNowListViewController: UIViewController, UITableViewDelegate {

    var goNowList: AnyObject = []
    
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
        
        self.view.addSubview(tableView)
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
        dateFormatter.dateFormat = "yyyy年M月d日 H:m"
        let formatDateString = dateFormatter.stringFromDate(gonow.createdAt as NSDate!)
        gonowCell?.entryTime.text = formatDateString
        
        gonowCell?.gonowTime.text = gonow.objectForKey("GotoTime") as? String
        
        return gonowCell!
    }
    
    /*
    Cellが選択された際に呼び出される.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Num: \(indexPath.row)")
        print("Edeintg: \(tableView.editing)")
        
        let vc = TargetProfileViewController(type: ProfileType.ImakuruTargetProfile)
        vc.userInfo = goNowList[indexPath.row].objectForKey("User")!
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
}