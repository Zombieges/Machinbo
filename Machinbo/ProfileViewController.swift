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

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var sex: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var profile: UITextField!
    
    @IBOutlet weak var impPhotoButton: UIButton!
    
    @IBOutlet weak var editButon: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    var picker: UIImagePickerController?
    var window: UIWindow?
    var myImagePicker: UIImagePickerController!
    var myImageView: UIImageView!
    var myViewController: UIViewController?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // control init
        name.enabled = false
        sex.enabled = false
        age.enabled = false
        profile.enabled = false
        editButon.hidden = false
        cancelButton.hidden = true
        impPhotoButton.hidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editDepression(sender: AnyObject) {
        
        // control init
        name.enabled = true
        sex.enabled = true
        age.enabled = true
        profile.enabled = true
        editButon.hidden = true
        cancelButton.hidden = false
        impPhotoButton.hidden = false
    }
    
    @IBAction func cancelDepression(sender: AnyObject) {
        
        // control init
        name.enabled = false
        sex.enabled = false
        age.enabled = false
        profile.enabled = false
        editButon.hidden = false
        cancelButton.hidden = true
        impPhotoButton.hidden = true
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
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
