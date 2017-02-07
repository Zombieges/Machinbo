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

//extension MapViewController: TransisionProtocol {}

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, GADBannerViewDelegate, GADInterstitialDelegate, UITabBarDelegate, TransisionProtocol {
    
    private var profileSettingButton: UIBarButtonItem!
    private var lm : CLLocationManager!
    private var longitude: CLLocationDegrees!
    private var latitude: CLLocationDegrees!
    private var markWindow = MarkWindow()
    private var mainNavigationCtrl: UINavigationController?
    
    @IBOutlet weak var mapViewContainer: UIView!
    
    override func viewDidLoad() {
        if let view = UINib(nibName: "MapView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.navigationItem.title = "ホーム"
        self.navigationController!.navigationBar.tintColor = UIColor.darkGray
        self.createNavigationItem()
        
        if self.isInternetConnect() {
            let center = NotificationCenter.default as NotificationCenter
            LocationManager.sharedInstance.startUpdatingLocation()
            center.addObserver(self, selector: #selector(self.foundLocation(_:)), name: NSNotification.Name(rawValue: LMLocationUpdateNotification as String as String), object: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        NSLog("didChangeAuthorizationStatus");
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
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let createdBy = marker.userData as AnyObject? else {
            self.refresh()
            return nil
        }
        
        self.markWindow = Bundle.main.loadNibNamed("MarkWindow", owner: self, options: nil)?.first! as! MarkWindow
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
        
        return self.markWindow
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let vc = TargetProfileViewController(type: ProfileType.targetProfile)
        vc.userInfo = marker.userData! as? PFObject
        self.navigationController!.pushViewController(vc, animated: false)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("位置情報取得失敗")
        UIAlertController.showAlertView("エラー", message:"位置情報の取得が失敗しました。アプリを再起動してください。") { _ in
            manager.stopUpdatingLocation()
            self.createRefreshButton()
        }
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
    
    func onClickReload() {
        let center = NotificationCenter.default as NotificationCenter
        LocationManager.sharedInstance.startUpdatingLocation()
        center.addObserver(self, selector: #selector(self.foundLocation), name: NSNotification.Name(rawValue: LMLocationUpdateNotification as String as String), object: nil)
    }
    
    func foundLocation(_ notif: Notification) {
        defer { NotificationCenter.default.removeObserver(self) }

        self.createGoogleMapForNearGeoPoint(notif: notif)
        self.createupdateGeoPointButton()
    }
    
    private func createGoogleMapForNearGeoPoint(notif: Notification) {
        let info = notif.userInfo as NSDictionary!
        let location = info?[LMLocationInfoKey] as! CLLocation
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        
        NSLog("位置情報取得成功！-> latiitude: \(latitude) , longitude: \(longitude)")
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
            GoogleMapsHelper.setAnyUserMarker(gmaps, userObjects: FeedData.mainData().feedItems)
            self.showAdmob(AdmobType.full)
        }
    }
    
    private func createupdateGeoPointButton() {
        let btn = ZFRippleButton(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        btn.trackTouchLocation = true
        btn.backgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleBackgroundColor = LayoutManager.getUIColorFromRGB(0xD9594D)
        btn.rippleColor = LayoutManager.getUIColorFromRGB(0xB54241)
        btn.setTitle("待ち合わせ登録", for: UIControlState())
        btn.addTarget(self, action: #selector(MapViewController.onClickImakoko), for: UIControlEvents.touchUpInside)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height - self.view.bounds.height/7.3)
        self.view.addSubview(btn)
    }
    
    private func createNavigationItem() {
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
    
    internal func createRefreshButton() {
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
}

