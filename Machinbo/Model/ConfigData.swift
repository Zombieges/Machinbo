//
//  ConfigData.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2017/03/28.
//  Copyright © 2017年 Zombieges. All rights reserved.
//

import Foundation

enum ConfigType: String {
    case adMobApp = "ADMOB_APP_ID"
    case adMobUnit = "ADMOB_UNIT_ID"
    case adMobFull = "ADMOB_FULL_UNIT_ID"
    case awsCognito = "AWS_CONGNITO_TEST"
    case awsSNS = "AWS_SNS_TEST"
    case googleMap = "GOOGLE_MAPS_API_KEY"
    case mail = "MACHINBO_MAIL"
    case parseApp = "PARSE_APP_ID_KEY"
    case parseClient = "PARSE_CLIENT_KEY"
    case parseURL = "PARSE_URL"
    case twitter = "TWITTER_LINK"
}

struct ConfigData {
    
    let type: ConfigType
    
    init(type: ConfigType) {
        self.type = type
    }
    
    var getPlistKey: String {
        var dict: NSDictionary?
        var result = ""
        
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            dict = NSDictionary(contentsOfFile: path)
        }
        
        if let value: AnyObject = dict?.value(forKey: self.type.rawValue) as AnyObject?{
            result = value as! String
        }
        
        return result
    }
}
