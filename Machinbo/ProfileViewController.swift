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

class ProfileViewController: UIViewController, UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    UIPickerViewDelegate,
    PickerViewControllerDelegate ,
    UITableViewDelegate{
    
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var TableView: UITableView!
    
    var photoItems: [String] = ["フォト"]
    var otherItems: [String] = ["名前", "性別", "年齢", "プロフィール"]
    
    var picker: UIImagePickerController?
    var window: UIWindow?
   
    var myItems:[String] = []
    
    var gender: Int? = 0
    var age: Int? = 0
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
        self.profilePicture.userInteractionEnabled = true;
        var myTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapGesture:")
        self.profilePicture.addGestureRecognizer(myTap)
        /*
        // プロフィール編集時（登録済みユーザー）
        editButon = UIBarButtonItem(title: "編集", style: .Plain, target: nil, action: "editDepression")
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
        let nibName = UINib(nibName: "DetailProfileTableViewCell", bundle:nil)
        self.TableView.registerNib(nibName, forCellReuseIdentifier: detailTableViewCellIdentifier)
        self.TableView.estimatedRowHeight = 200.0
        self.TableView.rowHeight = UITableViewAutomaticDimension
        self.view.addSubview(TableView)
        
        startButton.hidden = true

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
        
        self.presentViewController(picker!, animated: true, completion: nil)
    }
    

    // 写真選択時の処理
    internal func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let resizedSize = CGSize(width: 93, height: 93)
        UIGraphicsBeginImageContext(resizedSize)
        
        image.drawInRect(CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        profilePicture.image = resizedImage
    }
    
    // 写真選択画面でキャンセルした場合の処理
    internal func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // PickerViewController より性別を選択した際に実行される処理
    internal func setGender(selectedIndex: Int,selected: String) {
        
        self.gender = selectedIndex
        self.selectedGender = selected
        
        // テーブル再描画
        self.TableView.reloadData()
    }
    
    // PickerViewController より年齢を選択した際に実行される処理
    internal func setAge(selectedIndex: Int,selected: String) {
        
        self.age = selectedIndex
        self.selectedAge = selected
        
        // テーブル再描画
        self.TableView.reloadData()
    }
    
    // PickerViewController よりを保存ボタンを押下した際に実行される処理
    internal func setName(name: String) {
        
        self.inputName = name
        
        // テーブル再描画
        self.TableView.reloadData()
    }

    // PickerViewController よりを保存ボタンを押下した際に実行される処理
    internal func setComment(comment: String) {
        
        self.inputComment = comment
        
        // テーブル再描画
        self.TableView.reloadData()
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
                    normalCell?.detailTextLabel?.text = self.inputName as String
                
                } else if indexPath.row == 1 {
                    normalCell?.textLabel?.text = otherItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = self.selectedGender as String
                
                } else if indexPath.row == 2 {
                    normalCell?.textLabel?.text = otherItems[indexPath.row]
                    normalCell?.detailTextLabel?.text = self.selectedAge as String
                
                }
                
                
                cell = normalCell
                
            } else {
                
                let detailCell = tableView.dequeueReusableCellWithIdentifier(detailTableViewCellIdentifier, forIndexPath: indexPath) as? DetailProfileTableViewCell
                
                if indexPath.row == 3 {
                    
                    detailCell?.titleLabel.text = otherItems[indexPath.row]
                    detailCell?.valueLabel.text = self.inputComment as String
                
                }
                
                cell = detailCell
            }
        }
        
        return cell!
    }
    
    // セルがタップされた時
    internal func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        
        self.myItems = []
        let vc = PickerViewController()
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
                vc.palmItems = self.myItems
                vc.palKind = "name"
                vc.palInput = self.inputName
                vc.delegate = self
                
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 1 {
                
                self.myItems = ["男性","女性"]
                vc.palmItems = self.myItems
                vc.palKind = "gender"
                vc.palInput = self.gender!
                vc.delegate = self
                
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 2 {
                
                let date = NSDate()      // 現在日時
                let calendar = NSCalendar.currentCalendar()
                var comp : NSDateComponents = calendar.components(
                    NSCalendarUnit.CalendarUnitYear, fromDate: date)
                
                
                var i:Int = 0
                for i in 0...50 {
                    self.myItems.append((String(comp.year - i)))
                }
                
                vc.palmItems = self.myItems
                vc.palKind = "age"
                vc.palInput = self.age!
                vc.delegate = self
                
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.row == 3 {
                
                
                vc.palmItems = self.myItems
                vc.palKind = "comment"
                vc.palInput = self.inputComment
                vc.delegate = self
                
                self.navigationController?.pushViewController(vc, animated: true)

            }
        }
    }
    
    @IBAction func pushStart(sender: AnyObject) {
        let imageData = UIImagePNGRepresentation(profilePicture.image)
        let imageFile = PFFile(name:"image.png", data:imageData)
        
        ParseHelper.setUserInfomation("userid",name: self.inputName,gender: self.gender!,age: self.selectedAge ,comment: inputComment,photo: imageFile)
    }
}