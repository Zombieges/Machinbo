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
            regionType: .APNortheast1,
            identityPoolId: poolId
        )
        
        let defaultAwsServiceConfiguration = AWSServiceConfiguration(region: .APNortheast1, credentialsProvider: awsCredentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultAwsServiceConfiguration
    }
    
    class func sendSpecificDevice(message : String, deviceTokenAsString : String, badges : Int,
                              type : String = "alert", sound : String = "default",
                              ompletionHandler : ((NSError?) -> ())? = nil)
    {
        
        // 別スレッドにて実行
        let grobalQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
        dispatch_async(grobalQueue, {
            
            
            //
            // GET READY TO SEND TO SPECIFIC DEVICE
            //
            let sns = AWSSNS.defaultSNS()
            let snsRequest = AWSSNSCreatePlatformEndpointInput()
            snsRequest.token = deviceTokenAsString
            snsRequest.platformApplicationArn = ConfigHelper.getPlistKey("AWS_SNS_TEST") as String
            
            
            //
            // SEND NOTIFICATION TO SPECIFIC DEVICE
            //
            sns.createPlatformEndpoint(snsRequest) { (AwsSnsEndPoint:AWSSNSCreateEndpointResponse?, error:NSError?) in
                if error != nil {
                    print("Failed to create SNS endpoint:\(error?.description)")
                } else {
                    if let endpointArn = AwsSnsEndPoint?.endpointArn {
                        print("created Endpoint is \(endpointArn)")
                        
                        
                        let request = AWSSNSPublishInput()
                        request.messageStructure = "json"
                        
                        
                        let dict = ["APNS_SANDBOX": "{\"aps\":{\"\(type)\": \"\(message)\",\"sound\":\"\(sound)\", \"badge\":\(badges)} }"]
                        
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