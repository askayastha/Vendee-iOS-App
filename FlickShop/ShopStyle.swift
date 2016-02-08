//
//  ShopStyle.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 12/11/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import Foundation
import Alamofire

struct ShopStyle {
    
    enum Router: URLRequestConvertible {
        static let baseURLString = "https://api.shopstyle.com/api/v2"
        static let APIKey = "uid4529-31475977-85"
        
        case PopularProducts(Int, Int, String)
        case Categories(String)
        case FilteredProducts(Int, Int, String, String?)
        case Product(Int)
        
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
                    
                case .Product(let id):
                    return "products/\(id)"
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
                    
                case .FilteredProducts (let offset, let limit, let category, let sort):
                    var params = [
                        "pid": Router.APIKey,
                        "cat": category,
                        "offset": "\(offset)",
                        "limit": "\(limit)"
                    ]
                    
                    if let sort = sort {
                        params["sort"] = "\(sort)"
                    }
                    
                    return params
                    
                case .Product(_):
                    let params = [
                        "pid": Router.APIKey
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