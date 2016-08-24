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
    func showAdmob(type: AdmobType)
}

enum AdmobType {
    case standard, Full
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
            UIAlertView.showAlertView("", message: "接続に失敗しました。通信状況を確認の上、再接続してくだささい。")
            
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
        btn.setTitle("Try now", forState: .Normal)
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
    func showAdmob(type: AdmobType) {
        
        // AdMob Sample Start
        let AdMobID = ConfigHelper.getPlistKey("ADMOB_ID") as String    //ID をInfoPlist より取得
        //let TEST_DEVICE_ID = "61b0154xxxxxxxxxxxxxxxxxxxxxxxe0"
        let AdMobTest:Bool = true
        let SimulatorTest:Bool = true
        
        // Admob のビューを生成
        //var admobView: GADBannerView = GADBannerView()
        
        if type == AdmobType.standard {
            let admobView = GADBannerView(adSize:kGADAdSizeBanner)
            admobView.frame.origin = CGPointMake(0, UIScreen.mainScreen().bounds.size.height - 50)
            admobView.frame.size = CGSizeMake(UIScreen.mainScreen().bounds.size.width, admobView.frame.height)
            
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
            
            admobView.loadRequest(admobRequest)
            self.view.addSubview(admobView)
            
        } else if type == AdmobType.Full {
            let interstitial = GADInterstitial(adUnitID: AdMobID)
            interstitial.delegate = self
            
            // Admob ヘリクエスト
            let admobRequest:GADRequest = GADRequest()
            
            if AdMobTest {
                if SimulatorTest {
                    admobRequest.testDevices = [kGADSimulatorID]
                }
            }
            
            interstitial.loadRequest(admobRequest)
            
            if interstitial.isReady {
                interstitial.presentFromRootViewController(self)
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
        
        interstitial.loadRequest(admobRequest)
        
        return interstitial
    }
    
    //　to do nabe 共通化
    //  Send Notification
    //
    func sendNotification(message : String, deviceTokenAsString : String,
                          type : String = "alert", sound : String = "default", badges : Int = 1,
                          ompletionHandler : ((NSError?) -> ())? = nil)
    {
        
        // 別スレッドにて実行
        let grobalQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
        dispatch_async(grobalQueue, {
            
            //
            // SET UP AWS CONGNITO
            //
            let poolId = ConfigHelper.getPlistKey("AWS_CONGNITO_TEST") as String
            let awsCredentialsProvider = AWSCognitoCredentialsProvider(
                regionType: .APNortheast1,
                identityPoolId: poolId
            )
            
            let defaultAwsServiceConfiguration = AWSServiceConfiguration(region: .APNortheast1, credentialsProvider: awsCredentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultAwsServiceConfiguration
            
            //
            // AWS SNS
            //
            let sns = AWSSNS.defaultSNS()
            let snsRequest = AWSSNSCreatePlatformEndpointInput()
            snsRequest.token = deviceTokenAsString
            snsRequest.platformApplicationArn = ConfigHelper.getPlistKey("AWS_SNS_TEST") as String
            
            
            //
            // SEND NOTIFICATION TO PARTICULAR PARSON
            //
            sns.createPlatformEndpoint(snsRequest) { (AwsSnsEndPoint:AWSSNSCreateEndpointResponse?, error:NSError?) in
                if error != nil {
                    print("Failed to create SNS endpoint:\(error?.description)")
                } else {
                    if let endpointArn = AwsSnsEndPoint?.endpointArn {
                        print("created Endpoint is \(endpointArn)")
                        
                        
                        let request = AWSSNSPublishInput()
                        request.messageStructure = "json"
                        
                        
                        //let dict = ["default": message, "APNS_SANDBOX": "{\"aps\":{\"\(type)\": \"\(message)\", \"badge\":\"\(badges)\"},\"sound\":\"\(sound)\" }"]
                        //let dict = [ "APNS_SANDBOX": "{\"aps\":{\"\(type)\": \"\(message)\", \"badge\":\"\(badges)\"},\"sound\":\"\(sound),\"content-available\":1\" }"]
                        
                        let dict = [ "APNS_SANDBOX": "{\"aps\":{\"\(type)\": \"\(message)\", \"badge\":\"\(badges)\"},\"sound\":\"\(sound)\" }"]
                        
                        do
                        {
                            let jsonData = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)
                            request.message = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as? String
                            request.targetArn = "\(endpointArn)"
                            
                            // sending
                            sns.publish(request).continueWithBlock
                                {
                                    (task) -> AnyObject! in
                                    if task.error != nil
                                    {
                                        print("Error sending mesage: \(task.error)")
                                    }
                                    else
                                    {
                                        print("Success sending message")
                                    }
                                    return nil
                            }
                        }
                        catch
                        {
                            print("Error on json serialization: \(error)")
                        }
                    }
                }
            }
        })
    }

    
}