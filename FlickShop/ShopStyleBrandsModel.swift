//
//  ShopStyleBrandsModel.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 4/5/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import Foundation

private let ShopStyleBrandsModelSingleton = ShopStyleBrandsModel()

class ShopStyleBrandsModel {
    
    class func sharedInstance() -> ShopStyleBrandsModel {
        return ShopStyleBrandsModelSingleton
    }
    
    var brands: [String: [NSDictionary]]!
    
    private init() {
        loadBrands()
    }
    
    func documentsDirectory() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[0]
    }
    
    func dataFileURL() -> NSURL {
        return documentsDirectory().URLByAppendingPathComponent("ShopStyle_Brands.plist")
    }
    
    func saveBrands() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(brands, forKey: "ShopStyle_Brands")
        archiver.finishEncoding()
        data.writeToURL(dataFileURL(), atomically: true)
    }
    
    func loadBrands() {
        let fileURL = dataFileURL()
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
            if let data = NSData(contentsOfURL: fileURL) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                brands = unarchiver.decodeObjectForKey("ShopStyle_Brands") as! [String: [NSDictionary]]
                unarchiver.finishDecoding()
            }
        }
    }
    
    func removeBrands() {
        let fileURL = dataFileURL()
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
            try! NSFileManager.defaultManager().removeItemAtURL(fileURL)
        }
    }
}
