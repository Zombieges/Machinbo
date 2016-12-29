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
import AWSSNS
import AWSCore
import AWSCognito

protocol TransisionProtocol {
    func isInternetConnect() -> Bool
    func createRefreshButton()
    func showAdmob(_ type: AdmobType)
}

enum AdmobType {
    case standard, full
}

extension TransisionProtocol where
    Self: UIViewController,
    Self: GADBannerViewDelegate,
    Self: GADInterstitialDelegate {
    
    /**
     * インターネット接続がされているかを確認する
     */
    func isInternetConnect() -> Bool {

        let reachability = try! AMReachability.reachabilityForInternetConnection()
        if !reachability.isReachable() {
            defer { createRefreshButton() }
            
            print("インターネット接続なし")
            UIAlertController.showAlertView("", message: "接続に失敗しました。通信状況を確認の上、再接続してくだささい。")
            
            return false
        }
        
        print("インターネット接続あり")
        return true
    }
    
    func createRefreshButton() {
        //画面リフレッシュボタン
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xB54241)
        btn.setTitle("Try now", for: UIControlState())
        //btn.addTarget(self, action: #selector(TransisionProtocol.onClickViewRefresh), forControlEvents: UIControlEvents.TouchUpInside)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height - self.view.bounds.height/8.3)
        self.view.addSubview(btn)
    }
    
    func onClickViewRefresh() {
        self.viewDidLoad()
    }
    
    /**
     * 広告を表示
     */
    func showAdmob(_ type: AdmobType) {
        
        // AdMob Sample Start
        let AdMobID = ConfigHelper.getPlistKey("ADMOB_ID") as String    //ID をInfoPlist より取得
        //let TEST_DEVICE_ID = "61b0154xxxxxxxxxxxxxxxxxxxxxxxe0"
        let AdMobTest:Bool = true
        let SimulatorTest:Bool = true
        
        // Admob のビューを生成
        //var admobView: GADBannerView = GADBannerView()
        
        if type == AdmobType.standard {
            let admobView = GADBannerView(adSize:kGADAdSizeBanner)
            admobView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.size.height - 50)
            admobView.frame.size = CGSize(width: UIScreen.main.bounds.size.width, height: admobView.frame.height)
            
            admobView.adUnitID = AdMobID
            admobView.delegate = self
            admobView.rootViewController = self
            
            // Admob ヘリクエスト
            let admobRequest:GADRequest = GADRequest()
            
            if AdMobTest {
                if SimulatorTest {
                    admobRequest.testDevices = [kGADSimulatorID]
                }
            }
            
            admobView.load(admobRequest)
            self.view.addSubview(admobView)
            
        } else if type == AdmobType.full {
            let interstitial = GADInterstitial(adUnitID: AdMobID)
            interstitial.delegate = self
            
            // Admob ヘリクエスト
            let admobRequest:GADRequest = GADRequest()
            
            if AdMobTest {
                if SimulatorTest {
                    admobRequest.testDevices = [kGADSimulatorID]
                }
            }
            
            interstitial.load(admobRequest)
            
            if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
            }
        }


    }
    
    func showFullAdmob() -> GADInterstitial {
        let adMobID = ConfigHelper.getPlistKey("ADMOB_ID") as String
        let interstitial = GADInterstitial(adUnitID: adMobID)
        interstitial.delegate = self
        
        //TODOTEST：Admob ヘリクエスト
        let admobRequest:GADRequest = GADRequest()
        admobRequest.testDevices = [kGADSimulatorID]
        
        interstitial.load(admobRequest)
        
        return interstitial
    }
    
}
