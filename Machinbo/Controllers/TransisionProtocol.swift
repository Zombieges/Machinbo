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
