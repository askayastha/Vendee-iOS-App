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
    
    func resetSearch() {
        dataRequest?.cancel()
        state = .Idle
        cancelled = true
        products.removeAllObjects()
        lastItem = 0
        retryCount = 0
    }
    
    deinit {
        print("SEARCH DEALLOCATING !!!!!")
    }
    
    func incrementRetryCount() {
        retryCount++
    }
    
    func parseShopStyleForItemOffset(itemOffset: Int, withLimit limit: Int, var forCategory category: String, completion: SearchComplete) {
        
        if state == .Loading { // Do not request more data if a request is in process.
            return
        }
        
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
            scout.scoutImageWithURI(product.smallImageURL!) { [unowned self]
                error, size, type in
                
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
        
        scout.scoutImageWithURI(product.smallImageURL!) { error, size, type in
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
    
    func populateProducts(json: JSON) {
        if let productsArray = json["products"].array {
            
            for item in productsArray {
                let id = item["id"]
                let buyURL = item["clickUrl"]
                let largeImageURL = item["image"]["sizes"]["Original"]["url"]
                let smallImageURL = item["image"]["sizes"]["IPhone"]["url"]
                let name = item["name"]
                let brandedName = item["brandedName"]
                let unbrandedName = item["unbrandedName"]
                let brandName = item["brand"]["name"]
                let brandImageURL = item["brand"]["userImage"]
                let price = item["priceLabel"]
                let salePrice = item["salePriceLabel"]
                let productDescription = item["description"]
                var categories: [String]?
                
                if let categoriesArray = item["categories"].array {
                    categories = [String]()
                    for item in categoriesArray {
                        categories!.append(item["id"].stringValue)
                    }
                }
                
                let product = Product()
                product.id = id.string
                product.buyURL = buyURL.string
                product.largeImageURL = largeImageURL.string
                product.smallImageURL = smallImageURL.string
                product.name = name.string
                product.brandedName = brandedName.string
                product.unbrandedName = unbrandedName.string
                product.brandName = brandName.string
                product.brandImageURL = brandImageURL.string
                product.formattedPrice = price.string
                product.formattedSalePrice = salePrice.string
                product.productDescription = productDescription.string
                product.categories = categories
                
                products.addObject(product)
            }
            
            lastItem = products.count
        }
    }
}
