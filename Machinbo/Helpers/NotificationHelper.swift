//
//  NotificationHelper.swift
//  Machinbo
//
//  Created by Kazuhiro Watanabe on 2016/08/28.
//  Copyright © 2016年 Zombieges. All rights reserved.
//

import Foundation
import AWSSNS
import AWSCore
import AWSCognito

class NotificationHelper {

    class func launch() {
        //
        // SET UP AWS CONGNITO
        //
        let poolId = ConfigData(type: .awsCognito).getPlistKey
        let awsCredentialsProvider = AWSCognitoCredentialsProvider(
            regionType: .apNortheast1,
            identityPoolId: poolId
        )
        
        let defaultAwsServiceConfiguration = AWSServiceConfiguration(region: .apNortheast1, credentialsProvider: awsCredentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = defaultAwsServiceConfiguration
    }
    
    var message: String
    var deviceTokenAsString: String
    var badges: Int
    var type = "alert"
    var sound = "default"
    var endpoint: String = ""
    
    init(_ message : String, deviceTokenAsString : String, badges : Int, type : String = "alert", sound : String = "default") {
        self.message = message
        self.deviceTokenAsString = deviceTokenAsString
        self.badges = badges
        self.type = type
        self.sound = sound
    }
    
    func sendSpecificDevice(completionHandler : ((NSError?) -> ())? = nil) {
        let sns = AWSSNS.default()
        let request = AWSSNSGetEndpointAttributesInput()
        request?.endpointArn = PersistentData.AWSSNSEndpoint
        sns.getEndpointAttributes(request!).continue(with: AWSExecutor.default(), with: { (task) in
            if task.error != nil {
                print("Error: Endpoint attributes error. The device should create endpoint: \(task.error)");
                //Endpoint が存在しなかった場合、作成
                self.createEndpoint()
                return nil
            }
            
            guard let endpointAttributesResult = task.result else { return nil }
            let attributes: Dictionary<String, String>? = endpointAttributesResult.attributes
            
            //deviceToken が古いか、もしくは Enabled が false の場合は、再設定
            if !(attributes?["token"] == self.deviceTokenAsString) || !(attributes?["Enabled"] == "true") {
                //print("Error: Device token is old or not valid. The device should set latest information");
                self.setAttribute()
                self.push()
            }
            
            return nil
        })
    }
    
    fileprivate func createEndpoint() {
        let sns = AWSSNS.default()
        let input = AWSSNSCreatePlatformEndpointInput()
        input?.token = deviceTokenAsString
        input?.platformApplicationArn = ConfigData(type: .awsSNS).getPlistKey
        sns.createPlatformEndpoint(input!) { (AwsSnsEndPoint:AWSSNSCreateEndpointResponse?, error:Error?) in
            guard error == nil else {
                print("Failed to create SNS endpoint:\(error?.localizedDescription)")
                return
            }
            
            if let endpointArn = AwsSnsEndPoint?.endpointArn {
                print("created Endpoint is \(endpointArn)")
                PersistentData.AWSSNSEndpoint = endpointArn
                self.push()
            }
        }
    }
    
    fileprivate func setAttribute() {
        let sns = AWSSNS.default()
        let request = AWSSNSSetEndpointAttributesInput()
        request?.attributes = ["Token":  self.deviceTokenAsString, "Enabled": "true"]
        sns.setEndpointAttributes(request!)
    }
    
    fileprivate func push() {
        //let dict = ["APNS_SANDBOX": "{\"aps\":{\"\(self.type)\": \"\(self.message)\",\"sound\":\"\(self.sound)\", \"badge\":\(self.badges)} }"]
        let dict = ["APNS": "{\"aps\":{\"\(self.type)\": \"\(self.message)\",\"sound\":\"\(self.sound)\", \"badge\":\(self.badges)} }"]
        let sns = AWSSNS.default()
        let request = AWSSNSPublishInput()
        
        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: dict,
                options: JSONSerialization.WritingOptions.prettyPrinted
            )
            request?.messageStructure = "json"
            request?.message = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as? String
            
            print("PersistentData.AWSSNSEndpoint===>" + PersistentData.AWSSNSEndpoint)
            
            request?.targetArn = "\(PersistentData.AWSSNSEndpoint)"
            sns.publish(request!).continue(successBlock: { (task) -> AnyObject! in
                guard task.error == nil else { 
                    print("Error sending mesage: \(task.error)")
                    return nil
                }
                
                print("Success sending message") 
                return nil 
            })
            
        } catch { 
            print("Error on json serialization: \(error)") 
        } 
    }
    
//    func sendSpecificDevice(completionHandler : ((NSError?) -> ())? = nil) {
//        
//        if !self.deviceTokenAsString.isEmpty {
//        // 別スレッドにて実行
//            let grobalQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
//            grobalQueue.async(execute: {
//                //
//                // GET READY TO SEND TO SPECIFIC DEVICE
//                //
//                let sns = AWSSNS.default()
//                let snsRequest = AWSSNSCreatePlatformEndpointInput()
//                snsRequest?.token = self.deviceTokenAsString
//                snsRequest?.platformApplicationArn = ConfigData(type: .awsSNS).getPlistKey
//                
//                //
//                // SEND NOTIFICATION TO SPECIFIC DEVICE
//                //
//                sns.createPlatformEndpoint(snsRequest!) { (AwsSnsEndPoint:AWSSNSCreateEndpointResponse?, error:Error?) in
//                    guard error == nil else {
//                        print("Failed to create SNS endpoint:\(error?.localizedDescription)")
//                        return
//                    }
//                    
//                    if let endpointArn = AwsSnsEndPoint?.endpointArn {
//                        print("created Endpoint is \(endpointArn)")
// 
//                        let requestEndpoint = AWSSNSSetEndpointAttributesInput()
//                        requestEndpoint?.attributes = ["Token": endpointArn, "Enabled": "true"]
//                        sns.setEndpointAttributes(requestEndpoint!)
//                        
//                        let request = AWSSNSPublishInput()
//                        request?.messageStructure = "json"
//                        
//                        let dict = ["APNS_SANDBOX": "{\"aps\":{\"\(self.type)\": \"\(self.message)\",\"sound\":\"\(self.sound)\", \"badge\":\(self.badges)} }"]
//                        //let dict = ["APNS": "{\"aps\":{\"\(self.type)\": \"\(self.message)\",\"sound\":\"\(self.sound)\", \"badge\":\(self.badges)} }"]
//                        
//                        do
//                        {
//                            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
//                            request?.message = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as? String
//                            request?.targetArn = "\(endpointArn)"
//                            
//                            // sending
//                            sns.publish(request!).continue(successBlock: {
//                                (task) -> AnyObject! in
//                                if task.error != nil
//                                {
//                                    print("Error sending mesage: \(task.error)")
//                                }
//                                else
//                                {
//                                    print("Success sending message")
//                                }
//                                return nil
//                            })
//                        }
//                        catch
//                        {
//                            print("Error on json serialization: \(error)")
//                        }
//                    }
//                }
//            })
//        }
//    }
}
