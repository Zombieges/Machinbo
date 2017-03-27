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
    // ネット接続確認
    func isInternetConnect() -> Bool
    // 広告表示
    func showAdmob(_ type: AdmobType)
    
    func errorAction()
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
            print("インターネット接続なし")
            UIAlertController.showAlertView("", message: "接続に失敗しました。通信状況を確認の上、再接続してくだささい。")
            return false
        }
        
        print("インターネット接続あり")
        return true
    }
    
    /**
     * 広告を表示
     */
    func showAdmob(_ type: AdmobType) {
        
        // AdMob Sample Start
        let AdMobUnitID = ConfigHelper.getPlistKey("ADMOB_UNIT_ID") as String
        
        if type == AdmobType.standard {
            let admobView = GADBannerView(adSize:kGADAdSizeBanner)
            admobView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.size.height - 50)
            admobView.frame.size = CGSize(width: UIScreen.main.bounds.size.width, height: admobView.frame.height)
            
            admobView.adUnitID = AdMobUnitID
            //admobView.delegate = self
            admobView.rootViewController = self
            
//            // Admob ヘリクエスト
//            let admobRequest:GADRequest = GADRequest()
//            
//            if AdMobTest {
//                // simulator テスト
//                if SimulatorTest {
//                    admobRequest.testDevices = [kGADSimulatorID]
//                    print("simulator")
//                }
//                    // 実機テスト
//                else {
//                    admobRequest.testDevices = [""]
//                    print("device")
//                }
//            }

            admobView.load(GADRequest())

            self.view.addSubview(admobView)
            
        } else if type == AdmobType.full {
            let interstitial = GADInterstitial(adUnitID: AdMobUnitID)
            interstitial.delegate = self
            
//            // Admob ヘリクエスト
//            let admobRequest:GADRequest = GADRequest()
//            
//            if AdMobTest {
//                // simulator テスト
//                if SimulatorTest {
//                    admobRequest.testDevices = [kGADSimulatorID]
//                    print("simulator")
//                }
//                    // 実機テスト
//                else {
//                    admobRequest.testDevices = [""]
//                    print("device")
//                }
//            }
            
            interstitial.load(GADRequest())
            
            if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
            }
        }


    }
    
    func showFullAdmob() -> GADInterstitial {
        let adMobID = ConfigHelper.getPlistKey("ADMOB_FULL_UNIT_ID") as String
        let interstitial = GADInterstitial(adUnitID: adMobID)
        interstitial.delegate = self
        let admobRequest:GADRequest = GADRequest()
        admobRequest.testDevices = [kGADSimulatorID]
        interstitial.load(admobRequest)
        
        return interstitial
    }
    
    func textColorForHeader() -> UIColor {
        return LayoutManager.getUIColorFromRGB(0x929292)
    }
    
    func backgroundColorForHeader() -> UIColor {
        return LayoutManager.getUIColorFromRGB(0xF6F2F3)
    }
    
    func errorAction() {
        MBProgressHUDHelper.sharedInstance.hide()
        UIAlertController.showAlertParseConnectionError()
    }
}
