//
//  ShopStyle.swift
//  Vendee
//
//  Created by Ashish Kayastha on 12/11/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import Alamofire

struct ShopStyle {
    
    enum Router: URLRequestConvertible {
        static let baseURLString = "https://api.shopstyle.com/api/v2"
        static let APIKey = "uid4529-31475977-85"
        
        case PreselectedResults(Int, Int, String)
        case PopularResults(Int, Int, String)
        case Categories(String)
        case FilteredResults(Int, Int, String, String?)
        case Product(String)
        
        var URLRequest: NSMutableURLRequest {
            let result: (path: String, parameters: [String: AnyObject]) = {
                switch self {
                case .PreselectedResults(let offset, let limit, let category):
                    let params = [
                        "pid": Router.APIKey,
                        "cat": category,
                        "offset": "\(offset)",
                        "limit": "\(limit)"
                    ]
                    return ("/products", params)
                    
                case .PopularResults (let offset, let limit, let category):
                    let params = [
                        "pid": Router.APIKey,
                        "cat": category,
                        "offset": "\(offset)",
                        "limit": "\(limit)",
                        "fl": "d100",
                        "sort": "Popular"
                    ]
                    return ("/products", params)
                    
                case .Categories (let category):
                    let params = [
                        "pid": Router.APIKey,
                        "cat": category
                    ]
                    return ("/categories", params)
                    
                case .FilteredResults (let offset, let limit, let category, let sort):
                    var params = [
                        "pid": Router.APIKey,
                        "cat": category,
                        "offset": "\(offset)",
                        "limit": "\(limit)"
                    ]
                    
                    if let sort = sort {
                        params["sort"] = "\(sort)"
                    }
                    
                    return ("/products", params)
                    
                case .Product(let id):
                    let params = [
                        "pid": Router.APIKey
                    ]
                    return ("/products/\(id)", params)
                }
            }()
            
            let URL = NSURL(string: Router.baseURLString)
            let URLRequest = NSURLRequest(URL: URL!.URLByAppendingPathComponent(result.path))
            let encoding = Alamofire.ParameterEncoding.URL
            
            return encoding.encode(URLRequest, parameters: result.parameters).0
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