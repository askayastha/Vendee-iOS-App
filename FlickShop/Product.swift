//
//  Product.swift
//  AmazonProduct
//
//  Created by Ashish Kayastha on 8/24/15.
//  Copyright (c) 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

struct ImageSize {
    var width: CGFloat
    var height: CGFloat
}

class Product: NSObject {
    
    var id: String?
    var buyURL: String?
    var largeImageURL: String?
    var smallImageURL: String?
    var name: String?
    var brandedName: String?
    var unbrandedName: String?
    var brandName: String?
    var brandImageURL: String?
    var formattedPrice: String?
    var formattedSalePrice: String?
    var colors: [String]?
    var sizes: [String]?
    var productDescription: String?
    var categories: [String]?
    var smallImageSize: CGSize?
    
//    init(id: String, detailPageURL: String, largeImageURL: String) {
//        self.id = id
//        self.detailPageURL = detailPageURL
//        self.largeImageURL = largeImageURL
//        
//        super.init()
//    }
    
//    required init(response: NSHTTPURLResponse, representation: AnyObject) {
//        
//    }
}
