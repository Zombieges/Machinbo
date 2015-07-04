//
//  FirstViewController.swift
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
    var lm: CLLocationManager! = nil
    var longitude: CLLocationDegrees!
    var latitude: CLLocationDegrees!
    
    // storyboardで関連づけるLabel
    //@IBOutlet var lonLabel: UILabel
    //@IBOutlet var latLabel: UILabel
    
    @IBOutlet var mapview : GMSMapView!
    //@IBOutlet var gadbnrview : GADBannerView
    
    // CLLocationManagerDelegateを継承すると、init()が必要になる
    required init(coder aDecoder: NSCoder) {
        lm = CLLocationManager()
        longitude = CLLocationDegrees()
        latitude = CLLocationDegrees()
        super.init(coder: aDecoder)
    }
    
    //画面表示後の処理
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //現在位置の取得
        lm = CLLocationManager()
        lm.delegate = self
        
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        
        // まだ認証が得られていない場合は、認証ダイアログを表示
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
        
        // Google Map の表示
        mapview = GMSMapView(frame: CGRectMake(
            0, 0, self.view.bounds.width, self.view.bounds.height))
        
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

    // ボタンイベントのセット.
    func onClickMyButton(sender: UIButton){
        // 現在位置の取得を開始.
        lm.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /** 位置情報取得成功時 */
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!){
        
        println("位置情報取得成功！")
        
        //現在位置を取得した後にGoogleMapに位置表示処理
        var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(
            latitude:newLocation.coordinate.latitude,longitude:newLocation.coordinate.longitude)
   
        longitude = newLocation.coordinate.longitude
        latitude = newLocation.coordinate.latitude
        
        var now: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(
            latitude,longitude:longitude,zoom:17)
        
        println(now)
        
        // MapViewを生成.
        mapview.camera = now
        
        
        mapview.myLocationEnabled = true
        mapview.delegate = self
        
        //self.lonLabel.text = String(longitude)
        //self.latLabel.text = String(latitude)
    }
    
    /** 位置情報取得失敗時 */
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error")
    }

}

