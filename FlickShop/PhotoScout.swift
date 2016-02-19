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
    
    var lastItem: Int {
        return products.count
    }
    
    init(products: NSMutableOrderedSet) {
        self.products = products
    }
    
    deinit {
        print("PHOTOSCOUT DEALLOCATING")
    }
    
    func populatePhotoSizesFromIndex(index: Int, withLimit limit: Int, completion: (Bool, Int) -> ()) {
        var count = 0
        var retryCount = 0
        let lastIndex = index + limit
        
        func populatePhotoSizeForProduct(product: Product) {
            scout.scoutImageWithURI(product.smallImageURLs!.first!) { [unowned self] error, size, type in
                
                if let unwrappedError = error {
                    print(unwrappedError.code)
                    
                    if retryCount < 1 {
                        print("Retry getting small image size.")
                        retryCount++
                        populatePhotoSizeForProduct(product)
                    } else {
                        print("Retry failed. Moving on to completion.")
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(false, lastIndex)
                        }
                    }
                    
                } else {
                    let imageSize = CGSize(width: size.width, height: size.height)
                    product.smallImageSize = imageSize
                    print("\(index + count)*****\(imageSize)")
                    count++
                    
                    if count == limit && !self.cancelled {
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(true, lastIndex)
                        }
                    }
                }
            }
        }
        
        for var i = index; i < lastIndex; i++ {
            guard i < products.count else { break }
            
            let product = products.objectAtIndex(i) as! Product
            if let _ = product.smallImageSize {
                count++
                if count == limit && !self.cancelled {
                    completion(true, lastIndex)
                }
            } else {
                populatePhotoSizeForProduct(product)
            }
        }
    }
}