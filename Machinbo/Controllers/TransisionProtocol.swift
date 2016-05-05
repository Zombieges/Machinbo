//
//  BaseViewController.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2016/05/05.
//  Copyright © 2016年 Zombieges. All rights reserved.
//

import UIKit
import Foundation
import GoogleMobileAds

protocol TransisionProtocol {
    func showAdmob()
}

extension TransisionProtocol where Self: UIViewController, Self: GADBannerViewDelegate {
    func showAdmob() {
        
        // AdMob Sample Start
        let AdMobID = ConfigHelper.getPlistKey("ADMOB_ID") as String    //ID をInfoPlist より取得
        //let TEST_DEVICE_ID = "61b0154xxxxxxxxxxxxxxxxxxxxxxxe0"
        let AdMobTest:Bool = true
        let SimulatorTest:Bool = true
        
        // Admob のビューを生成
        var admobView: GADBannerView = GADBannerView()
        admobView = GADBannerView(adSize:kGADAdSizeBanner)
        admobView.frame.origin = CGPointMake(0, self.view.frame.size.height - admobView.frame.height)
        
        admobView.frame.size = CGSizeMake(self.view.frame.width, admobView.frame.height)
        admobView.adUnitID = AdMobID
        admobView.delegate = self
        admobView.rootViewController = self
        
        // Admob ヘリクエスト
        let admobRequest:GADRequest = GADRequest()
        
        if AdMobTest {
            if SimulatorTest {
                admobRequest.testDevices = [kGADSimulatorID]
            }
            else {
                //admobRequest.testDevices = [TEST_DEVICE_ID]
            }
            
        }
        admobView.loadRequest(admobRequest)
        self.view.addSubview(admobView)
    }
    
    // 戻る画面遷移
    func pop() {
        navigationController?.popViewControllerAnimated(true)
        print("TransisionProtocol pop")
    }
}