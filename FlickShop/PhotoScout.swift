//
//  PhotoScout.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 2/19/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import Foundation
import UIKit

class PhotoScout {
    
    let scout = ImageScout()
    var products: NSMutableOrderedSet
    var cancelled = false
    var lastItem: Int { return products.count }
    var totalItems: Int
    
    init(products: NSMutableOrderedSet, totalItems: Int) {
        self.products = products
        self.totalItems = totalItems
    }
    
    deinit {
        print("PHOTOSCOUT DEALLOCATING")
    }
    
    func populatePhotoSizesFromIndex(fromIndex: Int, withLimit limit: Int, completion: (Bool, Int, Int) -> ()) {
        var count = 0
        let lastIndex = fromIndex + limit
        
        func populatePhotoSizeForProduct(product: Product) {
            scout.scoutImageWithURI(product.smallImageURLs!.first!) { [unowned self] error, size, type in
                
                if let unwrappedError = error {
                    print(unwrappedError.code)
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(false, fromIndex, fromIndex)
                    }
                    
                } else {
                    let imageSize = CGSize(width: size.width, height: size.height)
                    product.smallImageSize = imageSize
                    print("\(fromIndex + count)*****\(imageSize)")
                    count += 1
                    
                    if count == limit && !self.cancelled {
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(true, fromIndex, lastIndex)
                        }
                        
                    } else if (fromIndex + count == self.totalItems) && !self.cancelled {
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(true, fromIndex, self.totalItems)
                        }
                    }
                }
            }
        }
        
        for i in fromIndex..<lastIndex {
            guard i < products.count else { break }
            
            let product = products.objectAtIndex(i) as! Product
            if let _ = product.smallImageSize {
                count += 1
                if count == limit && !self.cancelled {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(true, fromIndex, lastIndex)
                    }
                    
                } else if (fromIndex + count == self.totalItems) && !self.cancelled {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(true, fromIndex, self.totalItems)
                    }
                }
            } else {
                populatePhotoSizeForProduct(product)
            }
        }
    }
}