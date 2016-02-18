//
//  CategorySearch.swift
//  Vendee
//
//  Created by Ashish Kayastha on 11/26/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CategorySearch {
    
    enum State {
        case Idle
        case Loading
        case Success
        case Failed
    }
    
    private(set) var state: State = .Idle
    private(set) var categories = NSMutableOrderedSet()
    private(set) var retryCount = 0
    
    var lastItem: Int {
        return categories.count
    }
    
    deinit {
        print("CATEGORY SEARCH DEALLOCATING !!!!!")
    }
    
    init(categories: NSMutableOrderedSet) {
        self.categories = categories
    }
    
    init() {
        categories = NSMutableOrderedSet()
    }
    
    func incrementRetryCount() {
        retryCount++
    }
    
    func resetRetryCount() {
        retryCount = 0
    }
    
    func parseShopStyleForCategory(category: String, completion: SearchComplete) {
        if state == .Loading { // Do not request more data if a request is in process.
            return
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        state = .Loading
        var success = false
        
        Alamofire.request(ShopStyle.Router.Categories(category)).validate().responseJSON() {
            response in
            
            if response.result.isSuccess {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    print("----------Got results!----------")
                    
                    let jsonData = JSON(response.result.value!)
                    // print(jsonData)
                    
                    let metadataRoot = jsonData["metadata"]["root"]
                    
                    let categoryInfo = CategoryInfo()
                    categoryInfo.id = metadataRoot["id"].string
                    categoryInfo.name = metadataRoot["name"].string
                    categoryInfo.shortName = metadataRoot["shortName"].string
                    categoryInfo.fullName = metadataRoot["fullName"].string
                    categoryInfo.parentId = metadataRoot["parentId"].string
                    categoryInfo.hasSizeFilter = metadataRoot["hasSizeFilter"].bool
                    categoryInfo.hasColorFilter = metadataRoot["hasColorFilter"].bool
                    
                    self.categories.addObject(categoryInfo)
                    
                    if let categoriesArray = jsonData["categories"].array {
                        for item in categoriesArray {
                            
                            let categoryInfo = CategoryInfo()
                            categoryInfo.id = item["id"].string
                            categoryInfo.name = item["name"].string
                            categoryInfo.shortName = item["shortName"].string
                            categoryInfo.fullName = item["fullName"].string
                            categoryInfo.parentId = item["parentId"].string
                            categoryInfo.hasSizeFilter = item["hasSizeFilter"].bool
                            categoryInfo.hasColorFilter = item["hasColorFilter"].bool
                            
                            self.categories.addObject(categoryInfo)
                        }
                    }
                    
                    success = true
                    self.state = .Success
                    print("Request successful")
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(success, response.result.description, self.lastItem)
                    }
                }
                
            } else {
                self.state = .Failed
                completion(success, response.result.error!.localizedDescription, self.lastItem)
            }
        }
    }
}

class CategoryInfo: NSObject {
    
    var id: String?
    var name: String?
    var shortName: String?
    var fullName: String?
    var parentId: String?
    var hasSizeFilter: Bool?
    var hasColorFilter: Bool?
}
