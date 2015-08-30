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

class ProfileViewController: UIViewController, UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    UIPickerViewDelegate{
    
    
    var editButon: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var myNavigationBar: UINavigationBar!
    
    
    @IBOutlet weak var myNavigationItem: UINavigationItem!
    
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var genderSelectButton: UIButton!

    @IBOutlet weak var ageSelectButton: UIButton!
    @IBOutlet weak var profile: UITextField!
    
    @IBOutlet weak var impPhotoButton: UIButton!
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    var picker: UIImagePickerController?
    var window: UIWindow?
   
    var TableView: UIViewController?
    var myItems:[String] = []
    
    var gender: String = ""
    var age: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // uiNavigationBar Setting
        /*let first: ProfileViewController = self
        myNavigationController = UINavigationController(rootViewController: first)
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = myNavigationController
        self.window?.makeKeyAndVisible()
        */
        
        editButon = UIBarButtonItem(title: "編集", style: .Plain, target: nil, action: "editDepression")
        
        /*self.navigationItem.leftBarButtonItem = editButon
        
        self.navigationItem.rightBarButtonItem = nil;*/
        
        myNavigationItem.leftBarButtonItem = editButon
        myNavigationItem.rightBarButtonItem = nil
        
        // control Init
        name.enabled = false
        profile.enabled = false
        genderSelectButton.hidden = true
        impPhotoButton.hidden = true
        profilePicture.hidden = true
        ageSelectButton.hidden = true
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func editDepression() {
        
        // control init
        name.enabled = true
        genderSelectButton.hidden = false
        profile.enabled = true
        impPhotoButton.hidden = false
        profilePicture.hidden = false
        ageSelectButton.hidden = false
        
        cancelButton = UIBarButtonItem(title: "キャンセル", style: .Plain, target: self, action: "viewDidLoad")
        //self.navigationItem.leftBarButtonItem = cancelButton
        myNavigationItem.leftBarButtonItem = cancelButton
        
        
        saveButton = UIBarButtonItem(title: "保存", style: .Plain, target: self, action: "viewDidLoad")
        //self.navigationItem.rightBarButtonItem =
        myNavigationItem.rightBarButtonItem = saveButton

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
        
        profilePicture.image = image
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    * 画面遷移
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        var PickerView:PickerViewController = segue.destinationViewController as! PickerViewController
        
        if(segue.identifier == "goAgePicker") {
            
            
            let date = NSDate()      // 現在日時
            let calendar = NSCalendar.currentCalendar()
            var comp : NSDateComponents = calendar.components(
                NSCalendarUnit.CalendarUnitYear, fromDate: date)
            
            
            var i:Int = 0
            for i in 0...50 {
                
                self.myItems.append((String(comp.year - i)))
                PickerView.palmItems = self.myItems
            }
            
        } else if(segue.identifier == "goGenderPicker"){
            
            self.myItems = ["男性","女性"]
            PickerView.palmItems = self.myItems
        }
    }
}
