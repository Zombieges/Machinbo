//
//  MarkerDraggableViewController.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2016/07/02.
//  Copyright © 2016年 Zombieges. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Parse
import MBProgressHUD
import GoogleMobileAds

extension MarkerDraggableViewController: TransisionProtocol {}

//enum MySelector {
//    case MapPinTapped
//    
//    func selector() -> Selector {
//        switch self {
//        case .MapPinTapped:
//            return #selector(MarkerDraggableViewController.mapPinTapped(_:))
//        }
//    }
//}

class MarkerDraggableViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, GADBannerViewDelegate, GADInterstitialDelegate,
    UIGestureRecognizerDelegate {
    
    var gmaps: GMSMapView!
    var palGeoPoint: PFGeoPoint!
    var palUserInfo: PFObject!
    var marker: GMSMarker!
    var pinImage: UIImageView!
    
    override func viewDidLoad() {
        
        if let view = UINib(nibName: "MapView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.navigationItem.title = "ピンをタップして位置を送信"
        
        if self.isInternetConnect() {
            setGoogleMaps()
        }
    }
    
    func setGoogleMaps() {
        //現在位置
        let myPosition = CLLocationCoordinate2D(latitude: self.palGeoPoint.latitude, longitude: self.palGeoPoint.longitude)
        let camera = GMSCameraPosition(target: myPosition, zoom: 13, bearing: 0, viewingAngle: 0)
        
        self.gmaps = GMSMapView()
        self.gmaps.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        self.gmaps.myLocationEnabled = true
        self.gmaps.settings.myLocationButton = true
        self.gmaps.camera = camera
        self.gmaps.delegate = self
        self.gmaps.animateToLocation(myPosition)
        
        self.view.addSubview(self.gmaps)
    }
    
    func getMapCenterPosition(gmaps: GMSMapView) -> CLLocationCoordinate2D {
        let visibleRegion = gmaps.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(region: visibleRegion)
        
        let center = CLLocationCoordinate2DMake(
            (bounds.southWest.latitude + bounds.northEast.latitude) / 2,
            (bounds.southWest.longitude + bounds.northEast.longitude) / 2)
        
        return center
    }
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition cameraPosition: GMSCameraPosition) {
        
        if self.pinImage == nil {
            
            self.pinImage = UIImageView(image: UIImage(named: "mappin.png"))
            self.pinImage.userInteractionEnabled = true
            
            let gesture = UITapGestureRecognizer(target:self, action: #selector(self.didClickImageView))
            self.pinImage.addGestureRecognizer(gesture)
            
            self.view.addSubview(self.pinImage)
        }

        var mapViewPosition = mapView.projection.pointForCoordinate(getMapCenterPosition(mapView))
        mapViewPosition.y = mapViewPosition.y - self.pinImage.frame.height / 2
        self.pinImage.center = mapViewPosition
    }
    
    func didClickImageView(recognizer: UIGestureRecognizer) {

        let mapViewCenter = getMapCenterPosition(self.gmaps)
        
        let vc = GoNowViewController()
        vc.palGeoPoint = PFGeoPoint(latitude: mapViewCenter.latitude, longitude: mapViewCenter.longitude)
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
}