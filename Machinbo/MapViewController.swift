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

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    var gmaps : GMSMapView!
    
    //現在地の位置情報取得
    var lm: CLLocationManager!
    // 取得した緯度を保持
    var longitude: CLLocationDegrees!
    // 取得した軽度を保持
    var latitude: CLLocationDegrees!
    
    @IBOutlet var mapview : GMSMapView!
    
    // CLLocationManagerDelegateを継承すると、init()が必要になる
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        lm = CLLocationManager()
        longitude = CLLocationDegrees()
        latitude = CLLocationDegrees()
    }
    
    //画面表示後の処理
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lm.delegate = self
        
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.NotDetermined {
            println("didChangeAuthorizationStatus:\(status)");
            // まだ承認が得られていない場合は、認証ダイアログを表示
            self.lm.requestAlwaysAuthorization()
        }
        
        // 取得精度の設定
        lm.desiredAccuracy = kCLLocationAccuracyBest
        // 取得頻度の設定
        lm.distanceFilter = 100
        // 現在位置の取得
        lm.startUpdatingLocation()
        
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        println("didChangeAuthorizationStatus");
        
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
        println(" CLAuthorizationStatus: \(statusStr)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /** 位置情報取得成功時 */
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!){
        
        println("位置情報取得成功！")
        
        // 取得した緯度がnewLocation.coordinate.longitudeに格納されている
        latitude = newLocation.coordinate.latitude
        // 取得した経度がnewLocation.coordinate.longitudeに格納されている
        longitude = newLocation.coordinate.longitude
        
        //現在位置を取得した後にGoogleMapに位置表示処理
        var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:latitude,longitude:longitude)
        
        var now = GMSCameraPosition.cameraWithLatitude(latitude,longitude:longitude,zoom:17)
        //var now = GMSCameraPosition.cameraWithLatitude(-33.868,longitude:151.2086, zoom:6)
        
        // 取得した緯度・経度をLogに表示
        NSLog("latiitude: \(latitude) , longitude: \(longitude)")
        
        
        // Google Map の表示
        mapview = GMSMapView.mapWithFrame(CGRectZero, camera:now)
        
        mapview.myLocationEnabled = true
        mapview.delegate = self
        mapview.camera = now
        
        mapview = GMSMapView.mapWithFrame(CGRectZero, camera:now)
        
        var marker = GMSMarker()
        marker.position = now.target
        marker.snippet = "Hello World"
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = mapview
        
    }
    
    /** 位置情報取得失敗時 */
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("位置情報取得失敗")
    }

}

