//
//  PickerViewController.swift
//  Machinbo
//
//  Created by Kazuhiro Watanabe on 2015/08/02.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

protocol PickerViewControllerDelegate{
    func getGender(selectedIndex: Int,selected: String)
    func getAge(selected: String)
}


class PickerViewController: UIViewController,
    UITableViewDelegate,
    UITableViewDataSource{
    
    var delegate: PickerViewControllerDelegate?
    var saveButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    
    var selectedAge:String = ""
    var selectedGenderIndex: Int = 0
    var selectedGender: String = ""
    
    // Tableで使用する配列を設定する
    private var myTableView: UITableView!
    private var myItems: NSArray = []
    private var kind: String = ""
    var palmItems:[String] = []
    var palKind: String = ""
    var window: UIWindow?
    
    var myViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = UINib(nibName: "PickerView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        // palmater set
        self.myItems = []
        self.myItems = palmItems
        self.kind = palKind
        
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        
        
        // Viewの高さと幅を取得する.
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        // TableViewの生成する.
        myTableView = UITableView(frame: CGRect(x: 0, y: navBarHeight!, width: displayWidth, height: displayHeight - navBarHeight!))
        
        // Cell名の登録をおこなう.
        myTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        myTableView.dataSource = self
        
        // Delegateを設定する.
        myTableView.delegate = self
        
        // Viewに追加する.
        self.view.addSubview(myTableView)
        
        /*
        cancelButton = UIBarButtonItem(title: "キャンセル", style: .Plain, target: self, action: "cancelPush")
        self.navigationItem.leftBarButtonItem = cancelButton
        
        saveButton = UIBarButtonItem(title: "保存", style: .Plain, target: self, action: "savePush")
        
        self.navigationItem.rightBarButtonItem = saveButton
        */
        //self.navigationItem.tintColor = UIColor(red:119.0/255, green:185.0/255, blue:66.0/255, alpha:1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
    Cellが選択された際に呼び出されるデリゲートメソッド.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //println("Num: \(indexPath.row)")
        //println("Value: \(myItems[indexPath.row])")
        
        //if let myItem = myItems[indexPath.row] as? String {
        
        if (self.kind == "age"){
            
            let indexPath: String? = myItems[indexPath.row] as? String
            if indexPath != nil {
                self.selectedAge = indexPath!.uppercaseString
            }
            
        } else if (self.kind == "gender"){
            
            self.selectedGenderIndex = indexPath.row
            
            let indexPath: String? = myItems[indexPath.row] as? String
            if indexPath != nil {
                self.selectedGender = indexPath!.uppercaseString
            }
        }
    }
    
    /*
    Cellの総数を返すデータソースメソッド.
    (実装必須)
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItems.count
    }
    
    /*
    Cellに値を設定するデータソースメソッド.
    (実装必須)
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 再利用するCellを取得する.
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as! UITableViewCell
        
        // Cellに値を設定する.
        cell.textLabel!.text = "\(myItems[indexPath.row])"
        
        return cell
    }
    
    /*
    キャンセルボタン押下時
    */
    func cancelPush(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    保存ボタン押下時
    */
    func savePush(){
        
        if (self.kind == "age"){
            
            self.delegate!.getAge(self.selectedAge)
        }
        else if (self.kind == "gender"){
            
            self.delegate!.getGender(self.selectedGenderIndex,selected: self.selectedGender)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}