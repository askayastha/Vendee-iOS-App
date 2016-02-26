//
//  Product.swift
//  Vendee
//
//  Created by Ashish Kayastha on 8/24/15.
//  Copyright (c) 2015 Ashish Kayastha. All rights reserved.
//

import SwiftyJSON

class Product: NSObject, NSCoding {
    // ShopStyle Properties
    var id: String!
    var name: String!
    var brandedName: String!
    var unbrandedName: String!
    var currency: String!
    var price: Float!
    var salePrice: Float!
    var formattedPrice: String!
    var formattedSalePrice: String!
    var inStock: Bool!
    var stock: [AnyObject]!
    var retailer: NSDictionary!
    var brand: NSDictionary!
    var locale: String!
    var productDescription: String!
    var clickURL: String!
    var pageURL: String!
    var image: NSDictionary!
    var alternateImages: [AnyObject]!
    var colors: [AnyObject]!
    var sizes: [AnyObject]!
    var categories: [AnyObject]!
    var extractDate: String!
    var badges: [AnyObject]!
    var seeMoreLabel: String!
    var seeMoreURL: String!
    var preOwned: Bool!
    var rental: Bool!
    
    // Custom Properties
    var tinyImageURLs: [String]!
    var smallImageURLs: [String]!
    var largeImageURLs: [String]!
    var tinyImageSize: CGSize!
    var smallImageSize: CGSize!
    var favoritedDate: NSDate!
    
    init(data: JSON) {
        // ShopStyle Properties
        self.id = String(data["id"].int)
        self.name = data["name"].string
        self.brandedName = data["brandedName"].string
        self.unbrandedName = data["unbrandedName"].string
        self.currency = data["currency"].string
        self.price = data["price"].float
        self.salePrice = data["salePrice"].float
        self.formattedPrice = data["priceLabel"].string
        self.formattedSalePrice = data["salePriceLabel"].string
        self.inStock = data["inStock"].bool
        self.retailer = data["retailer"].dictionaryObject
        self.brand = data["brand"].dictionaryObject
        self.locale = data["locale"].string
        self.productDescription = data["description"].string
        self.clickURL = data["clickUrl"].string
        self.pageURL = data["pageUrl"].string
        self.image = data["image"].dictionaryObject
        self.alternateImages = data["alternateImages"].arrayObject
        self.colors = data["colors"].arrayObject
        self.sizes = data["sizes"].arrayObject
        self.categories = data["categories"].arrayObject
        self.extractDate = data["extractDate"].string
        self.badges = data["badges"].arrayObject
        self.seeMoreLabel = data["seeMoreLabel"].string
        self.preOwned = data["preOwned"].bool
        self.rental = data["rental"].bool
        
        // Custom Properties
        tinyImageURLs = [String]()
        smallImageURLs = [String]()
        largeImageURLs = [String]()
        
        // First URL
        tinyImageURLs.append(data["image"]["sizes"]["IPhoneSmall"]["url"].stringValue)
        smallImageURLs.append(data["image"]["sizes"]["IPhone"]["url"].stringValue)
        largeImageURLs.append(data["image"]["sizes"]["Original"]["url"].stringValue)
        
        // Alternate URLs
        if let alternateImages = data["alternateImages"].array {
            for alternateImage in alternateImages {
                let tinyImageURL = alternateImage["sizes"]["IPhoneSmall"]["url"].stringValue
                let smallImageURL = alternateImage["sizes"]["IPhone"]["url"].stringValue
                let largeImageURL = alternateImage["sizes"]["Original"]["url"].stringValue
                
                if !tinyImageURLs.contains(tinyImageURL) {
                    tinyImageURLs.append(tinyImageURL)
                }
                if !smallImageURLs.contains(smallImageURL) {
                    smallImageURLs.append(smallImageURL)
                }
                if !largeImageURLs.contains(largeImageURL) {
                    largeImageURLs.append(largeImageURL)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        // ShopStyle Properties
        id = aDecoder.decodeObjectForKey("Id") as? String
        name = aDecoder.decodeObjectForKey("Name") as? String
        brandedName = aDecoder.decodeObjectForKey("BrandedName") as? String
        unbrandedName = aDecoder.decodeObjectForKey("UnbrandedName") as? String
        currency = aDecoder.decodeObjectForKey("Currency") as? String
        price = aDecoder.decodeFloatForKey("Price")
        salePrice = aDecoder.decodeFloatForKey("SalePrice")
        formattedPrice = aDecoder.decodeObjectForKey("FormattedPrice") as? String
        formattedSalePrice = aDecoder.decodeObjectForKey("FormattedSalePrice") as? String
        inStock = aDecoder.decodeBoolForKey("InStock")
        stock = aDecoder.decodeObjectForKey("Stock") as? [AnyObject]
        retailer = aDecoder.decodeObjectForKey("Retailer") as? NSDictionary
        brand = aDecoder.decodeObjectForKey("Brand") as? NSDictionary
        locale = aDecoder.decodeObjectForKey("Locale") as? String
        productDescription = aDecoder.decodeObjectForKey("ProductDescription") as? String
        clickURL = aDecoder.decodeObjectForKey("ClickURL") as? String
        pageURL = aDecoder.decodeObjectForKey("PageURL") as? String
        image = aDecoder.decodeObjectForKey("Image") as? NSDictionary
        alternateImages = aDecoder.decodeObjectForKey("AlternateImages") as? [AnyObject]
        colors = aDecoder.decodeObjectForKey("Colors") as? [AnyObject]
        sizes = aDecoder.decodeObjectForKey("Sizes") as? [AnyObject]
        categories = aDecoder.decodeObjectForKey("Categories") as? [AnyObject]
        extractDate = aDecoder.decodeObjectForKey("ExtractDate") as? String
        badges = aDecoder.decodeObjectForKey("Badges") as? [AnyObject]
        seeMoreLabel = aDecoder.decodeObjectForKey("SeeMoreLabel") as? String
        seeMoreURL = aDecoder.decodeObjectForKey("SeeMoreURL") as? String
        preOwned = aDecoder.decodeBoolForKey("PreOwned")
        rental = aDecoder.decodeBoolForKey("Rental")
        
        // Custom Properties
        tinyImageURLs = aDecoder.decodeObjectForKey("TinyImageURLs") as? [String]
        smallImageURLs = aDecoder.decodeObjectForKey("SmallImageURLs") as? [String]
        largeImageURLs = aDecoder.decodeObjectForKey("LargeImageURLs") as? [String]
        tinyImageSize = aDecoder.decodeObjectForKey("TinyImageSize") as? CGSize
        smallImageSize = aDecoder.decodeObjectForKey("SmallImageSize") as? CGSize
        favoritedDate = aDecoder.decodeObjectForKey("FavoritedDate") as? NSDate
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        // ShopStyle Properties
        aCoder.encodeObject(id, forKey: "Id")
        aCoder.encodeObject(name, forKey: "Name")
        aCoder.encodeObject(brandedName, forKey: "BrandedName")
        aCoder.encodeObject(unbrandedName, forKey: "UnbrandedName")
        aCoder.encodeObject(currency, forKey: "Currency")
        aCoder.encodeObject(price, forKey: "Price")
        aCoder.encodeObject(salePrice, forKey: "SalePrice")
        aCoder.encodeObject(formattedPrice, forKey: "FormattedPrice")
        aCoder.encodeObject(formattedSalePrice, forKey: "FormattedSalePrice")
        aCoder.encodeBool(inStock, forKey: "InStock")
        aCoder.encodeObject(stock, forKey: "Stock")
        aCoder.encodeObject(retailer, forKey: "Retailer")
        aCoder.encodeObject(brand, forKey: "Brand")
        aCoder.encodeObject(locale, forKey: "Locale")
        aCoder.encodeObject(productDescription, forKey: "ProductDescription")
        aCoder.encodeObject(clickURL, forKey: "ClickURL")
        aCoder.encodeObject(pageURL, forKey: "PageURL")
        aCoder.encodeObject(image, forKey: "Image")
        aCoder.encodeObject(alternateImages, forKey: "AlternateImages")
        aCoder.encodeObject(colors, forKey: "Colors")
        aCoder.encodeObject(sizes, forKey: "Sizes")
        aCoder.encodeObject(categories, forKey: "Categories")
        aCoder.encodeObject(extractDate, forKey: "ExtractDate")
        aCoder.encodeObject(badges, forKey: "Badges")
        aCoder.encodeObject(seeMoreLabel, forKey: "SeeMoreLabel")
        aCoder.encodeObject(seeMoreURL, forKey: "SeeMoreURL")
        aCoder.encodeBool(preOwned, forKey: "PreOwned")
        aCoder.encodeBool(rental, forKey: "Rental")
        
        // Custom Properties
        aCoder.encodeObject(tinyImageURLs, forKey: "TinyImageURLs")
        aCoder.encodeObject(smallImageURLs, forKey: "SmallImageURLs")
        aCoder.encodeObject(largeImageURLs, forKey: "LargeImageURLs")
        aCoder.encodeObject(tinyImageSize as? AnyObject, forKey: "TinyImageSize")
        aCoder.encodeObject(smallImageSize as? AnyObject, forKey: "SmallImageSize")
        aCoder.encodeObject(favoritedDate, forKey: "FavoritedDate")
    }
}
