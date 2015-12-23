//
//  GoogleMapsHelper.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2015/08/02.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import Parse
import GoogleMaps

class GoogleMapsHelper {

    class func setUserMarker(map: GMSMapView, userObjects: [AnyObject]) {
        
        for users in userObjects {
            //let UserID = user.objectForKey("UserID") as! String

            let geoPoint : PFGeoPoint
            if let tempGeopoint = (users.objectForKey("GPS") as? PFGeoPoint) {
                geoPoint = tempGeopoint
                
            } else {
                geoPoint = PFGeoPoint(latitude: 0, longitude: 0)
            }

            var marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.map = map
            marker.userData = users
            
            //NSLog("UserID================>" + UserID)
            
            //↓表示したMAP内のみでピンを立てるロジック
            /*
            if map.projection.containsCoordinate(location) {
                var marker = GMSMarker()
                marker.position = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)
                marker.appearAnimation = kGMSMarkerAnimationPop
                marker.map = map
                marker.userData = user
                
                //markers.append(marker)

                NSLog("UserID================>" + UserID)

            } else {
                NSLog("★★★" + UserID)
                continue
            }*/
        }
    }
}
