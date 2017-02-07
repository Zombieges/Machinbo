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

class NotificationHelper{

    class func launch() {
        //
        // SET UP AWS CONGNITO
        //
        let poolId = ConfigHelper.getPlistKey("AWS_CONGNITO_TEST") as String
        let awsCredentialsProvider = AWSCognitoCredentialsProvider(
            regionType: .apNortheast1,
            identityPoolId: poolId
        )
        
        let defaultAwsServiceConfiguration = AWSServiceConfiguration(region: .apNortheast1, credentialsProvider: awsCredentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = defaultAwsServiceConfiguration
    }
    
    class func sendSpecificDevice(_ message : String, deviceTokenAsString : String, badges : Int, type : String = "alert", sound : String = "default", ompletionHandler : ((NSError?) -> ())? = nil)
    {
        
        // 別スレッドにて実行
        let grobalQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
        grobalQueue.async(execute: {
            //
            // GET READY TO SEND TO SPECIFIC DEVICE
            //
            let sns = AWSSNS.default()
            let snsRequest = AWSSNSCreatePlatformEndpointInput()
            snsRequest?.token = deviceTokenAsString
            snsRequest?.platformApplicationArn = ConfigHelper.getPlistKey("AWS_SNS_TEST") as String
            
            //
            // SEND NOTIFICATION TO SPECIFIC DEVICE
            //
            sns.createPlatformEndpoint(snsRequest!) { (AwsSnsEndPoint:AWSSNSCreateEndpointResponse?, error:Error?) in
                guard error == nil else {
                    print("Failed to create SNS endpoint:\(error?.localizedDescription)")
                    return
                }
                
                if let endpointArn = AwsSnsEndPoint?.endpointArn {
                    print("created Endpoint is \(endpointArn)")
                    
                    let request = AWSSNSPublishInput()
                    request?.messageStructure = "json"
                    
                    let dict = ["APNS_SANDBOX": "{\"aps\":{\"\(type)\": \"\(message)\",\"sound\":\"\(sound)\", \"badge\":\(badges)} }"]
                    
                    do
                    {
                        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
                        request?.message = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as? String
                        request?.targetArn = "\(endpointArn)"
                        
                        // sending
                        sns.publish(request!).continue(successBlock: {
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
                        })
                    }
                    catch
                    {
                        print("Error on json serialization: \(error)")
                    }
                }
            }
        })
    }
}
