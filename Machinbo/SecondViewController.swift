//
//  SecondViewController.swift
//  Machinbo
//
//  Created by 渡辺和宏 on 2015/06/14.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO:test alert.
        var alert = UIAlertView()
        alert.title = "title"
        alert.message = "message"
        alert.addButtonWithTitle("OK")
        alert.show()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

