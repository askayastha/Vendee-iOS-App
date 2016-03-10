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
    }
    
    func incrementRetryCount() {
        retryCount++
    }
    
    func resetRetryCount() {
        retryCount = 0
    }
    
    func parseShopStyleForProductId(productId: String, completion: SearchComplete) {
        if state == .Loading { return }     // Do not request more data if a request is in process.
        
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
    
    func parseShopStyleForItemOffset(itemOffset: Int, withLimit limit: Int, var forCategory category: String, completion: SearchComplete) {
        
        if state == .Loading { return }     // Do not request more data if a request is in process.
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        state = .Loading
        
        if filtersModel.filtersApplied {
            // Get category code for filter
            if let filterCategory = getFilterCategory() {
                category = filterCategory
            }
            
            // Get sort code for filter
            let sort = filtersModel.sort.count > 0 ? filtersModel.sort.values.first : nil
            
            // New request URL for filter
            var requestURL = ShopStyle.Router.FilteredResults(itemOffset, limit, category, sort).URLRequest.URLString
            requestURL.appendContentsOf(getFilterParams())
            
            print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
            print(requestURL)
            
            dataRequest = Alamofire.request(.GET, requestURL).validate().responseJSON() { response in
                self.handleResponse(response, withCompletion: completion)
            }
            
        } else {
            if let filterParams = PreselectedFiltersModel.sharedInstance().getFilterParamsForCategory(category) {
                var requestURL = ShopStyle.Router.PreselectedResults(itemOffset, limit, category).URLRequest.URLString
                
                requestURL.appendContentsOf("&" + filterParams)
                print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
                print(requestURL)
                
                dataRequest = Alamofire.request(.GET, requestURL).validate().responseJSON() { response in
                    self.handleResponse(response, withCompletion: completion)
                }
                
            } else {
                dataRequest = Alamofire.request(ShopStyle.Router.PopularResults(itemOffset, limit, category)).validate().responseJSON() { response in
                    self.handleResponse(response, withCompletion: completion)
                }
            }
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
        
        for filtersObj in [AnyObject](filtersModel.filterParams.values) {
            let filters = filtersObj as! [String: String]
            for code in [String](filters.values) {
                filterParams.append("fl=\(code)")
            }
        }
        
        let finalFilterParams = filterParams.joinWithSeparator("&")
        
        // finalFilterParams = initialfilterParams.substringFromIndex(initialfilterParams.startIndex.advancedBy(3))    ; print(finalFilterParams)
        return "&\(finalFilterParams)"
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
            self.populateProducts(data: jsonData)
            self.state = .Success
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(true, response.result.description, self.lastItem)
            }
        }
    }
}
