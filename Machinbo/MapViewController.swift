//
//  MapViewController.swift
//  Machinbo
//
//  Created by Zombieges on 2015/06/14.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Parse

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    var gmaps: GMSMapView?
    var markers : [GMSMarker] = []
    
    var lm : CLLocationManager!
    var longitude: CLLocationDegrees!
    var latitude: CLLocationDegrees!
    
    @IBOutlet weak var mapViewContainer: UIView!
    
    private var updateGeoPoint : ZFRippleButton!
    
    // CLLocationManagerDelegateを継承すると、init()が必要になる
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        longitude = CLLocationDegrees()
        latitude = CLLocationDegrees()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //updateGeoPoint = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        //self.view.addSubview(updateGeoPoint)
        
        
        lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyBest
        lm.distanceFilter = 100
        
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.NotDetermined {
            // まだ承認が得られていない場合は、認証ダイアログを表示
            self.lm.requestWhenInUseAuthorization()
        }
        
        lm.startUpdatingLocation()
        
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        NSLog("didChangeAuthorizationStatus");
        
        // 認証のステータスをログで表示.
        var statusStr = "";
        switch (status) {
        case .NotDetermined:
            statusStr = "NotDetermined"
        case .Restricted:
            statusStr = "Restricted"
        case .Denied:
            statusStr = "Denied"
        case .AuthorizedAlways:
            statusStr = "AuthorizedAlways"
        case .AuthorizedWhenInUse:
            statusStr = "AuthorizedWhenInUse"
        }
        NSLog(" CLAuthorizationStatus: \(statusStr)")
        
        if status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        latitude = locations.first!.coordinate.latitude
        longitude = locations.first!.coordinate.longitude
        
        NSLog("位置情報取得成功！-> latiitude: \(latitude) , longitude: \(longitude)")
        
        var target = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        var camera = GMSCameraPosition(target: target, zoom: 13, bearing: 0, viewingAngle: 0)
        
        gmaps = GMSMapView()
        if let map = gmaps {
            map.frame = CGRectMake(0, 20, self.view.frame.width, self.view.frame.height/2)
            map.myLocationEnabled = true
            map.settings.myLocationButton = true
            map.camera = camera
            map.delegate = self
            
            self.mapViewContainer.addSubview(map)
            self.mapViewContainer.hidden = false
            
            
            //ここで画像と名前、簡易自己紹介、何分前にイマココを押下したかをGPSMarkerで表示
            /*var myMarker = GMSMarker()
            myMarker.position = target
            myMarker.appearAnimation = kGMSMarkerAnimationPop
            myMarker.map = map*/
            //自分のマーカーは非表示でよしとする
            //self.markers = []
            //self.markers.append(myMarker)
            
            //現在の自分の表示範囲から50kmの範囲、100件のデータを取得する
            var userinfo = ParseHelper.getNearUserInfomation(target)
            GoogleMapsHelper.setUserMarker(map, userObjects: userinfo)
        }
        
        manager.stopUpdatingLocation()
    }
    
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        //MarkDownWindow生成
        var markWindow = NSBundle.mainBundle().loadNibNamed("MarkWindow", owner: self, options: nil).first! as! MarkWindow
        markWindow.Name.text = marker.userData.objectForKey("Name") as? String
        markWindow.Detail.text = marker.userData.objectForKey("Comment") as? String
        //markWindow.ProfileImage =
        markWindow.ProfileImage.transform = CGAffineTransformMakeRotation(-08);
        //infoWindow.label.text = "\(marker.position.latitude) \(marker.position.longitude)"
        return markWindow
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        return false
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        manager.stopUpdatingLocation()
        NSLog("位置情報取得失敗")
    }
    
    /*@IBAction func updateGPS(sender: AnyObject) {
        var geoPoint = PFGeoPoint(latitude: latitude, longitude: longitude);
        
        let gpsMark = PFObject(className: "UserInfo")
        gpsMark["GPS"] = geoPoint
        gpsMark["MarkTime"] = NSDate()
        gpsMark.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            NSLog("GPS情報登録成功")
        }
        
    }*/
}

