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

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, GADBannerViewDelegate, GADInterstitialDelegate {
    
    var profileSettingButton: UIBarButtonItem!
    
    var lm : CLLocationManager!
    var longitude: CLLocationDegrees!
    var latitude: CLLocationDegrees!
    
    //開いた MarkWindow
    var markWindow : MarkWindow = MarkWindow()
    
    @IBOutlet weak var mapViewContainer: UIView!
    
    var mainNavigationCtrl: UINavigationController?
    
//    var gmaps : GMSMapView!
    
    override func viewDidLoad() {
        //super.viewDidLoad()
        
        if let view = UINib(nibName: "MapView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        if self.isInternetConnect() {
            let center = NSNotificationCenter.defaultCenter() as NSNotificationCenter
            
            LocationManager.sharedInstance.startUpdatingLocation()
            center.addObserver(self, selector: #selector(self.foundLocation(_:)), name: LMLocationUpdateNotification as String, object: nil)
        }
    }
    
    func foundLocation(notif: NSNotification) {
        
        defer {
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
        
        let info = notif.userInfo as NSDictionary!
        var location = info[LMLocationInfoKey] as! CLLocation
        
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        NSLog("位置情報取得成功！-> latiitude: \(latitude) , longitude: \(longitude)")
        
        //現在位置
        let myPosition = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let camera = GMSCameraPosition(target: myPosition, zoom: 13, bearing: 0, viewingAngle: 0)
        
        var gmaps = GMSMapView()
        gmaps.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        gmaps.myLocationEnabled = true
        gmaps.settings.myLocationButton = true
        gmaps.camera = camera
        gmaps.delegate = self
        gmaps.animateToLocation(myPosition)
        
        self.view.addSubview(gmaps)
        
        FeedData.mainData().refreshMapFeed(myPosition) { () -> () in
            defer {
                MBProgressHUDHelper.hide()
            }
            
            //ユーザマーカーを表示
            GoogleMapsHelper.setAnyUserMarker(gmaps, userObjects: FeedData.mainData().feedItems)
            //広告表示
            self.showAdmob(AdmobType.Full)
        }
        
        //manager.stopUpdatingLocation()
        //lm.stopUpdatingLocation()
//        if #available(iOS 9.0, *) {
//            lm.allowsBackgroundLocationUpdates = false
//        } else {
//            // Fallback on earlier versions
//        }
        
        //button 生成
        createNavigationItem()
        createupdateGeoPointButton()
    }
    
    func createupdateGeoPointButton() {
        //GeoPoint 更新ボタン
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xB54241)
        btn.setTitle("待ち合わせ場所登録", forState: .Normal)
        btn.addTarget(self, action: #selector(MapViewController.onClickImakoko), forControlEvents: UIControlEvents.TouchUpInside)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height - self.view.bounds.height/7.3)
        self.view.addSubview(btn)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
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
        
        /*else if status == .AuthorizedWhenInUse {
         manager.startUpdatingLocation()
         }*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createNavigationItem() {
        
        //◆プロフィール画面
        let profileViewButton: UIButton = UIButton(type: UIButtonType.Custom)
        profileViewButton.setImage(UIImage(named: "profile_icon.png"), forState: UIControlState.Normal)
        profileViewButton.titleLabel?.font = UIFont.systemFontOfSize(10)
        profileViewButton.setTitle("設定", forState: UIControlState.Normal)
        profileViewButton.addTarget(self, action: #selector(MapViewController.onClickProfileView), forControlEvents: UIControlEvents.TouchUpInside)
        profileViewButton.frame = CGRectMake(0, 0, 60, 53)
        profileViewButton.imageView?.contentMode = .ScaleAspectFit
        profileViewButton.imageEdgeInsets = UIEdgeInsetsMake(-25, 17, 0, 0)
        profileViewButton.titleEdgeInsets = UIEdgeInsetsMake(22, -22, 0, 0)
        
        //create a new button
        let imakokoViewButton: UIButton = UIButton(type: UIButtonType.Custom)
        imakokoViewButton.setImage(UIImage(named: "imakoko.png"), forState: UIControlState.Normal)
        imakokoViewButton.titleLabel?.font = UIFont.systemFontOfSize(10)
        imakokoViewButton.setTitle("いま来る", forState: .Normal)
        imakokoViewButton.addTarget(self, action: #selector(MapViewController.onClickGoNowListView), forControlEvents: UIControlEvents.TouchUpInside)
        imakokoViewButton.frame = CGRectMake(0, 0, 60, 53)
        imakokoViewButton.imageView?.contentMode = .ScaleAspectFit
        imakokoViewButton.imageEdgeInsets = UIEdgeInsetsMake(-25, 17, 0, 0)
        imakokoViewButton.titleEdgeInsets = UIEdgeInsetsMake(22, -22, 0, 0)
        
        self.navigationItem.rightBarButtonItems =
            [UIBarButtonItem(customView: profileViewButton), UIBarButtonItem(customView: imakokoViewButton)]
        
        //通知があったら表示
        //◆いま行く画面
        //いまいくボタンを押下したら表示するようにする？
        let imaikuViewButton: UIButton = UIButton(type: UIButtonType.Custom)
        imaikuViewButton.setImage(UIImage(named: "imaiku.png"), forState: UIControlState.Normal)
        imaikuViewButton.titleLabel?.font = UIFont.systemFontOfSize(10)
        imaikuViewButton.setTitle("いま行く", forState: UIControlState.Normal)
        imaikuViewButton.sizeToFit()
        imaikuViewButton.addTarget(self, action: #selector(MapViewController.onClickGoNowView), forControlEvents: UIControlEvents.TouchUpInside)
        imaikuViewButton.frame = CGRectMake(0, 0, 60, 53)
        imaikuViewButton.imageView?.contentMode = .ScaleAspectFit
        imaikuViewButton.imageEdgeInsets = UIEdgeInsetsMake(-25, 17, 0, 0)
        imaikuViewButton.titleEdgeInsets = UIEdgeInsetsMake(22, -22, 0, 0)
        
        self.navigationItem.rightBarButtonItems =
            [UIBarButtonItem(customView: profileViewButton), UIBarButtonItem(customView: imakokoViewButton), UIBarButtonItem(customView: imaikuViewButton)]
        
        //いま行くボタンと、いまココボタンは両立できないため、どちらかを表示する
        //いずれもParseに登録した値を引っ張ってくる必要がある
        
        //リロード
        let reloadButton: UIButton = UIButton(type: UIButtonType.Custom)
        reloadButton.setImage(UIImage(named: "reload.png"), forState: UIControlState.Normal)
        reloadButton.titleLabel?.font = UIFont.systemFontOfSize(10)
        reloadButton.setTitle("リロード", forState: UIControlState.Normal)
        reloadButton.addTarget(self, action: #selector(MapViewController.onClickReload), forControlEvents: UIControlEvents.TouchUpInside)
        reloadButton.frame = CGRectMake(0, 0, 60, 53)
        reloadButton.imageView?.contentMode = .ScaleAspectFit
        reloadButton.imageEdgeInsets = UIEdgeInsetsMake(-25, 17, 0, 0)
        reloadButton.titleEdgeInsets = UIEdgeInsetsMake(22, -22, 0, 0)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: reloadButton)
        
    }
    
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        //MarkDownWindow生成
        self.markWindow = NSBundle.mainBundle().loadNibNamed("MarkWindow", owner: self, options: nil).first! as! MarkWindow
        
        let createdBy: AnyObject? = marker.userData
        
        if let createdBy: AnyObject = createdBy {
            if let imageFile = createdBy.valueForKey("ProfilePicture") as? PFFile {
                let imageData: NSData = try! imageFile.getData()
                self.markWindow.ProfileImage.image = UIImage(data: imageData)!
                self.markWindow.ProfileImage.layer.borderColor = UIColor.whiteColor().CGColor
                self.markWindow.ProfileImage.layer.borderWidth = 3
                self.markWindow.ProfileImage.layer.cornerRadius = 10
                self.markWindow.ProfileImage.layer.masksToBounds = true
            }
            
            self.markWindow.Name.text = createdBy.objectForKey("Name") as? String
            self.markWindow.Name.sizeToFit()
            
            self.markWindow.Detail.text = marker.userData!.objectForKey("PlaceDetail") as? String
            self.markWindow.Detail.sizeToFit()
            
            self.markWindow.timeAgoText.text = marker.userData!.updatedAt!!.relativeDateString
            
        } else {
            onClickViewRefresh()
        }
        
        return self.markWindow
    }
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        
        let vc = TargetProfileViewController(type: ProfileType.TargetProfile)
        vc.userInfo = marker.userData!
        
        self.navigationController!.pushViewController(vc, animated: true)
        
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        return false
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        defer {
            manager.stopUpdatingLocation()
            self.createRefreshButton()
        }
        
        NSLog("位置情報取得失敗")
        UIAlertView.showAlertView("エラー", message:"位置情報の取得が失敗しました。アプリを再起動してください。")
    }
    
    func onClickProfileView() {
        let profileView = ProfileViewController()
        self.navigationController?.pushViewController(profileView, animated: true)
        
    }
    
    func onClickImakoko(){
        let vc = MarkerDraggableViewController()
        vc.palGeoPoint = PFGeoPoint(latitude: latitude, longitude: longitude)
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func onClickGoNowListView() {
        MBProgressHUDHelper.show("Loading...")
        
        ParseHelper.getGoNowMeList(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            
            defer {
                MBProgressHUDHelper.hide()
            }
            
            guard error == nil else {
                return
            }
            
            let vc = GoNowListViewController()
            vc.goNowList = result!
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func onClickGoNowView() {
        MBProgressHUDHelper.show("Loading...")
        
        ParseHelper.getMyGoNow(PersistentData.User().userID) { (error: NSError?, result) -> Void in
            
            defer {
                MBProgressHUDHelper.hide()
            }
            
            guard let goNowObj = result else {
                UIAlertView.showAlertDismiss("", message: "いまから行く人が登録されていません") { () -> () in }
                return
            }
            
            let targetUserInfo = goNowObj.objectForKey("TargetUser") as? PFObject
            
            guard targetUserInfo != nil else {
                
                targetUserInfo!.deleteInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in

                    guard success else {
                        print("削除エラー")
                        return
                    }

                    goNowObj.deleteInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                        defer {
                            MBProgressHUDHelper.hide()
                        }

                        guard success else {
                            print("削除エラー")
                            return
                        }
                        
                        PersistentData.deleteUserIDForKey("imaikuFlag")
                        UIAlertView.showAlertDismiss("", message: "いまから行く人のアカウントが削除されています") { () -> () in }
                    }
                }
                
                return
            }
            
            let vc = TargetProfileViewController(type: ProfileType.ImaikuTargetProfile)
            vc.targetObjectID = goNowObj.objectId!
            vc.userInfo = targetUserInfo!
            
            self.navigationController!.pushViewController(vc, animated: true)
            
            
            let userUpdateAt = targetUserInfo?.updatedAt
            let imakokoAt = goNowObj.objectForKey("imakokoAt") as? NSDate
            
            if userUpdateAt != imakokoAt {
                UIAlertView.showAlertDismiss("", message: "いまから行く人の位置情報が変更されています") { () -> () in }
            }
        }
    }
    
    //更新
    func onClickReload() {
        let center = NSNotificationCenter.defaultCenter() as NSNotificationCenter
        
        LocationManager.sharedInstance.startUpdatingLocation()
        center.addObserver(self, selector: #selector(MapViewController.foundLocation(_:)), name: LMLocationUpdateNotification as String, object: nil)
        
        //UIAlertView.showAlertDismiss("", message: "マップを更新しました") { () -> () in }
    }
    
}

