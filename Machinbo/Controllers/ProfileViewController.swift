//
//  ProfileViewController.swift
//  Machinbo
//
//  Created by Kazuhiro Watanabe on 2015/07/05.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import UIKit
import Photos
import Parse
import SpriteKit
import MBProgressHUD

class ProfileViewController: UIViewController, UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    UIPickerViewDelegate,
    PickerViewControllerDelegate ,
UITableViewDelegate{
    
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var startButton: ZFRippleButton!
    @IBOutlet weak var TableView: UITableView!
    
    let photoItems: [String] = ["フォト"]
    let otherItems: [String] = ["名前", "性別", "年齢", "プロフィール"]
    
    var mainNavigationCtrl: UINavigationController?
    var picker: UIImagePickerController?
    var window: UIWindow?
    var FarstTimeStart : Bool = false
    
    var myItems:[String] = []
    
    var gender: Int?
    var age: Int?
    var inputName: String = ""
    var selectedAge: String = ""
    var selectedGender: String = ""
    var inputComment: String = ""
    
    let identifier = "Cell" // セルのIDを定数identifierにする。
    var cell: UITableViewCell? // nilになることがあるので、Optionalで宣言
    let detailTableViewCellIdentifier: String = "DetailCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = UINib(nibName: "ProfileView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        // profilePicture をタップできるように設定
        profilePicture.userInteractionEnabled = true;
        var myTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapGesture:")
        profilePicture.addGestureRecognizer(myTap)
        
        let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle:nil)
        TableView.registerNib(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
        TableView.estimatedRowHeight = 200.0
        TableView.rowHeight = UITableViewAutomaticDimension
        
        // 不要行の削除
        var v:UIView = UIView(frame: CGRectZero)
        v.backgroundColor = UIColor.clearColor()
        TableView.tableFooterView = v
        TableView.tableHeaderView = v
        view.addSubview(TableView)
        
        if (FarstTimeStart){
            
            // 新規登録時
            var storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            var mainViewController = ProfileViewController()
            mainNavigationCtrl = UINavigationController(rootViewController: mainViewController)
            
            // navigationBar 設置
            mainNavigationCtrl!.navigationBar.barTintColor = LayoutManager.getUIColorFromRGB(0x3949AB)
            mainNavigationCtrl!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
            
            window = UIWindow(frame: UIScreen.mainScreen().bounds)
            window?.rootViewController = mainNavigationCtrl
            window?.makeKeyAndVisible()
            
            // start button 表示
            //startButton.hidden = false
            
        } else {
            
            // 通常の画面遷移
            
            
            // start button 非表示
            //startButton.hidden = true
        }
        
        // 初期画像
        profilePicture.image = UIImage(named: "photo.png")
        imageMolding(profilePicture)
        //}
        
        /*editButon = UIBarButtonItem(title: "編集", style: .Plain, target: nil, action: "editDepression")
        self.navigationItem.leftBarButtonItem = editButon
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        */
        /*
        // control Init
        name.enabled = false
        comment.enabled = false
        genderSelectButton.hidden = true
        imgPhotoButton.hidden = true
        profilePicture.hidden = true
        ageSelectButton.hidden = true
        */
        
        
        // 初回起動時（未登録ユーザ）
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // profilePicture タップ時の処理
    internal func tapGesture(sender: UITapGestureRecognizer){
        
        picker = UIImagePickerController()
        picker?.delegate = self
        picker?.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker?.allowsEditing = false
        
        presentViewController(picker!, animated: true, completion: nil)
    }
    
    
    // 写真選択時の処理
    internal func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let resizedSize = CGSize(width: 93, height: 93)
        UIGraphicsBeginImageContext(resizedSize)
        
        image.drawInRect(CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        profilePicture.image = resizedImage
        
        imageMolding(profilePicture)
    }
    
    // 写真選択画面でキャンセルした場合の処理
    internal func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // PickerViewController より性別を選択した際に実行される処理
    internal func setGender(selectedIndex: Int,selected: String) {
        
        gender = selectedIndex
        selectedGender = selected
        
        // テーブル再描画
        TableView.reloadData()
    }
    
    // PickerViewController より年齢を選択した際に実行される処理
    internal func setAge(selectedIndex: Int,selected: String) {
        
        age = selectedIndex
        selectedAge = selected
        
        // テーブル再描画
        TableView.reloadData()
    }
    
    // PickerViewController よりを保存ボタンを押下した際に実行される処理
    internal func setName(name: String) {
        
        inputName = name
        
        // テーブル再描画
        TableView.reloadData()
    }
    
    // PickerViewController よりを保存ボタンを押下した際に実行される処理
    internal func setComment(comment: String) {
        
        inputComment = comment
        
        // テーブル再描画
        TableView.reloadData()
    }
    
    /*
    テーブルに表示する配列の総数を返す.
    */
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return otherItems.count
    }
    
    /*
    Cellに値を設定する.
    */
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tableViewCellIdentifier = "Cell"
        
        // セルを再利用する。
        cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? UITableViewCell
        if cell == nil { // 再利用するセルがなかったら（不足していたら）
            // セルを新規に作成する。
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identifier)
        }
        
        
        if indexPath.section == 0 {
            if indexPath.row < 3 {
                
                var normalCell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier) as? UITableViewCell
                if normalCell == nil { // 再利用するセルがなかったら（不足していたら）
                    // セルを新規に作成する。
                    normalCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: tableViewCellIdentifier)
                }
                
                if indexPath.row == 0 {
                    normalCell?.textLabel?.text = otherItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = inputName as String
                    
                } else if indexPath.row == 1 {
                    normalCell?.textLabel?.text = otherItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = selectedGender as String
                    
                } else if indexPath.row == 2 {
                    normalCell?.textLabel?.text = otherItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = selectedAge as String
                    
                }
                
                
                cell = normalCell
                
            } else {
                
                let detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell
                
                if indexPath.row == 3 {
                    
                    detailCell?.titleLabel.text = otherItems[indexPath.row]
                    detailCell?.valueLabel.text = inputComment as String
                    
                }
                
                cell = detailCell
            }
        }
        
        return cell!
    }
    
    // セルがタップされた時
    internal func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        
        myItems = []
        let vc = PickerViewController()
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
                vc.palmItems = myItems
                vc.palKind = "name"
                vc.palInput = inputName
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 1 {
                
                myItems = ["男性","女性"]
                vc.palmItems = myItems
                vc.palKind = "gender"
                if let gender = gender{
                    
                    vc.palInput = gender
                }
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 2 {
                
                let date = NSDate()      // 現在日時
                let calendar = NSCalendar.currentCalendar()
                var comp : NSDateComponents = calendar.components(
                    NSCalendarUnit.CalendarUnitYear, fromDate: date)
                
                
                var i:Int = 0
                for i in 0...50 {
                    myItems.append((String(comp.year - i)))
                }
                
                vc.palmItems = myItems
                vc.palKind = "age"
                if let age = age{
                    
                    vc.palInput = age
                }
                vc.delegate = self
                
                navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 3 {
                
                
                vc.palmItems = myItems
                vc.palKind = "comment"
                vc.palInput = inputComment
                vc.delegate = self
                
                //let profileViewCtrl: ProfileViewController = PickerViewController()
                //self.window?.rootViewController = profileViewCtrl
                navigationController?.pushViewController(vc, animated: true)
                
            }
        }
    }
    
    
    @IBAction func pushStart(sender: AnyObject) {
        
        // 必須チェック
        if inputName.isEmpty {
            errorMessageDeisplay("名前を入力してください");
        }
        if selectedGender.isEmpty{
            errorMessageDeisplay("性別を選択してください");
        }
        if selectedAge.isEmpty{
            errorMessageDeisplay("年齢を選択してください");
        }
        
        
        let imageData = UIImagePNGRepresentation(profilePicture.image)
        let imageFile = PFFile(name:"image.png", data:imageData)
        let uuid = NSUUID().UUIDString
        
        //var user = PersistentData.User()
        //user.userID = uuid
        var user = PersistentData.User()
        user.userID = uuid
        
        NSLog("UUID" + uuid)
        
        //var isNoneNil = if let uuid = uuid && let gender = gender && let gender = gender && let selectedAge = selectedAge && let inputComment = inputComment)
        
        // 登録
        ParseHelper.setUserInfomation(uuid ,name: inputName,gender: gender!,age: selectedAge ,comment: inputComment,photo: imageFile)
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Loading..."
        
        
        // MapViewControler へ
        var storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        var mainViewController = MapViewController()
        mainNavigationCtrl = UINavigationController(rootViewController: mainViewController)
        
        mainNavigationCtrl!.navigationBar.barTintColor = LayoutManager.getUIColorFromRGB(0x3949AB)
        mainNavigationCtrl!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = mainNavigationCtrl
        self.window?.makeKeyAndVisible()
    }
    
    private func imageMolding(target : UIImageView){
        
        target.layer.borderColor = UIColor.whiteColor().CGColor
        target.layer.borderWidth = 3
        target.layer.cornerRadius = 10
        target.layer.masksToBounds = true
    }
    
    private func errorMessageDeisplay(message: String){
        
        
        let uiAlertController = UIAlertController(title: "", message: message , preferredStyle: UIAlertControllerStyle.Alert)
        
        let defaultAction:UIAlertAction = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                print("Default")
        })
        // アクションを登録
        uiAlertController.addAction(defaultAction)
        
        
        presentViewController(uiAlertController, animated: true, completion: nil)
    }
}