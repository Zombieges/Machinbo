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
    
    var profileSettingButton: UIBarButtonItem!
    let kAnimationController = PushAnimator()
    
    var lm : CLLocationManager!
    var longitude: CLLocationDegrees!
    var latitude: CLLocationDegrees!
    
    //開いた MarkWindow
    var markWindow : MarkWindow = MarkWindow()
    
    @IBOutlet weak var mapViewContainer: UIView!

    private var updateGeoPoint : ZFRippleButton!
    var mainNavigationCtrl: UINavigationController?
    
    
    
    @IBOutlet weak var gmsMapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = UINib(nibName: "MapView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
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
        updateGeoPoint = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        updateGeoPoint.trackTouchLocation = true
        updateGeoPoint.backgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        updateGeoPoint.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        updateGeoPoint.rippleColor = LayoutManager.getUIColorFromRGB(0xB54241)
        updateGeoPoint.setTitle("現在位置登録", forState: .Normal)
        updateGeoPoint.layer.cornerRadius = 5.0
        updateGeoPoint.layer.masksToBounds = true
        updateGeoPoint.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height - self.view.bounds.height/8.3)
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
        
        let gmaps: GMSMapView? = GMSMapView()
        if let map = gmaps {
            map.frame = CGRectMake(0, 20, self.view.frame.width, self.view.frame.height/2)
            map.myLocationEnabled = true
            map.settings.myLocationButton = true
            map.camera = camera
            map.delegate = self
            
            self.view = map
            
            //現在の自分の表示範囲から50kmの範囲、100件のデータを取得する
            ParseHelper.getNearUserInfomation(target) { (withError error: NSError?, result) -> Void in
                if error == nil {
                    GoogleMapsHelper.setUserMarker(map, userObjects: result!)
                    
                } else {
                    // Error Occured
                    println(error)
                }
            }
        }
        
        manager.stopUpdatingLocation()
        
        //button 生成
        createNavigationItem()
        createupdateGeoPointButton()
    }
    
    func createNavigationItem() {
        
        //◆プロフィール画面
        //create a new button
        let profileViewButton: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        //set image for button
        profileViewButton.setImage(UIImage(named: "profile_icon.png"), forState: UIControlState.Normal)
        //add function for button
        profileViewButton.addTarget(self, action: "onClickProfileSettingButton", forControlEvents: UIControlEvents.TouchUpInside)
        //set frame
        profileViewButton.frame = CGRectMake(0, 0, 53, 53)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileViewButton)
        
        
        //いま行くボタンと、いまココボタンは両立できないため、どちらかを表示する
        //いずれもParseに登録した値を引っ張ってくる必要がある
        
        
        //通知があったら表示
        
        //◆いま行く画面
        //いまいくボタンを押下したら表示するようにする？
        //create a new button
        let imaikuViewButton: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        //set image for button
        imaikuViewButton.setImage(UIImage(named: "imaiku.png"), forState: UIControlState.Normal)
        //add function for button
        imaikuViewButton.addTarget(self, action: "onClickGoNowView", forControlEvents: UIControlEvents.TouchUpInside)
        //set frame
        imaikuViewButton.frame = CGRectMake(0, 0, 53, 53)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: imaikuViewButton)
        
    }
    
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        
        //MarkDownWindow生成
        self.markWindow = NSBundle.mainBundle().loadNibNamed("MarkWindow", owner: self, options: nil).first! as! MarkWindow
        
        let createdBy: AnyObject? = marker.userData.objectForKey("CreatedBy")
        
        if let imageFile = createdBy!.valueForKey("ProfilePicture") as? PFFile {
            var imageData: NSData = imageFile.getData()!
            self.markWindow.ProfileImage.image = UIImage(data: imageData)!
            self.markWindow.ProfileImage.layer.borderColor = UIColor.whiteColor().CGColor
            self.markWindow.ProfileImage.layer.borderWidth = 3
            self.markWindow.ProfileImage.layer.cornerRadius = 10
            self.markWindow.ProfileImage.layer.masksToBounds = true
        }
        
        self.markWindow.Name.text = createdBy!.objectForKey("Name") as? String
        self.markWindow.Name.sizeToFit()
        
        self.markWindow.Detail.text = createdBy!.objectForKey("Comment") as? String
        self.markWindow.Detail.sizeToFit()
        
        return self.markWindow
    }
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        let vc = TargetProfileViewController()
        vc.userInfo = marker.userData.objectForKey("CreatedBy")!
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        return false
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        manager.stopUpdatingLocation()
        NSLog("位置情報取得失敗")
        
        UIAlertView.showAlertView("エラー", message:"位置情報の取得が失敗しました。アプリを再起動してください。")
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
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return kAnimationController
    }
    
    func onClickProfileSettingButton() {
        let profileView = ProfileViewController()
        self.navigationController?.pushViewController(profileView, animated: true)
        
    }
    
    func onClickGoNowView() {
        
        //TODO:ナベの端末ID取得UserID設定処理が感性したら再実装
        ParseHelper.getGoNowMe("demo7") { (withError error: NSError?, result) -> Void in
            if error == nil {
                let goNowMe: AnyObject? = result?.first
                let targetAction: AnyObject? = goNowMe!.objectForKey("TargetUser")
                let targetUser: AnyObject? = targetAction?.objectForKey("CreatedBy")
                
                NSLog(targetUser?.objectForKey("Name") as! String)
                
                let vc = TargetProfileViewController()
                vc.userInfo = targetUser!
                
                self.navigationController!.pushViewController(vc, animated: true)
                                
            } else {
                // Error Occured
                println(error)
            }
        }

    }
}

