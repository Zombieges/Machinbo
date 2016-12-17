//
//  File.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2015/07/25.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import Foundation
import UIKit
import Parse
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class LoginManager
{
    class var UUID:String?
    {
        //let settings : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        //decode
        //var temp = settings.objectForKey("UUID") as? String
        return ""//AESCrypt.decrypt(temp, password: "UUID")
    }
    
    class func createUserAccount(_ userName: String) {
        let UUID = Foundation.UUID().uuidString
        
        //NSUserDefaults.standardUserDefaults().setObject(userName, forKey:"UserName")
        UserDefaults.standard.set(UUID, forKey:"UUID")
        //ほかに登録するものがあったらここに 端末にはUUIDのみ保持しておけば良いかも
        UserDefaults.standard.synchronize()
        
        //insert into Parse
        let userInfo = PFObject(className: "UserInfo")
        userInfo["UserName"] = userName
        userInfo["UserID"] = UUID
        
        //ほかに登録するものがあったらここに
        
        userInfo.saveInBackground { (success: Bool, error: Error?) -> Void in
            NSLog("==>Insert Into UserInfo userName: " + userName + "/UserID: " + UUID)
        }
        
    }
    
    class func getUserAccount() {
        //nabe create
    }
    
    class func getUUID() -> String {
        let UUIDString = UserDefaults.standard.object(forKey: "UUID") as? NSString
        if UUIDString?.length > 0 {
            return (UUIDString as! String)
        }
        
        return String();
    }
    
    class func createUserAccount() {
        //nabe create
    }
    
    class func deleteUserAccount()
    {
        let localUUID = getUUID()
        
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: localUUID)
        userDefaults.synchronize()
        
        let query: PFQuery = PFQuery(className: "UserInfo")
        query.whereKey("UserID", contains: localUUID)
        query.findObjectsInBackground { (objects, error) -> Void in
            
            if let unwrappedObjects = objects {
                for object in unwrappedObjects {
                    NSLog("==>delete user:" + localUUID)
                    //try! object.delete() // 削除
                    do {
                        try object.delete() // 削除                        }
                    } catch {
                        // Error handling...
                    }
                }
            }
            //for object in (objects as! [PFObject]) {
            //    if(error == nil){
            //        NSLog("==>delete user:" + localUUID)
            //        object.delete() // 削除
            //    }
            //}
        }
    }
}

//以降、無視

func getUserIdFromDB() -> (userId: UUID, generatedOn: Date)
{
    let userDefaults = UserDefaults.standard
    let stored_user_id: NSDictionary? = userDefaults.dictionary(forKey: "KEY") as NSDictionary?
    if stored_user_id != nil {
        // de user defaults hadden al wat
        let uuid_created = stored_user_id!["created"] as! Date
        let uuid_str = stored_user_id!["uuid"] as? String
        if uuid_str != nil {
            let uuid: UUID? = UUID(uuidString: uuid_str!)
            if uuid != nil {
                // user defaults bevatten reeds een geldige uuid, return deze
                return (uuid!, uuid_created)
            }
        }
    }
    
    // nog geen id (of invalide storage), maak een nieuwe
    let uuid = UUID()
    let created = Date()
    let store_value: [AnyHashable: Any] = [
        "created": created,
        "uuid": uuid.uuidString
    ]
    userDefaults.set(store_value, forKey: "KEY")
    userDefaults.synchronize()
    return (uuid, created)
}




// haal device identifier op
// deze identifier is de zogenaamde uniek-voor-vendor id van Apple
// 'a UUID that may be used to uniquely identify the device, same across apps from a single vendor'
// @todo uitzoeken of hij hetzelfde blijft bij een system restore, en als de app op iemand anders z'n telefoon draait
func getDeviceIdForVendor() -> UUID
{
    let device = UIDevice.current
    return device.identifierForVendor!
}


// haal de 'bundle identifier' op (zeg maar de package name van de App)
func getBundleIdentifier() -> String
{
    return String(CFBundleGetIdentifier(CFBundleGetMainBundle()))
}


// verwijder usergegevens uit de datastore
func deleteUserInfoFromDB()
{
    let userDefaults = UserDefaults.standard
    userDefaults.removeObject(forKey: "KEY")
    userDefaults.synchronize()
}

// bewaar usergegevens in de datastore
func storeUserInfoInDB(_ loginname: String, token: String!)
{
    let userDefaults = UserDefaults.standard
    userDefaults.setValue(loginname, forKey: "KEY")
    userDefaults.synchronize()
}

// haal usergegevens op uit de datastore
func getUserInfoFromDB() -> (loginname: String?, authtoken: String?)
{
    let userDefaults = UserDefaults.standard
    return (
        userDefaults.string(forKey: "KEY"),
        userDefaults.string(forKey: "KEY")
    )
}
