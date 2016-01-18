//
//  Product.swift
//  AmazonProduct
//
//  Created by Ashish Kayastha on 8/24/15.
//  Copyright (c) 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class Product {
    
    var id: String?
    var description: String?
    
    var buyURL: String?
    var brandImageURL: String?
    
    var tinyImageURLs: [String]?
    var smallImageURLs: [String]?
    var largeImageURLs: [String]?
    
    var tinyImageSize: CGSize?
    var smallImageSize: CGSize?
    var largeImageSizes = [CGSize?]()
    
    var name: String?
    var brandedName: String?
    var unbrandedName: String?
    var brandName: String?
    
    var price: Float?
    var salePrice: Float?
    var formattedPrice: String?
    var formattedSalePrice: String?
    
    var colors: [String]?
    var sizes: [String]?
    
    var categories: [String]?
}
