//
//  LocationManager.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2016/06/12.
//  Copyright © 2016年 Zombieges. All rights reserved.
//

import Foundation
import CoreLocation

let LMLocationUpdateNotification : NSString = "LMLocationUpdateNotification"

let LMLocationInfoKey : NSString = "LMLocationInfoKey"

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    fileprivate var locationManager_: CLLocationManager
    fileprivate var currentLocation: CLLocation!
    
    struct Singleton {
        static let sharedInstance = LocationManager()
    }
    
    class var sharedInstance: LocationManager {
        return Singleton.sharedInstance
    }
    
    override init() {
        locationManager_ = CLLocationManager()
//        locationManager_.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager_.distanceFilter = 100 // meters
        super.init()
        locationManager_.delegate = self

        locationManager_.requestWhenInUseAuthorization()
        locationManager_.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager_.pausesLocationUpdatesAutomatically = true
        
        if #available(iOS 9.0, *) {
            locationManager_.allowsBackgroundLocationUpdates = true
        }
        
        // iOS8用のメソッドがあるかチェック
        if (self.locationManager_.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization))) {
            self.locationManager_.requestWhenInUseAuthorization()
        }
        
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            // まだ承認が得られていない場合は、認証ダイアログを表示
            locationManager_.requestWhenInUseAuthorization()
        }
    }
    
    
    func startUpdatingLocation()
    {
        print("Starting location updates")
        self.locationManager_.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location service failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        print("Location = \(location)")
        
        self.currentLocation = location
        
        let userInfo = [ LMLocationInfoKey : location]
        let center = NotificationCenter.default
        center.post(name: Notification.Name(rawValue: LMLocationUpdateNotification as String), object:self, userInfo: userInfo)
        self.locationManager_.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .notDetermined) {
            if (self.locationManager_.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization))) {
                self.locationManager_.requestWhenInUseAuthorization()
            }
        }
    }
}
