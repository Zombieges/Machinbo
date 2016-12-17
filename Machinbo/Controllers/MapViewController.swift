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
import MBProgressHUD
import GoogleMobileAds

extension MapViewController: TransisionProtocol {}

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, GADBannerViewDelegate, GADInterstitialDelegate, UITabBarDelegate {
    
    var profileSettingButton: UIBarButtonItem!
    
    var lm : CLLocationManager!
    var longitude: CLLocationDegrees!
    var latitude: CLLocationDegrees!
    
    //開いた MarkWindow
    var markWindow : MarkWindow = MarkWindow()
    
    @IBOutlet weak var mapViewContainer: UIView!
    
    var mainNavigationCtrl: UINavigationController?
    
    override func loadView() {
        if let view = UINib(nibName: "MapView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.navigationItem.title = "ホーム"
        self.navigationController!.navigationBar.tintColor = UIColor.darkGray
        
        //button 生成
        createNavigationItem()
    }
    
    override func viewDidLoad() {
        if self.isInternetConnect() {
            let center = NotificationCenter.default as NotificationCenter
            
            LocationManager.sharedInstance.startUpdatingLocation()
            center.addObserver(self, selector: #selector(self.foundLocation(_:)), name: NSNotification.Name(rawValue: LMLocationUpdateNotification as String as String), object: nil)
        }
    }
    
    func foundLocation(_ notif: Notification) {
        
        defer {
            NotificationCenter.default.removeObserver(self)
        }
        
        let info = notif.userInfo as NSDictionary!
        let location = info?[LMLocationInfoKey] as! CLLocation
        
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        NSLog("位置情報取得成功！-> latiitude: \(latitude) , longitude: \(longitude)")
        
        //現在位置
        let myPosition = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let camera = GMSCameraPosition(target: myPosition, zoom: 13, bearing: 0, viewingAngle: 0)
        
        let gmaps = GMSMapView()
        gmaps.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        gmaps.isMyLocationEnabled = true
        gmaps.settings.myLocationButton = true
        gmaps.camera = camera
        gmaps.delegate = self
        gmaps.animate(toLocation: myPosition)
        
        self.view.addSubview(gmaps)
        
        FeedData.mainData().refreshMapFeed(myPosition) { () -> () in
            //ユーザマーカーを表示
            GoogleMapsHelper.setAnyUserMarker(gmaps, userObjects: FeedData.mainData().feedItems)
            //広告表示
            self.showAdmob(AdmobType.full)
        }
        
        //manager.stopUpdatingLocation()
        //lm.stopUpdatingLocation()
        //        if #available(iOS 9.0, *) {
        //            lm.allowsBackgroundLocationUpdates = false
        //        } else {
        //            // Fallback on earlier versions
        //        }
        
        createupdateGeoPointButton()
    }
    
    func createupdateGeoPointButton() {
        //GeoPoint 更新ボタン
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xB54241)
        btn.setTitle("待ち合わせ場所登録", for: UIControlState())
        btn.addTarget(self, action: #selector(MapViewController.onClickImakoko), for: UIControlEvents.touchUpInside)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height - self.view.bounds.height/7.3)
        self.view.addSubview(btn)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        NSLog("didChangeAuthorizationStatus");
        
        // 認証のステータスをログで表示.
        var statusStr = "";
        switch (status) {
        case .notDetermined:
            statusStr = "NotDetermined"
        case .restricted:
            statusStr = "Restricted"
        case .denied:
            statusStr = "Denied"
        case .authorizedAlways:
            statusStr = "AuthorizedAlways"
        case .authorizedWhenInUse:
            statusStr = "AuthorizedWhenInUse"
        }
        
        NSLog(" CLAuthorizationStatus: \(statusStr)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createNavigationItem() {
        let reloadButton = UIButton(type: UIButtonType.custom)
        reloadButton.setImage(UIImage(named: "reload.png"), for: UIControlState())
        reloadButton.setTitleColor(UIColor.darkGray, for: UIControlState())
        reloadButton.addTarget(self, action: #selector(onClickReload), for: UIControlEvents.touchUpInside)
        reloadButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        reloadButton.imageView?.contentMode = .scaleAspectFit
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: reloadButton)
        
        let seachButton = UIButton(type: UIButtonType.custom)
        seachButton.setImage(UIImage(named: "search.png"), for: UIControlState())
        seachButton.setTitleColor(UIColor.darkGray, for: UIControlState())
        seachButton.addTarget(self, action: #selector(onClickSearch), for: UIControlEvents.touchUpInside)
        seachButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        seachButton.imageView?.contentMode = .scaleAspectFit
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: seachButton)
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        self.markWindow = Bundle.main.loadNibNamed("MarkWindow", owner: self, options: nil)?.first! as! MarkWindow
        
        let createdBy: AnyObject? = marker.userData as AnyObject?
        
        if let createdBy: AnyObject = createdBy {
            if let imageFile = createdBy.value(forKey: "ProfilePicture") as? PFFile {
                let imageData: Data = try! imageFile.getData()
                self.markWindow.ProfileImage.image = UIImage(data: imageData)!
                self.markWindow.ProfileImage.layer.borderColor = UIColor.white.cgColor
                self.markWindow.ProfileImage.layer.borderWidth = 3
                self.markWindow.ProfileImage.layer.cornerRadius = 10
                self.markWindow.ProfileImage.layer.masksToBounds = true
            }
            
            self.markWindow.Name.text = createdBy.object(forKey: "Name") as? String
            self.markWindow.Name.sizeToFit()
            
            self.markWindow.Detail.text = (marker.userData! as AnyObject).object(forKey: "PlaceDetail") as? String
            self.markWindow.Detail.sizeToFit()
            
            self.markWindow.timeAgoText.text = (marker.userData! as AnyObject).updatedAt!!.relativeDateString
            
        } else {
            self.refresh()
        }
        
        return self.markWindow
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let vc = TargetProfileViewController(type: ProfileType.targetProfile)
        vc.userInfo = marker.userData! as AnyObject
        
        self.navigationController!.pushViewController(vc, animated: false)
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        defer {
            manager.stopUpdatingLocation()
            self.createRefreshButton()
        }
        
        NSLog("位置情報取得失敗")
        UIAlertView.showAlertView("エラー", message:"位置情報の取得が失敗しました。アプリを再起動してください。")
    }
    
    func onClickImakoko(){
        let vc = MarkerDraggableViewController()
        vc.palGeoPoint = PFGeoPoint(latitude: latitude, longitude: longitude)
        
        self.navigationController!.pushViewController(vc, animated: false)
    }

    func onClickSearch() {
        let vc = PickerViewController()
        vc.palKind = "search"
        self.navigationController!.pushViewController(vc, animated: false)
    }
    
//    
//    func onClickGoNowView() {
//        MBProgressHUDHelper.show("Loading...")
//        
//        ParseHelper.getMyGoNow(PersistentData.User().targetUserID) { (error: NSError?, result) -> Void in
//            
//            defer {
//                MBProgressHUDHelper.hide()
//            }
//            
//            guard let goNowObj = result else {
//                UIAlertView.showAlertDismiss("", message: "いまから行く人が登録されていません") { () -> () in }
//                return
//            }
//            
//            let targetUserInfo = goNowObj.objectForKey("TargetUser") as? PFObject
//            
//            guard targetUserInfo != nil else {
//                
//                targetUserInfo!.deleteInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//                    
//                    guard success else {
//                        print("削除エラー")
//                        return
//                    }
//                    
//                    goNowObj.deleteInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//                        defer {
//                            MBProgressHUDHelper.hide()
//                        }
//                        
//                        guard success else {
//                            print("削除エラー")
//                            return
//                        }
//                        
//                        PersistentData.deleteUserIDForKey("imaikuFlag")
//                        UIAlertView.showAlertDismiss("", message: "いまから行く人のアカウントが削除されています") { () -> () in }
//                    }
//                }
//                
//                return
//            }
//            
//            let vc = TargetProfileViewController(type: ProfileType.ImaikuTargetProfile)
//            vc.targetObjectID = goNowObj.objectId!
//            vc.userInfo = targetUserInfo!
//            
//            self.navigationController!.pushViewController(vc, animated: true)
//            
//            
//            let userUpdateAt = targetUserInfo?.updatedAt
//            let imakokoAt = goNowObj.objectForKey("imakokoAt") as? NSDate
//            
//            if userUpdateAt != imakokoAt {
//                UIAlertView.showAlertDismiss("", message: "いまから行く人の位置情報が変更されています") { () -> () in }
//            }
//        }
//    }
    
    //更新
    func onClickReload() {
        let center = NotificationCenter.default as NotificationCenter
        LocationManager.sharedInstance.startUpdatingLocation()
        center.addObserver(self, selector: #selector(self.foundLocation), name: NSNotification.Name(rawValue: LMLocationUpdateNotification as String as String), object: nil)
    }
    
    func createRefreshButton() {
        //画面リフレッシュボタン
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xB54241)
        btn.setTitle("再表示", for: UIControlState())
        btn.addTarget(self, action: #selector(self.refresh), for: .touchUpInside)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height - self.view.bounds.height/8.3)
        self.view.addSubview(btn)
    }
    
    func refresh() {
        self.viewDidLoad()
    }
    
    func onClickSeachView() {
        let vc = SettingsViewController()
        self.navigationController!.pushViewController(vc, animated: true)
    }
}

