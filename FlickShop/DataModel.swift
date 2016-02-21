//
//  DataModel.swift
//  Vendee
//
//  Created by Ashish Kayastha on 2/9/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import Foundation

func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedDescending
}

class DataModel {
    
    private(set) var favoriteProducts = NSMutableOrderedSet()
    
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
    
    func addFavoriteProduct(product: Product) {
        if !containsProductId(product.id) {
            product.favoritedDate = NSDate()
            favoriteProducts.insertObject(product, atIndex: 0)
            saveProducts()
            CustomNotifications.dataModelDidChangeNotification()
        }
    }
    
    func removeFavoriteProduct(product: Product) {
        if containsProductId(product.id) {
            let index = indexOfProductId(product.id)
            print("Remove item at index: \(index!)")
            favoriteProducts.removeObjectAtIndex(index!)
            saveProducts()
            CustomNotifications.dataModelDidChangeNotification()
        }
    }
    
    func saveProducts() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(favoriteProducts, forKey: "FavoriteProducts")
        archiver.finishEncoding()
        data.writeToURL(dataFileURL(), atomically: true)
    }
    
    func loadProducts() {
        let fileURL = dataFileURL()
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
            if let data = NSData(contentsOfURL: fileURL) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                favoriteProducts = unarchiver.decodeObjectForKey("FavoriteProducts") as! NSMutableOrderedSet
                unarchiver.finishDecoding()
                sortProducts()
            }
        }
    }
    
    func containsProductId(productId: String) -> Bool {
        let results = favoriteProducts.filter {
            return ($0 as! Product).id == productId
        }
        
        return results.count > 0
    }
    
    func indexOfProductId(id: String) -> Int? {
        var index = 0
        for favoriteProduct in favoriteProducts {
            let product = favoriteProduct as! Product
            if product.id == id { return index }
            index++
        }
        return nil
    }
    
    func sortProducts() {
        favoriteProducts.sortUsingComparator { lhs, rhs in
            let obj1 = lhs as! Product
            let obj2 = rhs as! Product
            
            if obj1.favoritedDate < obj2.favoritedDate {
                return .OrderedDescending
            } else if obj1.favoritedDate > obj2.favoritedDate {
                return .OrderedAscending
            }
            return .OrderedSame
        }
    }
}
