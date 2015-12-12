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
    func setGender(selectedIndex: Int,selected: String)
    func setAge(selectedIndex: Int,selected: String)
    func setName(name: String)
}


class PickerViewController: UIViewController,
    UITableViewDelegate,
    UITableViewDataSource{
    
    var delegate: PickerViewControllerDelegate?
    //var saveButton: UIBarButtonItem!
    
    let saveButton = UIButton()
    
    var selectedAgeIndex: Int = 0
    var selectedAge:String = ""
    var selectedGenderIndex: Int = 0
    var selectedGender: String = ""
    var myTextField = UITextField()
    
    // Tableで使用する配列を設定する
    private var myTableView: UITableView!
    private var myItems: NSArray = []
    private var kind: String = ""
    private var Input: AnyObject = ""
    var palmItems:[String] = []
    var palKind: String = ""
    var palInput: AnyObject = ""
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
        self.Input = palInput
        
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        
        
        // Viewの高さと幅を取得する.
        let displayWidth: CGFloat = UIScreen.mainScreen().bounds.size.width
        let displayHeight: CGFloat = UIScreen.mainScreen().bounds.size.height
        
        if (self.kind == "gender" || self.kind == "age") {
            // TableViewの生成す
            myTableView = UITableView(frame: CGRect(x: 0, y: navBarHeight!, width: displayWidth, height: displayHeight - navBarHeight!))
        
            // Cell名の登録をおこなう.
            myTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
            // DataSourceの設定をする.
            myTableView.dataSource = self
        
            // Delegateを設定する.
            myTableView.delegate = self
        
            // Viewに追加する.
            self.view.addSubview(myTableView)
            
        } else if (self.kind == "name"){
            
            myTextField.frame = CGRectMake(10, 100, displayWidth - 20 , 30)
            myTextField.borderStyle = UITextBorderStyle.RoundedRect
            myTextField.text = self.Input as? String
            
            self.view.addSubview(myTextField)
            
            createButton(displayWidth)
        }
        
    }
    
    private func createButton(displayWidth: CGFloat){
        saveButton.setTitle("保存", forState: .Normal)
        
        //テキストの色
        saveButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        
        //タップした状態のテキスト
        //saveButton.setTitle("Tapped!", forState: .Highlighted)
        
        //タップした状態の色
        saveButton.setTitleColor(UIColor.redColor(), forState: .Highlighted)
        
        //サイズ
        saveButton.frame = CGRectMake(0, 0, displayWidth - 150, 30)
        
        //タグ番号
        saveButton.tag = 1
        
        //配置場所
        saveButton.layer.position = CGPoint(x: displayWidth/2, y:180)
        
        //背景色
        saveButton.backgroundColor = UIColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 0.2)
        
        //角丸
        saveButton.layer.cornerRadius = 10
        
        //ボーダー幅
        //saveButton.layer.borderWidth = 1
        
        //ボタンをタップした時に実行するメソッドを指定
        saveButton.addTarget(self, action: "onClickSaveButton:", forControlEvents:.TouchUpInside)
        
        //viewにボタンを追加する
        self.view.addSubview(saveButton)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    internal func onClickSaveButton(sender: UIButton){
        
        self.delegate!.setName(self.myTextField.text)
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    /*
    Cellが選択された際に呼び出されるデリゲートメソッド.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (self.kind == "age"){
            
            self.selectedAgeIndex = indexPath.row
            
            let indexPath: String? = myItems[indexPath.row] as? String
            if indexPath != nil {
                
                self.selectedAge = indexPath!.uppercaseString
                self.delegate!.setAge(self.selectedAgeIndex,selected: self.selectedAge)
                self.navigationController!.popViewControllerAnimated(true)

            }
            
        } else if (self.kind == "gender"){
            
            self.selectedGenderIndex = indexPath.row
            
            let indexPath: String? = myItems[indexPath.row] as? String
            if indexPath != nil {
                
                self.selectedGender = indexPath!.uppercaseString
                self.delegate!.setGender(self.selectedGenderIndex,selected: self.selectedGender)
                self.navigationController!.popViewControllerAnimated(true)
            }
        }
    }
    
    /*
    Cellの総数を返すデータソースメソッド.
    (実装必須)
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myItems.count
    }
    
    /*
    Cellに値を設定するデータソースメソッド.
    (実装必須)
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 再利用するCellを取得する.
        //let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as! UITableViewCell
        
        let identifier = "Cell" // セルのIDを定数identifierにする。
        var cell: UITableViewCell? // nilになることがあるので、Optionalで宣言
        
        cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? UITableViewCell
        if cell == nil { // 再利用するセルがなかったら（不足していたら）
            // セルを新規に作成する。
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identifier)
        }
        
        
        if indexPath.section == 0 {
            
            cell?.accessoryType = .None
            
            if indexPath.row == (self.palInput as? Int) {
                cell?.accessoryType = .Checkmark
            }
            
            
            cell?.textLabel!.text = "\(self.myItems[indexPath.row])"
            
            // Cellに値を設定する.
            //cell.textLabel!.text = "\(myItems[indexPath.row])"
        }
        
        return cell!
    }
}