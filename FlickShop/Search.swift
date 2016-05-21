//
//  Search.swift
//  Vendee
//
//  Created by Ashish Kayastha on 9/7/15.
//  Copyright (c) 2015 Ashish Kayastha. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias SearchComplete = (Bool, String, Int) -> Void

class Search {
    
    enum State {
        case Idle
        case Loading
        case Success
        case Failed
    }
    
    let filtersModel = FiltersModel.sharedInstance()
    
    private(set) var dataRequest: Alamofire.Request?
    private(set) var state: State = .Idle
    private(set) var products: NSMutableOrderedSet
    private(set) var retryCount = 0
    private(set) var totalItems = 0
    
    var lastItem: Int {
        return products.count
    }
    
    deinit {
        print("SEARCH DEALLOCATING !!!!!")
        dataRequest?.cancel()
    }
    
    init() {
        products = NSMutableOrderedSet()
    }
    
    init(products: NSMutableOrderedSet) {
        self.products = products
    }
    
    func resetSearch() {
        dataRequest?.cancel()
        state = .Idle
        products.removeAllObjects()
        retryCount = 0
        totalItems = 0
    }
    
    func incrementRetryCount() {
        retryCount += 1
    }
    
    func resetRetryCount() {
        retryCount = 0
    }
    
    func requestShopStyleProductId(productId: String, completion: SearchComplete) {
        if state == .Loading { return }     // Do not request more data if a request is in process.
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        state = .Loading
        
        dataRequest = Alamofire.request(ShopStyle.Router.Product(productId)).validate().responseJSON() { response in
            if response.result.isSuccess {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    print("----------Request successful----------")
                    let jsonData = JSON(response.result.value!)
                    self.products.addObject(Product(data: jsonData))
                    self.state = .Success
                    
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
    
    func requestShopStyleForItemOffset(itemOffset: Int, withLimit limit: Int, forCategory category: String, completion: SearchComplete) {
        if state == .Loading { return }     // Do not request more data if a request is in process.
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        state = .Loading
        
        if filtersModel.filtersApplied {
            // Get category code for filter
            var filterCategory = category
            if let cat = getFilterCategory() { filterCategory = cat }
            
            // Get sort code for filter
            let sort = filtersModel.sort.count > 0 ? filtersModel.sort.values.first : nil
            
            // New request URL for filter
            var requestURL = ShopStyle.Router.FilteredResults(itemOffset, limit, filterCategory, sort).URLRequest.URLString
            requestURL.appendContentsOf(getFilterParams())
            
            print("----- Request 1 -----")
            print(requestURL)
            
            dataRequest = Alamofire.request(.GET, requestURL).validate().responseJSON() { response in
                self.handleResponse(response, withCompletion: completion)
            }
            
        } else {
            if let filterParams = PreselectedFiltersModel.sharedInstance().getFilterParamsForCategory(category) {
                var filterCategory = category
                if filterParams.containsString("cat=") { filterCategory = "" }
                
                var requestURL = ShopStyle.Router.PreselectedResults(itemOffset, limit, filterCategory).URLRequest.URLString
                
                requestURL.appendContentsOf("&\(filterParams)")
                print("----- Request 2 -----")
                print(requestURL)
                
                dataRequest = Alamofire.request(.GET, requestURL).validate().responseJSON() { response in
                    self.handleResponse(response, withCompletion: completion)
                }
                
            } else {
                let requestURL = ShopStyle.Router.PopularResults(itemOffset, limit, category).URLRequest.URLString
                print("----- Request 3 -----")
                print(requestURL)
                
                dataRequest = Alamofire.request(ShopStyle.Router.PopularResults(itemOffset, limit, category)).validate().responseJSON() { response in
                    self.handleResponse(response, withCompletion: completion)
                }
            }
        }
    }
    
    func similarRequestShopStyleForItemOffset(itemOffset: Int, withLimit limit: Int, forCategory category: String, completion: SearchComplete) {
        if state == .Loading { return }     // Do not request more data if a request is in process.
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        state = .Loading
        
        let requestURL = ShopStyle.Router.PopularResults(itemOffset, limit, category).URLRequest.URLString
        print("----- Request 4 -----")
        print(requestURL)
        
        dataRequest = Alamofire.request(ShopStyle.Router.PopularResults(itemOffset, limit, category)).validate().responseJSON() { response in
            self.handleResponse(response, withCompletion: completion)
        }
    }
    
    func getFilterCategory() -> String? {
        let tappedCategories = filtersModel.category["tappedCategories"] as! [String]
        let categoriesIdDict = filtersModel.category["categoriesIdDict"] as! [String: String]
        var categoryId: String?
        
        if let category = tappedCategories.last {
            categoryId = categoriesIdDict[category]
        }
        
        return categoryId
    }
    
    func getFilterParams() -> String {
        var filterParams = [String]()
        
        [AnyObject](filtersModel.filterParams.values).forEach {
            let filters = $0 as! [String: String]
            [String](filters.values).forEach {
                filterParams.append("fl=\($0)")
            }
        }
        
        return "&\(filterParams.joinWithSeparator("&"))"
    }
    
    private func populateProducts(data data: JSON) {
        if let productsArray = data["products"].array {
            products.addObjectsFromArray(productsArray.map { Product(data: $0) })
        }
    }
    
    private func handleResponse(response: Response<AnyObject, NSError>, withCompletion completion: SearchComplete) {
        guard response.result.isSuccess else {
            print("Error while requesting data: \(response.result.error)")
            self.state = .Failed
            completion(false, response.result.error!.localizedDescription, self.lastItem)
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            print("----------Request successful----------")
            let jsonData = JSON(response.result.value!)
            
            self.totalItems = jsonData["metadata"]["total"].intValue
            print("Total Items: \(self.totalItems)")
            
            self.populateProducts(data: jsonData)
            self.state = .Success
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(true, response.result.description, self.lastItem)
            }
        }
    }
}
