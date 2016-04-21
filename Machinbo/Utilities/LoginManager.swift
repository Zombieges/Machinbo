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

class LoginManager
{
    class var UUID:String?
    {
        let settings : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        //decode
        var temp = settings.objectForKey("UUID") as? String
        return ""//AESCrypt.decrypt(temp, password: "UUID")
    }
    
    class func createUserAccount(userName: String) {
        let UUID = NSUUID().UUIDString
        
        //NSUserDefaults.standardUserDefaults().setObject(userName, forKey:"UserName")
        NSUserDefaults.standardUserDefaults().setObject(UUID, forKey:"UUID")
        //ほかに登録するものがあったらここに 端末にはUUIDのみ保持しておけば良いかも
        NSUserDefaults.standardUserDefaults().synchronize()
        
        //insert into Parse
        let userInfo = PFObject(className: "UserInfo")
        userInfo["UserName"] = userName
        userInfo["UserID"] = UUID
        
        //ほかに登録するものがあったらここに
        
        userInfo.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            NSLog("==>Insert Into UserInfo userName: " + userName + "/UserID: " + UUID)
        }
        
    }
    
    class func getUserAccount() {
        //nabe create
    }
    
    class func getUUID() -> String {
        let UUIDString = NSUserDefaults.standardUserDefaults().objectForKey("UUID") as? NSString
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
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(localUUID)
        userDefaults.synchronize()
        
        let query: PFQuery = PFQuery(className: "UserInfo")
        query.whereKey("UserID", containsString: localUUID)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
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

func getUserIdFromDB() -> (userId: NSUUID, generatedOn: NSDate)
{
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let stored_user_id: NSDictionary? = userDefaults.dictionaryForKey("KEY")
    if stored_user_id != nil {
        // de user defaults hadden al wat
        let uuid_created = stored_user_id!["created"] as! NSDate
        let uuid_str = stored_user_id!["uuid"] as? String
        if uuid_str != nil {
            let uuid: NSUUID? = NSUUID(UUIDString: uuid_str!)
            if uuid != nil {
                // user defaults bevatten reeds een geldige uuid, return deze
                return (uuid!, uuid_created)
            }
        }
    }
    
    // nog geen id (of invalide storage), maak een nieuwe
    let uuid = NSUUID()
    let created = NSDate()
    let store_value: [NSObject: AnyObject] = [
        "created": created,
        "uuid": uuid.UUIDString
    ]
    userDefaults.setObject(store_value, forKey: "KEY")
    userDefaults.synchronize()
    return (uuid, created)
}




// haal device identifier op
// deze identifier is de zogenaamde uniek-voor-vendor id van Apple
// 'a UUID that may be used to uniquely identify the device, same across apps from a single vendor'
// @todo uitzoeken of hij hetzelfde blijft bij een system restore, en als de app op iemand anders z'n telefoon draait
func getDeviceIdForVendor() -> NSUUID
{
    let device = UIDevice.currentDevice()
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
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.removeObjectForKey("KEY")
    userDefaults.synchronize()
}

// bewaar usergegevens in de datastore
func storeUserInfoInDB(loginname: String, token: String!)
{
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setValue(loginname, forKey: "KEY")
    userDefaults.synchronize()
}

// haal usergegevens op uit de datastore
func getUserInfoFromDB() -> (loginname: String!, authtoken: String!)
{
    let userDefaults = NSUserDefaults.standardUserDefaults()
    return (
        userDefaults.stringForKey("KEY"),
        userDefaults.stringForKey("KEY")
    )
}
