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

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    var profileSettingButton: UIBarButtonItem!
    let kAnimationController = PushAnimator()
    
    var myPosition: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    var lm : CLLocationManager!
    var longitude: CLLocationDegrees!
    var latitude: CLLocationDegrees!
    
    //開いた MarkWindow
    var markWindow : MarkWindow = MarkWindow()
    
    @IBOutlet weak var mapViewContainer: UIView!

    var mainNavigationCtrl: UINavigationController?
    
    var gmaps : GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = UINib(nibName: "MapView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.NotDetermined {
            // まだ承認が得られていない場合は、認証ダイアログを表示
            self.lm.requestWhenInUseAuthorization()
        }
        
        let reachability = AMReachability.reachabilityForInternetConnection()
        if reachability.isReachable() {
            println("インターネット接続あり")
            
            lm = CLLocationManager()
            lm.delegate = self
            lm.desiredAccuracy = kCLLocationAccuracyBest
            lm.distanceFilter = 100
            
            lm.startUpdatingLocation()
            
        } else {
            println("インターネット接続なし")
            UIAlertView.showAlertView("", message: "接続に失敗しました。通信状況を確認の上、再接続してくだささい。")
            createRefreshButton()
            return
        }
    }

    func createupdateGeoPointButton() {
        //GeoPoint 更新ボタン
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xB54241)
        btn.setTitle("現在位置登録", forState: .Normal)
        btn.addTarget(self, action: "onClickImakoko", forControlEvents: UIControlEvents.TouchUpInside)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height - self.view.bounds.height/8.3)
        self.view.addSubview(btn)
    }
    
    func createRefreshButton() {
        //画面リフレッシュボタン
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xB54241)
        btn.setTitle("再表示", forState: .Normal)
        btn.addTarget(self, action: "onClickViewRefresh", forControlEvents: UIControlEvents.TouchUpInside)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height - self.view.bounds.height/8.3)
        self.view.addSubview(btn)
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
        
        MBProgressHUDHelper.show("Loading...")
        
        latitude = locations.first!.coordinate.latitude
        longitude = locations.first!.coordinate.longitude
        
        NSLog("位置情報取得成功！-> latiitude: \(latitude) , longitude: \(longitude)")
        
        //現在位置
        self.myPosition = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        var camera = GMSCameraPosition(target: self.myPosition, zoom: 13, bearing: 0, viewingAngle: 0)
        
        self.gmaps = GMSMapView()
        if let gmaps = gmaps {
            self.gmaps.frame = CGRectMake(0, 20, self.view.frame.width, self.view.frame.height/2)
            self.gmaps.myLocationEnabled = true
            self.gmaps.settings.myLocationButton = true
            self.gmaps.camera = camera
            self.gmaps.delegate = self
            
            self.view = self.gmaps
            
        }
        
        FeedData.mainData().refreshMapFeed(myPosition) { () -> () in
            GoogleMapsHelper.setUserMarker(self.gmaps!, userObjects: FeedData.mainData().feedItems)
            
        }
        
        manager.stopUpdatingLocation()
        
        //button 生成
        createNavigationItem()
        createupdateGeoPointButton()
        
        MBProgressHUDHelper.hide()
    }
    
    func createNavigationItem() {
        
        //◆プロフィール画面
        let profileViewButton: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        profileViewButton.setImage(UIImage(named: "profile_icon.png"), forState: UIControlState.Normal)
        profileViewButton.titleLabel?.font = UIFont.systemFontOfSize(11)
        profileViewButton.setTitle("設定", forState: UIControlState.Normal)
        profileViewButton.addTarget(self, action: "onClickProfileView", forControlEvents: UIControlEvents.TouchUpInside)
        profileViewButton.frame = CGRectMake(0, 0, 60, 53)
        profileViewButton.imageEdgeInsets = UIEdgeInsetsMake(-25, 17, 0, 0)
        profileViewButton.titleEdgeInsets = UIEdgeInsetsMake(22, -22, 0, 0)
        
        //create a new button
        let imakokoViewButton: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        imakokoViewButton.setImage(UIImage(named: "imakoko.png"), forState: UIControlState.Normal)
        imakokoViewButton.titleLabel?.font = UIFont.systemFontOfSize(11)
        imakokoViewButton.setTitle("いま来る", forState: UIControlState.Normal)
        imakokoViewButton.addTarget(self, action: "onClickGoNowListView", forControlEvents: UIControlEvents.TouchUpInside)
        imakokoViewButton.frame = CGRectMake(0, 0, 60, 53)
        imakokoViewButton.imageEdgeInsets = UIEdgeInsetsMake(-25, 17, 0, 0)
        imakokoViewButton.titleEdgeInsets = UIEdgeInsetsMake(22, -22, 0, 0)
        
        self.navigationItem.rightBarButtonItems =
            [UIBarButtonItem(customView: profileViewButton), UIBarButtonItem(customView: imakokoViewButton)]
        
        //通知があったら表示
        //◆いま行く画面
        //いまいくボタンを押下したら表示するようにする？
        let imaikuViewButton: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        imaikuViewButton.setImage(UIImage(named: "imaiku.png"), forState: UIControlState.Normal)
        imaikuViewButton.titleLabel?.font = UIFont.systemFontOfSize(11)
        imaikuViewButton.setTitle("いま行く", forState: UIControlState.Normal)
        imaikuViewButton.sizeToFit()
        imaikuViewButton.addTarget(self, action: "onClickGoNowView", forControlEvents: UIControlEvents.TouchUpInside)
        imaikuViewButton.frame = CGRectMake(0, 0, 60, 53)
        imaikuViewButton.imageEdgeInsets = UIEdgeInsetsMake(-25, 17, 0, 0)
        imaikuViewButton.titleEdgeInsets = UIEdgeInsetsMake(22, -22, 0, 0)
        
        self.navigationItem.rightBarButtonItems =
            [UIBarButtonItem(customView: profileViewButton), UIBarButtonItem(customView: imakokoViewButton), UIBarButtonItem(customView: imaikuViewButton)]
        
        //いま行くボタンと、いまココボタンは両立できないため、どちらかを表示する
        //いずれもParseに登録した値を引っ張ってくる必要がある
        
        //リロード
        let reloadButton: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        reloadButton.setImage(UIImage(named: "reload.png"), forState: UIControlState.Normal)
        reloadButton.titleLabel?.font = UIFont.systemFontOfSize(11)
        reloadButton.setTitle("リロード", forState: UIControlState.Normal)
        reloadButton.addTarget(self, action: "onClickReload", forControlEvents: UIControlEvents.TouchUpInside)
        reloadButton.frame = CGRectMake(0, 0, 60, 53)
        reloadButton.imageEdgeInsets = UIEdgeInsetsMake(-25, 17, 0, 0)
        reloadButton.titleEdgeInsets = UIEdgeInsetsMake(22, -22, 0, 0)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: reloadButton)
        
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
        
        let vc = TargetProfileViewController(type: ProfileType.TargetProfile)
        vc.actionInfo = marker.userData
        
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
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return kAnimationController
    }
    
    func onClickProfileView() {
        let profileView = ProfileViewController()
        //profileView.userInfo =
        self.navigationController?.pushViewController(profileView, animated: true)
        
    }

    func onClickImakoko(){
        let vc = PickerViewController()
        vc.palKind = "imakoko"
        vc.palGeoPoint = PFGeoPoint(latitude: latitude, longitude: longitude)
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func onClickGoNowListView() {
        MBProgressHUDHelper.show("Loading...")
        
        ParseHelper.getGoNowMeList(PersistentData.User().userID) { (withError error: NSError?, result) -> Void in
            if error == nil {
                
                let vc = GoNowListViewController()
                vc.goNowList = result!
                self.navigationController!.pushViewController(vc, animated: true)
                
            } else {
                println(error)
            }
            
            MBProgressHUDHelper.hide()
        }
    }
    
    func onClickGoNowView() {
        MBProgressHUDHelper.show("Loading...")
        
        ParseHelper.getMyGoNow(PersistentData.User().userID) { (withError error: NSError?, result) -> Void in
            if error == nil {
                let vc = TargetProfileViewController(type: ProfileType.ImaikuTargetProfile)
                
                if let goNowObj: AnyObject = result {
                    let targetAction: AnyObject? = goNowObj.objectForKey("TargetUser")
                    let targetUser: AnyObject? = targetAction?.objectForKey("CreatedBy")
                    
                    vc.targetObjectID = goNowObj.objectId
                    vc.actionInfo = targetAction!
                    self.navigationController!.pushViewController(vc, animated: true)
                    
                } else {
                    
                    UIAlertView.showAlertDismiss("", message: "いまから行く人が登録されていません") { () -> () in
                        //self.navigationController!.popToRootViewControllerAnimated(true)
                    }
                }
            }
            
            MBProgressHUDHelper.hide()
        }
    }
    
    //更新
    func onClickReload() {
        self.lm.startUpdatingLocation()
        UIAlertView.showAlertDismiss("", message: "マップを更新しました") { () -> () in
        }
    }
    
    func onClickViewRefresh() {
        loadView()
        viewDidLoad()
    }
    
}

