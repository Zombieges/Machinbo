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
    PickerViewControllerDelegate {
    
    var editButon: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var myNavigationBar: UINavigationBar!
    @IBOutlet weak var myNavigationItem: UINavigationItem!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var genderSelectButton: UIButton!
    @IBOutlet weak var ageSelectButton: UIButton!
    @IBOutlet weak var comment: UITextField!
    @IBOutlet weak var impPhotoButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var displayGender: UILabel!
    @IBOutlet weak var displayAge: UILabel!
    
    var picker: UIImagePickerController?
    var window: UIWindow?
   
    var TableView: UIViewController?
    var myItems:[String] = []
    
    var gender: Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // プロフィール編集時（登録済みユーザー）
        editButon = UIBarButtonItem(title: "編集", style: .Plain, target: nil, action: "editDepression")
        
        myNavigationBar.tintColor = UIColor(red:119.0/255, green:185.0/255, blue:66.0/255, alpha:1.0)
        
        myNavigationItem.leftBarButtonItem = editButon
        myNavigationItem.rightBarButtonItem = nil
        myNavigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        // control Init
        name.enabled = false
        comment.enabled = false
        genderSelectButton.hidden = true
        impPhotoButton.hidden = true
        profilePicture.hidden = true
        ageSelectButton.hidden = true
        startButton.hidden = true
        
        // 初回起動時（未登録ユーザ）
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func editDepression() {
        
        // control init
        name.enabled = true
        genderSelectButton.hidden = false
        comment.enabled = true
        impPhotoButton.hidden = false
        profilePicture.hidden = false
        ageSelectButton.hidden = false
        startButton.hidden = false

        
        cancelButton = UIBarButtonItem(title: "キャンセル", style: .Plain, target: self, action: "viewDidLoad")
        //self.navigationItem.leftBarButtonItem = cancelButton
        myNavigationItem.leftBarButtonItem = cancelButton
        myNavigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        
        saveButton = UIBarButtonItem(title: "保存", style: .Plain, target: self, action: "viewDidLoad")
        //self.navigationItem.rightBarButtonItem =
        myNavigationItem.rightBarButtonItem = saveButton
        myNavigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        

    }
    
    @IBAction func importPhoto(sender: AnyObject) {
        
        super.viewDidLoad()
        
        picker = UIImagePickerController()
        picker?.delegate = self
        picker?.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker?.allowsEditing = false
        
        self.presentViewController(picker!, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let resizedSize = CGSize(width: 93, height: 93)
        UIGraphicsBeginImageContext(resizedSize)
        image.drawInRect(CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        profilePicture.image = resizedImage
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    /*
    * 画面遷移
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        var PickerView:PickerViewController = segue.destinationViewController as! PickerViewController
        
        self.myItems = []
        
        
        var ChildController:PickerViewController = segue.destinationViewController as! PickerViewController
        ChildController.delegate = self
        
        if(segue.identifier == "goAgePicker") {
            
            
            let date = NSDate()      // 現在日時
            let calendar = NSCalendar.currentCalendar()
            var comp : NSDateComponents = calendar.components(
                NSCalendarUnit.CalendarUnitYear, fromDate: date)
            
            
            var i:Int = 0
            for i in 0...50 {
                
                self.myItems.append((String(comp.year - i)))
            }
            PickerView.palmItems = self.myItems
            PickerView.palKind = "age"
            
        } else if(segue.identifier == "goGenderPicker"){
            
            self.myItems = ["男性","女性"]
            PickerView.palmItems = self.myItems
            PickerView.palKind = "gender"
        }
    }
    
    func getGender(selectedIndex: Int,selected: String) {
        
        self.gender = selectedIndex
        self.displayGender.text = selected
    }
    
    func getAge(selected: String) {
        
        self.displayAge.text = selected
    }
    
    @IBAction func pushStart(sender: AnyObject) {
        
        let imageData = UIImagePNGRepresentation(profilePicture.image)
        let imageFile = PFFile(name:"image.png", data:imageData)
        
        ParseHelper.setUserInfomation("userid",name: name.text,gender: self.gender!,age: displayAge.text! ,comment: comment.text,photo: imageFile)
        
    }
}