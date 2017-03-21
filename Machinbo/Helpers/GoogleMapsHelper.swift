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
import MapKit

class GoogleMapsHelper {
    
    class func setAnyUserMarker(_ map: GMSMapView, userObjects: [PFObject]) {
        
        //MBProgressHUDHelper.show("Loading...")
        
        for users in userObjects {
            setUserMarker(map, user: users, isSelect: false)
        }
        
        //MBProgressHUDHelper.hide()
    }
    
    class func setUserMarker(_ map: GMSMapView, user: PFObject, isSelect: Bool) {
        
        var geoPoint = PFGeoPoint(latitude: 0, longitude: 0)
        if let tempGeopoint = (user.object(forKey: "GPS") as? PFGeoPoint) {
            geoPoint = tempGeopoint
        }
        
        let marker = GMSMarker()
        marker.icon = UIImage(named: "mappin_red@2x.png")
        marker.position = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)
        marker.appearAnimation = .pop
        marker.map = map
        marker.userData = user
        
        if isSelect {
            let position = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
            let camera = GMSCameraPosition(target: position, zoom: 13, bearing: 0, viewingAngle: 0)
            map.camera = camera
        }
    }
    
    class func setDraggableUserMarker(_ map: GMSMapView, geoPoint: PFGeoPoint) {
        let marker = GMSMarker()
        marker.icon = UIImage(named: "mappin_red@2x.png")
        marker.position = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)
        marker.appearAnimation = .pop
        marker.map = map
        marker.title = "aaa"
        
        let visibleRegion = map.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(region: visibleRegion)
        let center = CLLocationCoordinate2DMake(
            (bounds.southWest.latitude + bounds.northEast.latitude) / 2,
            (bounds.southWest.longitude + bounds.northEast.longitude) / 2)
        let camera = GMSCameraPosition(target: center, zoom: 13, bearing: 0, viewingAngle: 0)
        
        map.camera = camera
        map.selectedMarker = marker
    }
    
    class func setUserPin(_ map: GMSMapView, gonowInfo: PFObject) {
        var meetingGeoPoint = PFGeoPoint(latitude: 0, longitude: 0)
        if let tempGeopoint = gonowInfo.object(forKey: "meetingGeoPoint") as? PFGeoPoint {
            meetingGeoPoint = tempGeopoint
            
            let position = CLLocationCoordinate2DMake(meetingGeoPoint.latitude, meetingGeoPoint.longitude)
            let marker1 = GMSMarker(position: position)
            marker1.icon = UIImage(named: "mappin_green@2x.png")
            marker1.appearAnimation = .pop
            marker1.map = map
            marker1.title = "待ち合わせ場所"
            
            map.selectedMarker = marker1
            let camera = GMSCameraPosition(target: position, zoom: 9, bearing: 0, viewingAngle: 0)
            map.camera = camera
        }
        
        var userGeoPoint = PFGeoPoint(latitude: 0, longitude: 0)
        if let userGonow = gonowInfo.object(forKey: "userGoNow") as? PFObject {
            if let tempGeoPoint = userGonow.object(forKey: "userGeoPoint") as? PFGeoPoint {
                userGeoPoint = tempGeoPoint
                let position = CLLocationCoordinate2DMake(userGeoPoint.latitude, userGeoPoint.longitude)
                let marker2 = GMSMarker(position: position)
                marker2.icon = UIImage(named: "mappin_red@2x.png")
                marker2.appearAnimation = .pop
                marker2.map = map
                
                if let user = gonowInfo.object(forKey: "User") as? PFObject {
                    if let tempName = user.object(forKey: "Name") as? String {
                        marker2.title = tempName
                    }
                }
            }
        }

        var targetGeoPoint = PFGeoPoint(latitude: 0, longitude: 0)
        if let targetGonow = gonowInfo.object(forKey: "targetGoNow") as? PFObject {
            if let tempGeoPoint = targetGonow.object(forKey: "userGeoPoint") as? PFGeoPoint {
                targetGeoPoint = tempGeoPoint
                let position = CLLocationCoordinate2DMake(targetGeoPoint.latitude, targetGeoPoint.longitude)
                let marker3 = GMSMarker(position: position)
                marker3.icon = UIImage(named: "mappin_blue@2x.png")
                marker3.appearAnimation = .pop
                marker3.map = map
                
                if let targetUser = gonowInfo.object(forKey: "TargetUser") as? PFObject {
                    if let tempName = targetUser.object(forKey: "Name") as? String {
                        marker3.title = tempName
                    }
                }
            }
        }
        
//        let visibleRegion = map.projection.visibleRegion()
//        let bounds = GMSCoordinateBounds(region: visibleRegion)
//        let center = CLLocationCoordinate2DMake(
//            (bounds.southWest.latitude + bounds.northEast.latitude) / 2,
//            (bounds.southWest.longitude + bounds.northEast.longitude) / 2)
//        let camera = GMSCameraPosition(target: center, zoom: 13, bearing: 0, viewingAngle: 0)
//        
//        map.camera = camera
    }
    
    func marker(_ annotation: MKAnnotation) -> GMSMarker {
        return GMSMarker(position: annotation.coordinate)
    }
}
