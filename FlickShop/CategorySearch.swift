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
        
        Alamofire.request(ShopStyle.Router.Categories(category)).validate().responseJSON() {
            response in
            
            if response.result.isSuccess {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    print("----------Got results!----------")
                    
                    let jsonData = JSON(response.result.value!)
                    self.populateCategories(data: jsonData)
                    
                    self.state = .Success
                    print("Request successful")
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(true, response.result.description, self.lastItem)
                    }
                }
                
            } else {
                self.state = .Failed
                completion(false, response.result.error!.localizedDescription, self.lastItem)
            }
        }
    }
    
    private func populateCategories(data data: JSON) {
        categories.addObject(CategoryInfo(data: data["metadata"]["root"]))
        
        if let categoriesArray = data["categories"].array {
            categories.addObjectsFromArray(categoriesArray.map { CategoryInfo(data: $0) })
        }
        
    }
}

