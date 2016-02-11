//
//  Product.swift
//  AmazonProduct
//
//  Created by Ashish Kayastha on 8/24/15.
//  Copyright (c) 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class Product: NSObject, NSCoding {
    
    var id: String?
    var productDescription: String?
    
    var buyURL: String?
    
    var tinyImageURLs: [String]?
    var smallImageURLs: [String]?
    var largeImageURLs: [String]?
    
    var tinyImageSize: CGSize?
    var smallImageSize: CGSize?
    
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
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey("Id") as? String
        productDescription = aDecoder.decodeObjectForKey("ProductDescription") as? String
        
        buyURL = aDecoder.decodeObjectForKey("BuyURL") as? String
        
        tinyImageURLs = aDecoder.decodeObjectForKey("TinyImageURLs") as? [String]
        smallImageURLs = aDecoder.decodeObjectForKey("SmallImageURLs") as? [String]
        largeImageURLs = aDecoder.decodeObjectForKey("LargeImageURLs") as? [String]
        
        tinyImageSize = aDecoder.decodeObjectForKey("TinyImageSize") as? CGSize
        smallImageSize = aDecoder.decodeObjectForKey("SmallImageSize") as? CGSize
        
        name = aDecoder.decodeObjectForKey("Name") as? String
        brandedName = aDecoder.decodeObjectForKey("BrandedName") as? String
        unbrandedName = aDecoder.decodeObjectForKey("UnbrandedName") as? String
        brandName = aDecoder.decodeObjectForKey("BrandName") as? String
        
        price = aDecoder.decodeFloatForKey("Price")
        salePrice = aDecoder.decodeFloatForKey("SalePrice")
        formattedPrice = aDecoder.decodeObjectForKey("FormattedPrice") as? String
        formattedSalePrice = aDecoder.decodeObjectForKey("FormattedSalePrice") as? String
        
        colors = aDecoder.decodeObjectForKey("Colors") as? [String]
        sizes = aDecoder.decodeObjectForKey("Sizes") as? [String]
        
        categories = aDecoder.decodeObjectForKey("Categories") as? [String]
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "Id")
        aCoder.encodeObject(productDescription, forKey: "ProductDescription")
        
        aCoder.encodeObject(buyURL, forKey: "BuyURL")
        
        aCoder.encodeObject(tinyImageURLs, forKey: "TinyImageURLs")
        aCoder.encodeObject(smallImageURLs, forKey: "SmallImageURLs")
        aCoder.encodeObject(largeImageURLs, forKey: "LargeImageURLs")
        
        aCoder.encodeObject(tinyImageSize as? AnyObject, forKey: "TinyImageSize")
        aCoder.encodeObject(smallImageSize as? AnyObject, forKey: "SmallImageSize")
        
        aCoder.encodeObject(name, forKey: "Name")
        aCoder.encodeObject(brandedName, forKey: "BrandedName")
        aCoder.encodeObject(unbrandedName, forKey: "UnbrandedName")
        aCoder.encodeObject(brandName, forKey: "BrandName")
        
        aCoder.encodeFloat(price!, forKey: "Price")
        aCoder.encodeFloat(salePrice!, forKey: "SalePrice")
        aCoder.encodeObject(formattedPrice, forKey: "FormattedPrice")
        aCoder.encodeObject(formattedSalePrice, forKey: "FormattedSalePrice")
        
        aCoder.encodeObject(colors, forKey: "Colors")
        aCoder.encodeObject(sizes, forKey: "Sizes")
        
        aCoder.encodeObject(categories, forKey: "Categories")
    }
}
