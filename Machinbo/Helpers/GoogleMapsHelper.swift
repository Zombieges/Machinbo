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
        
        MBProgressHUDHelper.show("Loading...")
        
        for users in userObjects {
            setUserMarker(map, user: users, isSelect: false)
        }
        
        MBProgressHUDHelper.hide()
    }
    
    class func setUserMarker(_ map: GMSMapView, user: PFObject, isSelect: Bool) {
        
        let geoPoint : PFGeoPoint
        if let tempGeopoint = (user.object(forKey: "GPS") as? PFGeoPoint) {
            geoPoint = tempGeopoint
            
        } else {
            geoPoint = PFGeoPoint(latitude: 0, longitude: 0)
        }
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)
        marker.appearAnimation = kGMSMarkerAnimationPop
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
        marker.position = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)
        marker.appearAnimation = kGMSMarkerAnimationPop
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
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)
//        marker.appearAnimation = kGMSMarkerAnimationPop
//        marker.map = map
//        
//        let position = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
//        let camera = GMSCameraPosition(target: position, zoom: 13, bearing: 0, viewingAngle: 0)
//        
//        map.camera = camera
        var meetingGeoPoint = PFGeoPoint(latitude: 0, longitude: 0)
        if let tempGeopoint = (gonowInfo.object(forKey: "meetingGeoPoint") as? PFGeoPoint) {
            meetingGeoPoint = tempGeopoint
        }
        let marker1 = GMSMarker()
        marker1.position = CLLocationCoordinate2DMake(meetingGeoPoint.latitude, meetingGeoPoint.longitude)
        marker1.appearAnimation = kGMSMarkerAnimationPop
        marker1.map = map
        marker1.title = "待ち合わせ場所"
        
        var userGeoPoint = PFGeoPoint(latitude: 0, longitude: 0)
        if let userGonow = (gonowInfo.object(forKey: "userGoNow") as? PFObject) {
            if let tempGeoPoint = (userGonow.object(forKey: "userGeoPoint") as? PFGeoPoint) {
                userGeoPoint = tempGeoPoint
            }
        }
        var userName = ""
        if let user = (gonowInfo.object(forKey: "User") as? PFObject) {
            if let tempName = (user.object(forKey: "Name") as? String) {
                userName = tempName
            }
        }
        let marker2 = GMSMarker()
        marker2.position = CLLocationCoordinate2DMake(userGeoPoint.latitude, userGeoPoint.longitude)
        marker2.appearAnimation = kGMSMarkerAnimationPop
        marker2.map = map
        marker2.title = userName
        
        var targetGeoPoint = PFGeoPoint(latitude: 0, longitude: 0)
        if let targetGonow = (gonowInfo.object(forKey: "targetGoNow") as? PFObject) {
            if let tempGeoPoint = (targetGonow.object(forKey: "userGeoPoint") as? PFGeoPoint) {
                targetGeoPoint = tempGeoPoint
            }
        }
        var targetUserName = ""
        if let targetUser = (gonowInfo.object(forKey: "TargetUser") as? PFObject) {
            if let tempName = (targetUser.object(forKey: "Name") as? String) {
                targetUserName = tempName
            }
        }
        let marker3 = GMSMarker()
        marker3.position = CLLocationCoordinate2DMake(targetGeoPoint.latitude, targetGeoPoint.longitude)
        marker3.appearAnimation = kGMSMarkerAnimationPop
        marker3.map = map
        marker3.title = targetUserName
        
        
        let visibleRegion = map.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(region: visibleRegion)
        let center = CLLocationCoordinate2DMake(
            (bounds.southWest.latitude + bounds.northEast.latitude) / 2,
            (bounds.southWest.longitude + bounds.northEast.longitude) / 2)
        let camera = GMSCameraPosition(target: center, zoom: 13, bearing: 0, viewingAngle: 0)
        
        map.camera = camera
        map.selectedMarker = marker1
        map.selectedMarker = marker2
        map.selectedMarker = marker3
    }
    
    func marker(_ annotation: MKAnnotation) -> GMSMarker {
        return GMSMarker(position: annotation.coordinate)
    }
}
