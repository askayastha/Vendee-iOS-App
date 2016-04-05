//
//  ShopStyleStoresModel.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 4/5/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import Foundation

private let ShopStyleStoresModelSingleton = ShopStyleStoresModel()

class ShopStyleStoresModel {
    
    class func sharedInstance() -> ShopStyleStoresModel {
        return ShopStyleStoresModelSingleton
    }
    
    var stores: [String: [NSDictionary]]!
    
    private init() {
        loadStores()
    }
    
    func documentsDirectory() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[0]
    }
    
    func dataFileURL() -> NSURL {
        return documentsDirectory().URLByAppendingPathComponent("ShopStyle_Stores.plist")
    }
    
    func saveStores() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(stores, forKey: "ShopStyle_Stores")
        archiver.finishEncoding()
        data.writeToURL(dataFileURL(), atomically: true)
    }
    
    func loadStores() {
        let fileURL = dataFileURL()
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
            if let data = NSData(contentsOfURL: fileURL) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                stores = unarchiver.decodeObjectForKey("ShopStyle_Stores") as! [String: [NSDictionary]]
                unarchiver.finishDecoding()
            }
        }
    }
    
    func removeStores() {
        let fileURL = dataFileURL()
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
            try! NSFileManager.defaultManager().removeItemAtURL(fileURL)
        }
    }
}
