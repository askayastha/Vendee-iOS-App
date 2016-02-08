//
//  Search.swift
//  AmazonProduct
//
//  Created by Ashish Kayastha on 9/7/15.
//  Copyright (c) 2015 Ashish Kayastha. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

typealias SearchComplete = (Bool, Int) -> Void

class Search {
    
    enum State {
        case Idle
        case Loading
        case Success
        case Failed
    }
    
    private(set) var dataRequest: Alamofire.Request?
    private(set) var state: State = .Idle
    private(set) var products = NSMutableOrderedSet()
    private(set) var lastItem = 0
    private(set) var retryCount = 0
    
    var filteredSearch = false
    var cancelled = false
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let scout = ImageScout()
    
    deinit {
        print("SEARCH DEALLOCATING !!!!!")
    }
    
    func resetSearch() {
        dataRequest?.cancel()
        state = .Idle
        cancelled = true
        products.removeAllObjects()
        lastItem = 0
        retryCount = 0
    }
    
    func incrementRetryCount() {
        retryCount++
    }
    
    func resetRetryCount() {
        retryCount = 0
    }
    
    func parseShopStyleForProductId(productId: Int, completion: SearchComplete) {
        if state == .Loading { return }     // Do not request more data if a request is in process.
        var success = false
        
        dataRequest = Alamofire.request(ShopStyle.Router.Product(productId)).validate().responseJSON() { response in
            if response.result.isSuccess {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    print("----------Got results!----------")
                    
                    let jsonData = JSON(response.result.value!)
                    self.populateProduct(jsonData)
                    
                    success = true
                    self.state = .Success
                    print("Request successful")
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(success, self.lastItem)
                    }
                }
            } else {
                self.state = .Failed
                completion(success, self.lastItem)
            }
        }
    }
    
    func parseShopStyleForItemOffset(itemOffset: Int, withLimit limit: Int, var forCategory category: String, completion: SearchComplete) {
        
        if state == .Loading { return }     // Do not request more data if a request is in process.
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        state = .Loading
        var success = false
        
        if filteredSearch {
            // Get category code for filter
            if let filterCategory = getFilterCategory() {
                category = filterCategory
            }
            
            // Get sort code for filter
            let sort = appDelegate.filter.sort.count > 0 ? appDelegate.filter.sort.values.first : nil
            
            // New request URL for filter
            var requestURL = ShopStyle.Router.FilteredProducts(itemOffset, limit, category, sort).URLRequest.URLString
            requestURL.appendContentsOf(getFilterParams())
            
            print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
            print(requestURL)
            
            dataRequest = Alamofire.request(.GET, requestURL).responseJSON() { response in
                if response.result.isSuccess {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        print("----------Got results!----------")
                        
                        let jsonData = JSON(response.result.value!)
                        self.populateProducts(jsonData)
                        success = true
                        self.state = .Success
                        print("Request successful")
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(success, self.lastItem)
                        }
                    }
                } else {
                    self.state = .Failed
                    completion(success, self.lastItem)
                }
            }
            
        } else {
            dataRequest = Alamofire.request(ShopStyle.Router.PopularProducts(itemOffset, limit, category)).validate().responseJSON() { response in
                
                if response.result.isSuccess {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        print("----------Got results!----------")
                        
                        let jsonData = JSON(response.result.value!)
                        self.populateProducts(jsonData)
                        success = true
                        self.state = .Success
                        print("Request successful")
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(success, self.lastItem)
                        }
                    }
                } else {
                    self.state = .Failed
                    completion(success, self.lastItem)
                }
            }
        }
    }
    
    func populatePhotoSizesFromIndex(index: Int, withLimit limit: Int, completion: (Bool, Int) -> ()) {
        var success = false
        var count = 0
        let lastIndex = index + limit
        
        func populatePhotoSizeForProduct(product: Product) {
            scout.scoutImageWithURI(product.smallImageURLs!.first!) { error, size, type in
                
                if let unwrappedError = error {
                    print(unwrappedError.code)
                    populatePhotoSizeForProduct(product)
                    
                } else {
                    let imageSize = CGSize(width: size.width, height: size.height)
                    product.smallImageSize = imageSize
                    print("\(index + count)*****\(imageSize)")
                    count++
                    
                    success = true
                    if count == limit && !self.cancelled {
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(success, lastIndex)
                        }
                    }
                }
            }
        }
        
        for var i = index; i < lastIndex; i++ {
            if products.count > 0 {
                let product = products.objectAtIndex(i) as! Product
                populatePhotoSizeForProduct(product)
            }
        }
    }
    
    func populatePhotoSizeForIndexPath(indexPath: NSIndexPath, completion: (Bool) -> ()) {
        var success = false
        let product = products.objectAtIndex(indexPath.item) as! Product
        
        scout.scoutImageWithURI(product.smallImageURLs!.first!) { error, size, type in
            if let unwrappedError = error {
                print("ImageScout Error: \(unwrappedError.code)")
                
                // Retry if error
                self.populatePhotoSizeForIndexPath(indexPath, completion: completion)
                
            } else {
                product.smallImageSize = CGSize(width: size.width, height: size.height)
                print("\(indexPath.item)*****\(CGSize(width: size.width, height: size.height))")
                
                success = true
                dispatch_async(dispatch_get_main_queue()) {
                    completion(success)
                }
            }
        }
    }
    
    func getFilterCategory() -> String? {
        let tappedCategories = appDelegate.filter.category["tappedCategories"] as! [String]
        let categoriesIdDict = appDelegate.filter.category["categoriesIdDict"] as! [String: String]
        var categoryId: String?
        
        if let category = tappedCategories.last {
            categoryId = categoriesIdDict[category]
        }
        
        return categoryId
    }
    
    func getFilterParams() -> String {
        var filterParams = [String]()
        
        for filtersObj in [AnyObject](appDelegate.filter.filterParams.values) {
            let filters = filtersObj as! [String: String]
            for code in [String](filters.values) {
                filterParams.append("fl=\(code)")
            }
        }
        
        let finalFilterParams = filterParams.joinWithSeparator("&")
        
        // finalFilterParams = initialfilterParams.substringFromIndex(initialfilterParams.startIndex.advancedBy(3))    ; print(finalFilterParams)
        return "&\(finalFilterParams)"
    }
    
    private func populateProduct(product: JSON) {
        let id = product["id"].intValue
        let buyURL = product["clickUrl"]
        var tinyImageURLs: [String]!
        var smallImageURLs: [String]!
        var largeImageURLs: [String]!
        let name = product["name"]
        let brandedName = product["brandedName"]
        let unbrandedName = product["unbrandedName"]
        let brandName = product["brand"]["name"]
        let brandImageURL = product["brand"]["userImage"]
        let price = product["price"]
        let salePrice = product["salePrice"]
        let formattedPrice = product["priceLabel"]
        let formattedSalePrice = product["salePriceLabel"]
        let description = product["description"]
        var categories: [String]!
        
        if let categoriesArray = product["categories"].array {
            categories = [String]()
            for category in categoriesArray {
                categories.append(category["id"].stringValue)
            }
        }
        
        if let alternateImages = product["alternateImages"].array {
            tinyImageURLs = [String]()
            smallImageURLs = [String]()
            largeImageURLs = [String]()
            
            // First URL
            tinyImageURLs.append(product["image"]["sizes"]["IPhoneSmall"]["url"].stringValue)
            smallImageURLs.append(product["image"]["sizes"]["IPhone"]["url"].stringValue)
            largeImageURLs.append(product["image"]["sizes"]["Original"]["url"].stringValue)
            
            // Alternate URLs
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
        
        let product = Product()
        product.id = String(id)
        product.buyURL = buyURL.string
        product.tinyImageURLs = tinyImageURLs
        product.smallImageURLs = smallImageURLs
        product.largeImageURLs = largeImageURLs
        product.name = name.string
        product.brandedName = brandedName.string
        product.unbrandedName = unbrandedName.string
        product.brandName = brandName.string
        product.brandImageURL = brandImageURL.string
        product.price = price.float
        product.salePrice = salePrice.float
        product.formattedPrice = formattedPrice.string
        product.formattedSalePrice = formattedSalePrice.string
        product.description = description.string
        product.categories = categories
        
        products.addObject(product)
    }
    
    private func populateProducts(json: JSON) {
        if let products = json["products"].array {
            
            for product in products {
                populateProduct(product)
            }
            
            lastItem = products.count
        }
    }
}
