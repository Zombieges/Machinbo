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

class MarkerDraggableViewController: UIViewController, CLLocationManagerDelegate, GADBannerViewDelegate, GADInterstitialDelegate, UIGestureRecognizerDelegate, TransisionProtocol {
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    var gmaps: GMSMapView!
    @IBOutlet weak var gmapsView: UIView!
    
//    @IBOutlet weak var gmaps: GMSMapView!
    
    @IBOutlet weak var imakokoButton: ZFRippleButton!
    
    //var gmaps: GMSMapView!
    var palGeoPoint: PFGeoPoint!
    var palUserInfo: PFObject!
    var marker: GMSMarker!
    var pinImage: UIImageView!
    
    let displayWidth = UIScreen.main.bounds.size.width
    
    override func viewDidLoad() {
        if let view = UINib(nibName: "MarkerMapView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        navigationItem.backBarButtonItem = backButton
        navigationItem.title = "待ち合わせ場所を選択"
        
        imakokoButton.isHidden = true

        LocationManager.sharedInstance.startUpdatingLocation()
        
        let center = NotificationCenter.default as NotificationCenter
        center.addObserver(
            self,
            selector: #selector(self.setGoogleMaps(_:)),
            name: NSNotification.Name(rawValue: LMLocationUpdateNotification as String),
            object: nil)
    }
    
    func setGoogleMaps(_ notif: Notification)  {
        defer { NotificationCenter.default.removeObserver(self) }

        let info = notif.userInfo as NSDictionary!
        let location = info?[LMLocationInfoKey] as! CLLocation
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let myPosition = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        //地図作成
        gmaps = GoogleMapsHelper.gmsMapView(self, myPosition)
        self.gmapsView.addSubview(gmaps)
    }
    
    func getMapCenterPosition(_ gmaps: GMSMapView) -> CLLocationCoordinate2D {
        let visibleRegion = gmaps.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(region: visibleRegion)
        
        let center = CLLocationCoordinate2DMake(
            (bounds.southWest.latitude + bounds.northEast.latitude) / 2,
            (bounds.southWest.longitude + bounds.northEast.longitude) / 2)
        
        return center
    }
    
    @IBAction func createImakoko(_ sender: Any) {
        guard self.isInternetConnect() else {
            self.errorAction()
            return
        }
        
        let mapViewCenter = getMapCenterPosition(gmaps)
        
        let vc = GoNowViewController()
        vc.palGeoPoint = PFGeoPoint(latitude: mapViewCenter.latitude, longitude: mapViewCenter.longitude)
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
}


extension MarkerDraggableViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didChange cameraPosition: GMSCameraPosition) {
        
        if self.pinImage == nil {
            self.pinImage = UIImageView(image: UIImage(named: "mappin_blue_big"))
            self.pinImage.isUserInteractionEnabled = true
            
            self.view.addSubview(self.pinImage)
        }
        
        var mapViewPosition = mapView.projection.point(for: getMapCenterPosition(mapView))
        mapViewPosition.y = mapViewPosition.y - self.pinImage.frame.height / 3
        self.pinImage.center = mapViewPosition
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        imakokoButton.isHidden = true
    }
    
    func mapView(_ mapView:GMSMapView, idleAt position:GMSCameraPosition) {
        imakokoButton.isHidden = false
        
    }
    
}
