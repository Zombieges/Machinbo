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

let NavigationBarHeight = 44, StatusBarHeight = 20, SearchBarHeight = 44

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    var gmaps: GMSMapView?
    var markers : [GMSMarker] = []
    
    //現在地の位置情報取得
    let locationManager = CLLocationManager()
    // 取得した緯度を保持
    var longitude: CLLocationDegrees!
    // 取得した軽度を保持
    var latitude: CLLocationDegrees!
    
    @IBOutlet weak var mapViewContainer: UIView!
    
    @IBOutlet weak var GPSUpdateContainer: UIButton!
    
    var geoPoint = PFGeoPoint()
    var feedItems: [PFObject] = []
    
    // CLLocationManagerDelegateを継承すると、init()が必要になる
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        longitude = CLLocationDegrees()
        latitude = CLLocationDegrees()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapViewContainer.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        /*
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.NotDetermined {
        println("didChangeAuthorizationStatus:\(status)");
        // まだ承認が得られていない場合は、認証ダイアログを表示
        self.locationManager.requestAlwaysAuthorization()
        }
        */
        
        locationManager.delegate = self
        // 取得精度の設定
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 取得頻度の設定
        locationManager.distanceFilter = 100
        
        locationManager.requestWhenInUseAuthorization()
        
        // 現在位置の取得
        locationManager.startUpdatingLocation()
        
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
        
        // 取得した緯度・経度をLogに表示
        NSLog("位置情報取得成功！-> latiitude: \(latitude) , longitude: \(longitude)")
        
        var target = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        var camera = GMSCameraPosition(
            target: target,
            zoom: 15,
            bearing: 0,
            viewingAngle: 0
        )
        
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
            
            //
            var userinfo = ParseHelper.getUserInfo()
            GoogleMapsHelper.setUserMarker(map, userObjects: userinfo)
        }

        
        //消しちゃダメ！
        /*
        var current_location = locations[0] as? CLLocation
        if let current_cordinate = (current_location!.coordinate) as CLLocationCoordinate2D?{
        self.updateGoogleMapView(current_cordinate)
        }
        */
        
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
    
    private func reloadMarkers(){
        
        //DBから再度マーカーを取得する
        
        //地図が表示外になった場合、マーカーを非表示にする
        for marker in self.markers {
            if self.gmaps!.projection.containsCoordinate(marker.position) == false {
                marker.map = nil
                NSLog("マーカー非表示")
                
            } else {
                marker.map = self.gmaps
                NSLog("マーカー表示")
                
            }
        }
        
        markers = []
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        return false
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        manager.stopUpdatingLocation()
        NSLog("位置情報取得失敗")
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        self.reloadMarkers()
    }
    
    @IBAction func updateGPS(sender: AnyObject) {
        var geoPoint = PFGeoPoint(latitude: latitude, longitude: longitude);
        
        let gpsMark = PFObject(className: "UserInfo")
        gpsMark["GPS"] = geoPoint
        gpsMark["MarkTime"] = NSDate()
        gpsMark.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            NSLog("GPS情報登録成功")
        }
        
    }
}

