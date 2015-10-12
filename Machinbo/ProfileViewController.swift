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
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var genderSelectButton: UIButton!
    @IBOutlet weak var ageSelectButton: UIButton!
    @IBOutlet weak var comment: UITextField!
    @IBOutlet weak var imgPhotoButton: UIButton!
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

        if let view = UINib(nibName: "ProfileView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
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
        imgPhotoButton.hidden = false
        profilePicture.hidden = false
        ageSelectButton.hidden = false
        startButton.hidden = false

        /*
        cancelButton = UIBarButtonItem(title: "キャンセル", style: .Plain, target: self, action: "viewDidLoad")
        //self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        
        saveButton = UIBarButtonItem(title: "保存", style: .Plain, target: self, action: "viewDidLoad")
        //self.navigationItem.rightBarButtonItem =
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        */

    }
    
    
    @IBAction func importPhoto(sender: AnyObject) {
        super.viewDidLoad()
        
        picker = UIImagePickerController()
        picker?.delegate = self
        picker?.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker?.allowsEditing = false
        
        self.presentViewController(picker!, animated: true, completion: nil)
    }

    
    @IBAction func genderButtonOnClick(sender: AnyObject) {
        //performSegueWithIdentifier("goGenderPicker", sender: nil)
        let pickerCireCtrl = PickerViewController()
        self.navigationController?.pushViewController(pickerCireCtrl, animated: true)
    }
    
    
    @IBAction func ageButtonOnClick(sender: AnyObject) {
        //performSegueWithIdentifier("goAgePicker", sender: nil)
        let pickerCireCtrl = PickerViewController()
        self.navigationController?.pushViewController(pickerCireCtrl, animated: true)
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
        var pickerView = segue.destinationViewController as! PickerViewController
        
        self.myItems = []
        
        var childController = segue.destinationViewController as! PickerViewController
        childController.delegate = self
        
        if(segue.identifier == "goAgePicker") {
            let date = NSDate()      // 現在日時
            let calendar = NSCalendar.currentCalendar()
            var comp : NSDateComponents = calendar.components(
                NSCalendarUnit.CalendarUnitYear, fromDate: date)
            
            
            var i:Int = 0
            for i in 0...50 {
                self.myItems.append((String(comp.year - i)))
            }
            
            pickerView.palmItems = self.myItems
            pickerView.palKind = "age"
            
        } else if(segue.identifier == "goGenderPicker"){
            
            self.myItems = ["男性","女性"]
            pickerView.palmItems = self.myItems
            pickerView.palKind = "gender"
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