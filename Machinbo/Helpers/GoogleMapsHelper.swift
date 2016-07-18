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

    class func setAnyUserMarker(map: GMSMapView, userObjects: [PFObject]) {
        
        for users in userObjects {
            setUserMarker(map, user: users, isSelect: false)
        }
    }
    
    class func setUserMarker(map: GMSMapView, user: PFObject, isSelect: Bool) {
        
        let geoPoint : PFGeoPoint
        if let tempGeopoint = (user.objectForKey("GPS") as? PFGeoPoint) {
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
    
    class func setDraggableUserMarker(map: GMSMapView, geoPoint: PFGeoPoint) {
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = map
        //marker.draggable = true
        marker.title = "aaa"
        
        let visibleRegion = map.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(region: visibleRegion)
        //let bounds = GMSCoordinateBounds(coordinate: visibleRegion.nearLeft, coordinate: visibleRegion.farRight)
        
        let latitudeDelta = bounds.northEast.latitude - bounds.southWest.latitude
        let longitudeDelta = bounds.northEast.longitude - bounds.southWest.longitude
        let center = CLLocationCoordinate2DMake(
            (bounds.southWest.latitude + bounds.northEast.latitude) / 2,
            (bounds.southWest.longitude + bounds.northEast.longitude) / 2)
        
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        let regionmake = MKCoordinateRegionMake(center, span)
        
        let position = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        let camera = GMSCameraPosition(target: center, zoom: 13, bearing: 0, viewingAngle: 0)
        
        map.camera = camera
        //map.cameraForBounds(bounds, insets: UIEdgeInsetsZero)
        map.selectedMarker = marker
    }
    
    class func setUserPin(map: GMSMapView, geoPoint: PFGeoPoint) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = map
        
        let position = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        let camera = GMSCameraPosition(target: position, zoom: 13, bearing: 0, viewingAngle: 0)
        
        map.camera = camera
    }
    
    func marker(annotation: MKAnnotation) -> GMSMarker {
        let marker = GMSMarker(position: annotation.coordinate)

        return marker
    }
}
