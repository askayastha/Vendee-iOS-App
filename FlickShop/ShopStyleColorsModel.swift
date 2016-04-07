//
//  ShopStyleColorsModel.swift
//  Vendee
//
//  Created by Ashish Kayastha on 4/7/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import Foundation

private let ShopStyleColorsModelSingleton = ShopStyleColorsModel()

class ShopStyleColorsModel {
    
    class func sharedInstance() -> ShopStyleColorsModel {
        return ShopStyleColorsModelSingleton
    }
    
    var colors: NSMutableOrderedSet!
    
    private init() {
        loadColors()
    }
    
    func documentsDirectory() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[0]
    }
    
    func dataFileURL() -> NSURL {
        return documentsDirectory().URLByAppendingPathComponent("ShopStyle_Colors.plist")
    }
    
    func saveColors() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(colors, forKey: "ShopStyle_Colors")
        archiver.finishEncoding()
        data.writeToURL(dataFileURL(), atomically: true)
    }
    
    func loadColors() {
        let fileURL = dataFileURL()
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
            if let data = NSData(contentsOfURL: fileURL) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                colors = unarchiver.decodeObjectForKey("ShopStyle_Colors") as! NSMutableOrderedSet
                unarchiver.finishDecoding()
            }
        }
    }
    
    func removeColors() {
        let fileURL = dataFileURL()
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
            try! NSFileManager.defaultManager().removeItemAtURL(fileURL)
        }
    }
}
