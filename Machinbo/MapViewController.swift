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
    
    //現在地の位置情報取得
    let locationManager = CLLocationManager()
    // 取得した緯度を保持
    var longitude: CLLocationDegrees!
    // 取得した軽度を保持
    var latitude: CLLocationDegrees!
    
    @IBOutlet weak var mapViewContainer: UIView!
    
    @IBOutlet weak var GPSUpdateContainer: UIButton!
    
    var geoPoint = PFGeoPoint()
    
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
        var target: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.6, longitude: 17.2)
        var camera: GMSCameraPosition = GMSCameraPosition(target: target, zoom: 6, bearing: 0, viewingAngle: 0)
        var container:CGRect?=CGRectMake(0, CGFloat(NavigationBarHeight+SearchBarHeight), self.view.bounds.width, self.view.bounds.height-super.tabBarController!.tabBar.bounds.height-CGFloat(NavigationBarHeight+SearchBarHeight))
        
        container = self.mapViewContainer.bounds
        
        gmaps = GMSMapView.mapWithFrame(container!, camera: camera)
        
        if let map = gmaps {
        map.myLocationEnabled = true
        map.camera = camera
        map.delegate = self
        
        self.mapViewContainer.addSubview(map)
        self.mapViewContainer.hidden=false
        }
        */
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        NSLog("位置情報取得成功！")
        
        // 取得した緯度がnewLocation.coordinate.longitudeに格納されている
        latitude = locations[0].coordinate.latitude
        // 取得した経度がnewLocation.coordinate.longitudeに格納されている
        longitude = locations[0].coordinate.longitude
        
        // 取得した緯度・経度をLogに表示
        NSLog("位置情報取得成功！-> latiitude: \(latitude) , longitude: \(longitude)")
        
        
        var target = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
        var camera = GMSCameraPosition(
            target: target,
            zoom: 13,
            bearing: 0,
            viewingAngle: 0
        )
        
        var container:CGRect?=CGRectMake(
            0,
            CGFloat(NavigationBarHeight+SearchBarHeight),
            self.view.bounds.width,
            self.view.bounds.height
            //self.view.bounds.height-super.tabBarController!.tabBar.bounds.height-CGFloat(NavigationBarHeight+SearchBarHeight)
        )
        
        container = self.mapViewContainer.bounds
        
        gmaps = GMSMapView.mapWithFrame(container!, camera: camera)
        
        if let map = gmaps {
            map.myLocationEnabled = true
            map.camera = camera
            map.delegate = self
            
            var marker1 = GMSMarker()
            marker1.position = target
            marker1.snippet = "Test Marker"
            marker1.appearAnimation = kGMSMarkerAnimationPop
            marker1.map = map
            
            self.mapViewContainer.addSubview(map)
            self.mapViewContainer.hidden=false
        }
        
        
        //消しちゃダメ！
        /*
        var current_location = locations[0] as? CLLocation
        if let current_cordinate = (current_location!.coordinate) as CLLocationCoordinate2D?{
        self.updateGoogleMapView(current_cordinate)
        }
        */
        
        locationManager.stopUpdatingLocation()
        
    }
    
    func updateGoogleMapView(target: CLLocationCoordinate2D!)->Bool{
        if let camera: GMSCameraPosition = GMSCameraPosition(target: target, zoom: 13, bearing: 0, viewingAngle: 0) as GMSCameraPosition?{
            self.gmaps?.clear()
            self.gmaps?.moveCamera(GMSCameraUpdate.setCamera(camera))
            if let marker = GMSMarker() as GMSMarker?{
                marker.position=target
                
                marker.title = "test marker"
                marker.snippet = "Hello World"
                
                marker.appearAnimation=kGMSMarkerAnimationPop
                marker.map = self.gmaps
            }
            
            return true
            
        }else{
            return false
        }
        
        
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        self.performSegueWithIdentifier("ToMarkerDetailSegue", sender: marker)
        return true
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("位置情報取得失敗")
    }
    
    @IBAction func updateGPS(sender: AnyObject) {
        
        // GeoPointの生成
        var geoPoint = PFGeoPoint(latitude: longitude, longitude: latitude);
        
        let gpsMark = PFObject(className: "UserInfo")
        gpsMark["GPS"] = geoPoint
        gpsMark["MarkTime"] = NSDate()
        gpsMark.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            NSLog("GPS情報登録成功")
        }
        
    }
}

