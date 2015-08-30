//
//  PickerViewController.swift
//  Machinbo
//
//  Created by Kazuhiro Watanabe on 2015/08/02.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import UIKit

class PickerViewController: UIViewController,
UINavigationBarDelegate,
UITableViewDelegate,
UITableViewDataSource {
    
    @IBOutlet weak var myNavigationBar: UINavigationBar!
    
    @IBOutlet weak var myNavigationItem: UINavigationItem!
    
    // Tableで使用する配列を設定する
    private var myTableView: UITableView!
    private var myItems: NSArray = []
    var palmItems:[String] = []
    var na: UIBarButtonItem!
    var window: UIWindow?
    
    var myNavigationController: UINavigationController?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // palmater set
        self.myItems = palmItems
        
        /*// ViewControllerを生成する.
        let myViewController: PickerViewController = self
        
        // Navication Controllerを生成する.
        let myNavigationController: UINavigationController = UINavigationController(rootViewController: myViewController)
        
        // UIWindowを生成する.
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        // rootViewControllerにNatigationControllerを設定する.
        self.window?.rootViewController = myNavigationController
        
        self.window?.makeKeyAndVisible()

        // UINavigationBar Setting
        self.navigationController?.navigationBar
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        */
        let navBarHeight = self.myNavigationBar.frame.size.height
        
        
        // Viewの高さと幅を取得する.
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        // TableViewの生成する.
        myTableView = UITableView(frame: CGRect(x: 0, y: navBarHeight, width: displayWidth, height: displayHeight - navBarHeight))
        
        // Cell名の登録をおこなう.
        myTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        myTableView.dataSource = self
        
        // Delegateを設定する.
        myTableView.delegate = self
        
        // Viewに追加する.
        self.view.addSubview(myTableView)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
    Cellが選択された際に呼び出されるデリゲートメソッド.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        println("Num: \(indexPath.row)")
        println("Value: \(myItems[indexPath.row])")
        
        
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
}
