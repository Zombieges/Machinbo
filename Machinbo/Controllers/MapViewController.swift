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
    
    private var longitude: CLLocationDegrees!
    private var latitude: CLLocationDegrees!
    private var markWindow = MarkWindow()
    
    @IBOutlet weak var gmsMapView: GMSMapView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        if let view = UINib(nibName: "MapView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
        
        self.prepareNavigationItem()
        
        guard self.isInternetConnect() else {
            self.errorAction()
            return
        }
        
        let center = NotificationCenter.default as NotificationCenter
        LocationManager.sharedInstance.startUpdatingLocation()
        center.addObserver(self, selector: #selector(self.foundLocation(_:)), name: NSNotification.Name(rawValue: LMLocationUpdateNotification as String as String), object: nil)
        
        let AdMobUnitID = ConfigData(type: .adMobUnit).getPlistKey
        bannerView.adUnitID = AdMobUnitID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
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
        vc.targetUserInfo = marker.userData! as? PFObject
        self.navigationController!.pushViewController(vc, animated: false)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
    
    func onClickSearch() {
        let vc = PickerViewController(kind: PickerKind.search)
        self.navigationController!.pushViewController(vc, animated: false)
    }
    
    func onClickReload() {
        LocationManager.sharedInstance.startUpdatingLocation()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.foundLocation),
            name: NSNotification.Name(rawValue: LMLocationUpdateNotification as String as String),
            object: nil
        )
    }
    
    func foundLocation(_ notif: Notification) {
        defer { NotificationCenter.default.removeObserver(self) }

        self.createGoogleMapForNearGeoPoint(notif: notif)
    }
    
    private func createGoogleMapForNearGeoPoint(notif: Notification) {
        let info = notif.userInfo as NSDictionary!
        let location = info?[LMLocationInfoKey] as! CLLocation
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        
        NSLog("位置情報取得成功！-> latiitude: \(latitude) , longitude: \(longitude)")
        
        let myPosition = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        //GoogleMap set GMSMapView
        let gmaps = GoogleMapsHelper.gmsMapView(self, myPosition)
        self.gmsMapView.addSubview(gmaps)
        
        FeedData.mainData().refreshMapFeed(myPosition) { () -> () in
            //GoogleMaps Set User Marker
            GoogleMapsHelper.setAnyUserMarker(gmaps, userObjects: FeedData.mainData().feedItems)
        }
    }
    
    private func prepareNavigationItem() {
        //self.navigationItem.title = "Machinbo"
        self.navigationController!.navigationBar.tintColor = UIColor.darkGray
        
        let titleView = UIImageView(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        titleView.image = UIImage(named: "machinbo_title")
        titleView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = titleView
        
        let reloadButton = UIButton(type: .custom)
        reloadButton.setImage(UIImage(named: "reload"), for: UIControlState())
        reloadButton.setTitleColor(.darkGray, for: UIControlState())
        reloadButton.addTarget(self, action: #selector(onClickReload), for: .touchUpInside)
        reloadButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        reloadButton.imageView?.contentMode = .scaleAspectFit
        
        self.navigationItem.leftBarButtonItems =
            [UIBarButtonItem(customView: reloadButton)]
        
        let seachButton = UIButton(type: .custom)
        seachButton.setImage(UIImage(named: "search"), for: UIControlState())
        seachButton.setTitleColor(.darkGray, for: UIControlState())
        seachButton.addTarget(self, action: #selector(onClickSearch), for: .touchUpInside)
        seachButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        seachButton.imageView?.contentMode = .scaleAspectFit
        
        self.navigationItem.rightBarButtonItems =
            [UIBarButtonItem(customView: seachButton)]
    }
    
    func refresh() {
        self.viewDidLoad()
    }
    
}

