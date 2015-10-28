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

typealias SearchComplete = (Bool) -> Void

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
    
    func parseShopStyleForItemOffset(itemOffset: Int, withLimit limit: Int, forCategory category: String, completion: SearchComplete) {
        
        if state == .Loading { // Do not request more data if a request is in process.
            return
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        state = .Loading
        var success = false
        
        Alamofire.request(ShopStyle.Router.PopularProducts(itemOffset, limit, category)).validate().responseJSON() {
            response in
            
            if response.result.isSuccess {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    print("----------Got results!----------")
                    
                    let jsonData = JSON(response.result.value!)
//                    print(jsonData)
                    
                    if let productsArray = jsonData["products"].array {
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
//                            var colors: [String]?
//                            var sizes: [String]?
                            var categories: [String]?
                            
//                            if let colorsArray = item["colors"].array {
//                                colors = [String]()
//                                for item in colorsArray {
//                                    colors!.append(item["name"].stringValue)
//                                }
//                            }
//                            
//                            if let sizesArray = item["sizes"].array {
//                                sizes = [String]()
//                                for item in sizesArray {
//                                    sizes!.append(item["name"].stringValue)
//                                }
//                            }
                            
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
//                            product.colors = colors
//                            product.sizes = sizes
                            product.categories = categories
                            
                            self.products.addObject(product)
                        }
                        
                        self.lastItem = self.products.count
                    }
                    
                    success = true
                    self.state = .Success
                    print("Request successful")
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(success)
                    }
                    
                }
            } else {
                self.state = .Failed
                
                completion(success)
            }
        }
    }
}

struct ShopStyle {
    enum Router: URLRequestConvertible {
        static let baseURLString = "https://api.shopstyle.com/api/v2"
        static let APIKey = "uid4529-31475977-85"
        
        case PopularProducts(Int, Int, String)
        
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