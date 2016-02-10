//
//  DataModel.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 2/9/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import Foundation

class DataModel {
    
    var favoriteProducts = NSMutableOrderedSet()
    var favoriteProductIds = Set<String>()
    
    init() {
        loadProducts()
    }
    
    func documentsDirectory() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[0]
    }
    
    func dataFileURL() -> NSURL {
        return documentsDirectory().URLByAppendingPathComponent("FavoriteProducts.plist")
    }
    
    func saveProducts() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(favoriteProducts, forKey: "FavoriteProducts")
        archiver.encodeObject(favoriteProductIds, forKey: "FavoriteProductIds")
        archiver.finishEncoding()
        data.writeToURL(dataFileURL(), atomically: true)
    }
    
    func loadProducts() {
        let fileURL = dataFileURL()
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
            if let data = NSData(contentsOfURL: fileURL) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                favoriteProducts = unarchiver.decodeObjectForKey("FavoriteProducts") as! NSMutableOrderedSet
                favoriteProductIds = unarchiver.decodeObjectForKey("FavoriteProductIds") as! Set<String>
                unarchiver.finishDecoding()
//                sortFavoriteProducts()
            }
        }
    }
    
//    func sortProducts() {
//        favoriteProducts.sortInPlace({ checklist1, checklist2 in
//            return checklist1.name.localizedStandardCompare(checklist2.name) == .OrderedAscending
//        })
//    }
}