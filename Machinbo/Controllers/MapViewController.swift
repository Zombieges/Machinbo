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
        let location = info[LMLocationInfoKey] as! CLLocation
        
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        NSLog("位置情報取得成功！-> latiitude: \(latitude) , longitude: \(longitude)")
        
        //現在位置
        let myPosition = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let camera = GMSCameraPosition(target: myPosition, zoom: 13, bearing: 0, viewingAngle: 0)
        
        let gmaps = GMSMapView()
        gmaps.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        gmaps.myLocationEnabled = true
        gmaps.settings.myLocationButton = true
        gmaps.camera = camera
        gmaps.delegate = self
        gmaps.animateToLocation(myPosition)
        
        self.view.addSubview(gmaps)
        
        FeedData.mainData().refreshMapFeed(myPosition) { () -> () in
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
        profileViewButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        profileViewButton.setTitle("プロフィール", forState: .Normal)
        profileViewButton.addTarget(self, action: #selector(onClickProfileView), forControlEvents: UIControlEvents.TouchUpInside)
        profileViewButton.frame = CGRectMake(0, 0, 60, 53)
        profileViewButton.imageView?.contentMode = .ScaleAspectFit
        profileViewButton.imageEdgeInsets = UIEdgeInsetsMake(-23, 13, 0, 0)
        profileViewButton.titleEdgeInsets = UIEdgeInsetsMake(22, -22, 0, 0)
        
        //create a new button
        let imakokoViewButton: UIButton = UIButton(type: UIButtonType.Custom)
        imakokoViewButton.setImage(UIImage(named: "imakoko.png"), forState: UIControlState.Normal)
        imakokoViewButton.titleLabel?.font = UIFont.systemFontOfSize(10)
        imakokoViewButton.setTitle("待ち合わせ", forState: .Normal)
        imakokoViewButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        imakokoViewButton.addTarget(self, action: #selector(onClickGoNowListView), forControlEvents: UIControlEvents.TouchUpInside)
        imakokoViewButton.frame = CGRectMake(0, 0, 60, 53)
        imakokoViewButton.imageView?.contentMode = .ScaleAspectFit
        imakokoViewButton.imageEdgeInsets = UIEdgeInsetsMake(-23, 13, 0, 0)
        imakokoViewButton.titleEdgeInsets = UIEdgeInsetsMake(22, -22, 0, 0)
        
//        self.navigationItem.rightBarButtonItems =
//            [UIBarButtonItem(customView: profileViewButton), UIBarButtonItem(customView: imakokoViewButton)]
//        
        
        //検索ボタン
        let searchViewButton: UIButton = UIButton(type: UIButtonType.Custom)
        searchViewButton.setImage(UIImage(named: "search.png"), forState: UIControlState.Normal)
        searchViewButton.titleLabel?.font = UIFont.systemFontOfSize(10)
        searchViewButton.setTitle("検索", forState: UIControlState.Normal)
        searchViewButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        searchViewButton.sizeToFit()
        searchViewButton.addTarget(self, action: #selector(MapViewController.onClickSearch), forControlEvents: UIControlEvents.TouchUpInside)
        searchViewButton.frame = CGRectMake(0, 0, 60, 53)
        searchViewButton.imageView?.contentMode = .ScaleAspectFit
        searchViewButton.imageEdgeInsets = UIEdgeInsetsMake(-23, 13, 0, 0)
        searchViewButton.titleEdgeInsets = UIEdgeInsetsMake(22, -22, 0, 0)
        
//        self.navigationItem.rightBarButtonItems =
//            [UIBarButtonItem(customView: profileViewButton), UIBarButtonItem(customView: imakokoViewButton), UIBarButtonItem(customView: searchViewButton)]
//        
        //いま行くボタンと、いまココボタンは両立できないため、どちらかを表示する
        //いずれもParseに登録した値を引っ張ってくる必要がある
        
        //リロード
        let reloadButton: UIButton = UIButton(type: UIButtonType.Custom)
        reloadButton.setImage(UIImage(named: "reload.png"), forState: UIControlState.Normal)
        reloadButton.titleLabel?.font = UIFont.systemFontOfSize(10)
        reloadButton.setTitle("リロード", forState: UIControlState.Normal)
        reloadButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        reloadButton.addTarget(self, action: #selector(MapViewController.onClickReload), forControlEvents: UIControlEvents.TouchUpInside)
        reloadButton.frame = CGRectMake(0, 0, 60, 53)
        reloadButton.imageView?.contentMode = .ScaleAspectFit
        reloadButton.imageEdgeInsets = UIEdgeInsetsMake(-23, 13, 0, 0)
        reloadButton.titleEdgeInsets = UIEdgeInsetsMake(22, -22, 0, 0)
        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: reloadButton)
        
        
        let myToolbar = UIToolbar(frame: CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 60.0))
        myToolbar.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height-20.0)
        myToolbar.barStyle = .Default
        myToolbar.tintColor = UIColor.whiteColor()
        myToolbar.backgroundColor = UIColor.whiteColor()
        
        myToolbar.items = [UIBarButtonItem(customView: profileViewButton), UIBarButtonItem(customView: imakokoViewButton), UIBarButtonItem(customView: searchViewButton)]
        
        self.view.addSubview(myToolbar)
        
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
            self.refresh()
        }
        
        return self.markWindow
    }
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        
        let vc = TargetProfileViewController(type: ProfileType.TargetProfile)
        vc.userInfo = marker.userData!
        
        self.navigationController!.pushViewController(vc, animated: false)
        
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
        self.navigationController?.pushViewController(profileView, animated: false)
        
    }
    
    func onClickImakoko(){
        let vc = MarkerDraggableViewController()
        vc.palGeoPoint = PFGeoPoint(latitude: latitude, longitude: longitude)
        
        self.navigationController!.pushViewController(vc, animated: false)
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
            
            guard result!.count != 0 else {
                UIAlertView.showAlertView("", message: "いまから来る人が存在しません。相手から待ち合わせ希望があった場合、リストに表示されます。")
                
                return
            }
            
            let vc = GoNowListViewController()
            vc.goNowList = result!
            self.navigationController!.pushViewController(vc, animated: false)
            
        }
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
        let center = NSNotificationCenter.defaultCenter() as NSNotificationCenter
        
        LocationManager.sharedInstance.startUpdatingLocation()
        center.addObserver(self, selector: #selector(self.foundLocation), name: LMLocationUpdateNotification as String, object: nil)
    }
    
    func createRefreshButton() {
        //画面リフレッシュボタン
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xB54241)
        btn.setTitle("再表示", forState: .Normal)
        btn.addTarget(self, action: #selector(self.refresh), forControlEvents: .TouchUpInside)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height - self.view.bounds.height/8.3)
        self.view.addSubview(btn)
    }
    
    func refresh() {
        self.viewDidLoad()
    }
    
}

