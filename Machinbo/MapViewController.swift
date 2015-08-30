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
    
    var lm : CLLocationManager!
    var longitude: CLLocationDegrees!
    var latitude: CLLocationDegrees!
    
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var GPSUpdateContainer: UIButton!
    
    
    //private var tabBarController: UITabBarController!
    private var updateGeoPoint : ZFRippleButton!
    
    // CLLocationManagerDelegateを継承すると、init()が必要になる
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        longitude = CLLocationDegrees()
        latitude = CLLocationDegrees()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
    func createupdateGeoPointButton() {
        //GeoPoint 更新ボタンの生成
        updateGeoPoint = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        updateGeoPoint.trackTouchLocation = true
        updateGeoPoint.backgroundColor = LayoutManager.getUIColorFromRGB(0x2196F3)
        updateGeoPoint.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0x2196F3)
        updateGeoPoint.rippleColor = LayoutManager.getUIColorFromRGB(0x1565C0)
        updateGeoPoint.setTitle("Update GPS!!", forState: .Normal)
        updateGeoPoint.layer.cornerRadius = 5.0
        updateGeoPoint.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height - self.view.bounds.height/8.3)
        updateGeoPoint.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(updateGeoPoint)
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
            
            //現在の自分の表示範囲から50kmの範囲、100件のデータを取得する
            var userinfo = ParseHelper.getNearUserInfomation(target)
            GoogleMapsHelper.setUserMarker(map, userObjects: userinfo)
        }
        
        manager.stopUpdatingLocation()
        
        //GeoPoint更新ボタンの生成
        self.createupdateGeoPointButton()
    }
    
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        //MarkDownWindow生成
        var markWindow = NSBundle.mainBundle().loadNibNamed("MarkWindow", owner: self, options: nil).first! as! MarkWindow
        markWindow.Name.text = marker.userData.objectForKey("Name") as? String
        markWindow.Detail.text = marker.userData.objectForKey("Comment") as? String
        //markWindow.ProfileImage =
        markWindow.ProfileImage.transform = CGAffineTransformMakeRotation(-08);
        //infoWindow.label.text = "\(marker.position.latitude) \(marker.position.longitude)"
        markWindow.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        return markWindow
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        return false
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        manager.stopUpdatingLocation()
        NSLog("位置情報取得失敗")
    }
    
    @IBAction func updateGPS(sender: AnyObject) {
        /*var geoPoint = PFGeoPoint(latitude: latitude, longitude: longitude);
        
        let gpsMark = PFObject(className: "UserInfo")
        gpsMark["GPS"] = geoPoint
        gpsMark["MarkTime"] = NSDate()
        gpsMark.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            NSLog("GPS情報登録成功")
        }
*/
        
    }
    
    func onClickMyButton(sender: UIButton){
        var geoPoint = PFGeoPoint(latitude: latitude, longitude: longitude);
        
        //USER情報にUPDATEをかける
        let gpsMark = PFObject(className: "UserInfo")
        gpsMark["GPS"] = geoPoint
        gpsMark["MarkTime"] = NSDate()
        gpsMark.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            NSLog("GPS情報登録成功")
        }
    }
}

