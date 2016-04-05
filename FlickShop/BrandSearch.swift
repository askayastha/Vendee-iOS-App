//
//  BrandSearch.swift
//  Vendee
//
//  Created by Ashish Kayastha on 4/4/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class BrandSearch {
    
    enum State {
        case Idle
        case Loading
        case Success
        case Failed
    }
    
    private(set) var dataRequest: Alamofire.Request?
    private(set) var state: State = .Idle
    private(set) var brands: [String: [NSDictionary]]
    private(set) var retryCount = 0
    
    var lastItem: Int {
        return brands.count
    }
    
    deinit {
        print("BRAND SEARCH DEALLOCATING !!!!!")
        dataRequest?.cancel()
    }
    
    init() {
        brands = [String: [NSDictionary]]()
    }
    
    init(brands: [String: [NSDictionary]]) {
        self.brands = brands
    }
    
    func incrementRetryCount() {
        retryCount += 1
    }
    
    func resetRetryCount() {
        retryCount = 0
    }
    
    func requestShopStyleBrands(completion: SearchComplete) {
        if state == .Loading { // Do not request more data if a request is in process.
            return
        }
        
        if let _ = ShopStyleBrandsModel.sharedInstance().brands {
            brands = ShopStyleBrandsModel.sharedInstance().brands
            completion(true, "Brands loaded from cache.", self.lastItem)
            return
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        state = .Loading
        
        dataRequest = Alamofire.request(ShopStyle.Router.Brands).validate().responseJSON() {
            response in
            
            if response.result.isSuccess {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    print("----------Got results!----------")
                    
                    let jsonData = JSON(response.result.value!)
                    self.populateBrands(data: jsonData)
                    
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
    
    private func populateBrands(data data: JSON) {
        guard let brandsArray = data["brands"].array else { return }
        let alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters.map { String($0) }
        
        var brandsList = brandsArray.map {
            [
                "id": $0["id"].stringValue,
                "name": $0["name"].stringValue
            ]
        }
        brandsList.sortInPlace { $0["name"]?.lowercaseString < $1["name"]?.lowercaseString }
        brandsList.forEach {
            var key = String($0["name"]!.characters.first!).uppercaseString
            
            if !alphabets.contains(key) {
                key = "#"
            }
            
            if !brands.keys.contains(key) {
                brands[key] = [$0]
            } else {
                brands[key]?.append($0)
            }
        }
        
        ShopStyleBrandsModel.sharedInstance().brands = brands
        ShopStyleBrandsModel.sharedInstance().saveBrands()
    }
}
