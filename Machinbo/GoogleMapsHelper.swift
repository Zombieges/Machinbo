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
import Parse

class GoogleMapsHelper {

    class func setUserMarker(map: GMSMapView, userObjects: [PFObject]) {
        for user in userObjects {
            let UserID = user.objectForKey("UserID") as! String

            let geoPoint : PFGeoPoint
            if let tempGeopoint = (user.objectForKey("GPS") as? PFGeoPoint) {
                geoPoint = tempGeopoint
            } else {
                geoPoint = PFGeoPoint(latitude: 0, longitude: 0)
            }

            let location = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)

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
            }
        }
    }
}
