//
//  MapViewController.swift
//  Machinbo
//
//  Created by Zombieges on 2015/06/14.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import UIKit
import Parse

let _mainData: FeedData = FeedData()

class FeedData: NSObject {
    
    var feedItems: [PFObject] = []
    
    class func mainData() -> FeedData {
        
        return _mainData
    }
    
    func refreshMapFeed(myLocation: CLLocationCoordinate2D, completion: () -> ()) {

        ParseHelper.getNearUserInfomation(myLocation) { (error: NSError?, result) -> Void in
            if error == nil {
                
                self.feedItems = result!
                
            }
            
            completion()
        }
    }
    
}
