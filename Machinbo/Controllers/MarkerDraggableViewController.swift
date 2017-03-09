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

class MarkerDraggableViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, GADBannerViewDelegate, GADInterstitialDelegate, UIGestureRecognizerDelegate, TransisionProtocol {
    
    var gmaps: GMSMapView!
    var palGeoPoint: PFGeoPoint!
    var palUserInfo: PFObject!
    var marker: GMSMarker!
    var pinImage: UIImageView!
    
    let displayWidth = UIScreen.main.bounds.size.width
    
    override func viewDidLoad() {
        
        if let view = UINib(nibName: "MapView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        //self.navigationItem.title = "ピンの場所を選択"
        
        if self.isInternetConnect() {
            LocationManager.sharedInstance.startUpdatingLocation()
            
            let center = NotificationCenter.default as NotificationCenter
            center.addObserver(self, selector: #selector(self.setGoogleMaps(_:)), name: NSNotification.Name(rawValue: LMLocationUpdateNotification as String as String), object: nil)
        }
    }
    
    func setGoogleMaps(_ notif: Notification)  {
        defer { NotificationCenter.default.removeObserver(self) }

        let info = notif.userInfo as NSDictionary!
        let location = info?[LMLocationInfoKey] as! CLLocation
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        //現在位置
        let myPosition = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let camera = GMSCameraPosition(target: myPosition, zoom: 13, bearing: 0, viewingAngle: 0)
        
        self.gmaps = GMSMapView()
        self.gmaps.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.gmaps.isMyLocationEnabled = true
        self.gmaps.settings.myLocationButton = true
        self.gmaps.camera = camera
        self.gmaps.delegate = self
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "geojson") {
                gmaps.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        self.gmaps.animate(toLocation: myPosition)
        
        self.view.addSubview(self.gmaps)
    }
    
    func getMapCenterPosition(_ gmaps: GMSMapView) -> CLLocationCoordinate2D {
        let visibleRegion = gmaps.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(region: visibleRegion)
        
        let center = CLLocationCoordinate2DMake(
            (bounds.southWest.latitude + bounds.northEast.latitude) / 2,
            (bounds.southWest.longitude + bounds.northEast.longitude) / 2)
        
        return center
    }
    
    func mapView(_ mapView: GMSMapView, didChange cameraPosition: GMSCameraPosition) {
        
        if self.pinImage == nil {
            
            self.pinImage = UIImageView(image: UIImage(named: "mappin@2x.png"))
            self.pinImage.isUserInteractionEnabled = true
            
//            let gesture = UITapGestureRecognizer(target:self, action: #selector(self.didClickImageView))
//            self.pinImage.addGestureRecognizer(gesture)
            
            self.view.addSubview(self.pinImage)
            self.createEntryThisPointButton()
        }

        var mapViewPosition = mapView.projection.point(for: getMapCenterPosition(mapView))
        mapViewPosition.y = mapViewPosition.y - self.pinImage.frame.height / 3
        self.pinImage.center = mapViewPosition
    }
    
    func didClickImageView(_ recognizer: UIGestureRecognizer) {

        let mapViewCenter = getMapCenterPosition(self.gmaps)
        
        let vc = GoNowViewController()
        vc.palGeoPoint = PFGeoPoint(latitude: mapViewCenter.latitude, longitude: mapViewCenter.longitude)
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    private func createEntryThisPointButton() {
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: displayWidth - 20, height: 50))
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0x0D47A1, alpha: 0.8)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0x0D47A1, alpha: 0.8)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0x1976D2)
        btn.setTitle("待ち合わせ場所決定", for: UIControlState())
        btn.addTarget(self, action: #selector(self.didClickImageView), for: UIControlEvents.touchUpInside)
        btn.layer.cornerRadius = 0
        btn.layer.masksToBounds = true
        btn.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height - self.view.bounds.height/7.3)
        self.view.addSubview(btn)
    }
}
