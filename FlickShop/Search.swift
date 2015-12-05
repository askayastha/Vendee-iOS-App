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
        case NotSearchedYet
        case Loading
        case Success
        case Failed
    }
    
    private(set) var state: State = .NotSearchedYet
    private(set) var products = NSMutableOrderedSet()
    private(set) var lastItem = 0
    
    var filteredSearch = false
    var dataRequest: Alamofire.Request?
    var retryCount = 0
    
    let scout = ImageScout()
    
    func parseShopStyleForItemOffset(itemOffset: Int, withLimit limit: Int, var forCategory category: String, completion: SearchComplete) {
        
        if state == .Loading { // Do not request more data if a request is in process.
            return
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        state = .Loading
        var success = false
        
        if filteredSearch {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            if let cat = appDelegate.category {
                category = cat
            }
            
            let sort = appDelegate.sort
            
            var finalFilterParams: String?
            
            var modifiedURL = ShopStyle.Router.FilteredProducts(itemOffset, limit, category, finalFilterParams, sort).URLRequest.URLString
            
            if appDelegate.filterParams.count > 0 {
                var filters = [String]()
                
//                for filter in appDelegate.filterParams {
//                    filters.append("fl=\(filter)")
//                }
                
                for filterCodes in appDelegate.filterParams.values {
                    if let codes = filterCodes as? [String] {
                        for code in codes {
                            filters.append("fl=\(code)")
                        }
                        
                    } else if let codes = filterCodes as? String {
                        filters.append("fl=\(codes)")
                    }
                }
                
                let initialfilterParams = filters.joinWithSeparator("&")
                
//                finalFilterParams = initialfilterParams.substringFromIndex(initialfilterParams.startIndex.advancedBy(3))    ; print(finalFilterParams)
                finalFilterParams = initialfilterParams
                modifiedURL += "&" + finalFilterParams!
            }
            
            print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
            print(modifiedURL)
            
            dataRequest = Alamofire.request(.GET, modifiedURL).responseJSON() {
                response in
                
                print(response.request)
                
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
            dataRequest = Alamofire.request(ShopStyle.Router.PopularProducts(itemOffset, limit, category)).validate().responseJSON() {
                response in
                
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
    
    func populatePhotoSizesForLimit(limit: Int, completion: (Bool, Int) -> ()) {
        
        var success = false
        var count = 0
        let fromIndex = lastItem - limit
        
        for var i = fromIndex; i < lastItem; i++ {
            let product = products.objectAtIndex(i) as! Product
            
            scout.scoutImageWithURI(product.smallImageURL!) { [unowned self]
                error, size, type in
                
                if let unwrappedError = error {
                    print(unwrappedError.code)
                    
                } else {
                    let imageSize = CGSize(width: size.width, height: size.height)
                    product.smallImageSize = imageSize
                    print("\(count)*****\(imageSize)")
                    count++
                    
                    success = true
                }
                
                if count == limit {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(success, self.lastItem)
                    }
                }
            }
        }
    }
    
    func populatePhotoSizeForIndexPath(indexPath: NSIndexPath, completion: (Bool) -> ()) {
        
        var success = false
        
        let product = products.objectAtIndex(indexPath.item) as! Product
        
        scout.scoutImageWithURI(product.smallImageURL!) { error, size, type in
            if let unwrappedError = error {
                print(unwrappedError.code)
                
            } else {
                product.smallImageSize = CGSize(width: size.width, height: size.height)
                print("\(indexPath.item)*****\(CGSize(width: size.width, height: size.height))")
                
                success = true
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(success)
            }
        }
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

struct ShopStyle {
    enum Router: URLRequestConvertible {
        static let baseURLString = "https://api.shopstyle.com/api/v2"
        static let APIKey = "uid4529-31475977-85"
        
        case PopularProducts(Int, Int, String)
        case Categories(String)
        case FilteredProducts(Int, Int, String, String?, String?)
        
        var URLRequest: NSMutableURLRequest {
//            let (path: String, parameters: [String: AnyObject]) = {
//                switch self {
//                    case .PopularProducts (let offset):
//                        
//                        let params = ["pid": Router.APIKey, "cat": "womens-clothes", "offset": "\(offset)"]
//                        return ("/products", params)
//                }
//            }()
        
            let path: String = {
                switch self {
                    case .PopularProducts(_):
                        return "products"
                    
                    case .Categories(_):
                        return "categories"
                    
                    case .FilteredProducts(_):
                        return "products"
                    }
            }()
            
            let parameters: [String: AnyObject] = {
                switch self {
                    case .PopularProducts (let offset, let limit, let category):
                        let params = [
                            "pid": Router.APIKey,
                            "cat": category,
                            "offset": "\(offset)",
                            "limit": "\(limit)",
//                            "fl": "d0&fl=b3510&fl=b689&fl=r21",
                            "fl": "d100",
                            "sort": "Popular"
                        ]
                        return params
                    
                    case .Categories (let category):
                        let params = [
                            "pid": Router.APIKey,
                            "cat": category
                        ]
                    return params
                    
                    case .FilteredProducts (let offset, let limit, let category, let _, let sort):
                        var params = [
                            "pid": Router.APIKey,
                            "cat": category,
                            "offset": "\(offset)",
                            "limit": "\(limit)"
                        ]
                        
//                        if let filterParams = filterParams {
//                            params["fl"] = "\(filterParams)"
//                        }
                        
                        if let sort = sort {
                            params["sort"] = "\(sort)"
                        }
                        
                        return params
                }
            }()
        
            let URL = NSURL(string: Router.baseURLString)
            let URLRequest = NSURLRequest(URL: URL!.URLByAppendingPathComponent(path))
            let encoding = Alamofire.ParameterEncoding.URL
            
            return encoding.encode(URLRequest, parameters: parameters).0
        }
    }
    
    enum ImageSize: Int {
        case Tiny = 1
        case Small = 2
        case Medium = 3
        case Large = 4
        case XLarge = 5
    }
}