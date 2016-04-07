//
//  StoreSearch.swift
//  Vendee
//
//  Created by Ashish Kayastha on 4/4/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class StoreSearch {
    
    enum State {
        case Idle
        case Loading
        case Success
        case Failed
    }
    
    private(set) var dataRequest: Alamofire.Request?
    private(set) var state: State = .Idle
    private(set) var stores: [String: [NSDictionary]]
    private(set) var retryCount = 0
    
    var lastItem: Int {
        return stores.count
    }
    
    deinit {
        print("STORE SEARCH DEALLOCATING !!!!!")
        dataRequest?.cancel()
    }
    
    init() {
        stores = [String: [NSDictionary]]()
    }
    
    init(stores: [String: [NSDictionary]]) {
        self.stores = stores
    }
    
    func incrementRetryCount() {
        retryCount += 1
    }
    
    func resetRetryCount() {
        retryCount = 0
    }
    
    func requestShopStyleStores(completion: SearchComplete) {
        if state == .Loading { return }     // Do not request more data if a request is in process.
        
        if let _ = ShopStyleStoresModel.sharedInstance().stores {
            stores = ShopStyleStoresModel.sharedInstance().stores
            completion(true, "Stores loaded from cache.", self.lastItem)
            return
        }
        
        state = .Loading
        
        dataRequest = Alamofire.request(ShopStyle.Router.Stores).validate().responseJSON() {
            response in
            
            if response.result.isSuccess {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    print("----------Got results!----------")
                    
                    let jsonData = JSON(response.result.value!)
                    self.populateStores(data: jsonData)
                    
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
    
    private func populateStores(data data: JSON) {
        guard let storesArray = data["retailers"].array else { return }
        let alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters.map { String($0) }
        
        var storesList = storesArray.map {
            [
                "id": $0["id"].stringValue,
                "name": $0["name"].stringValue
            ]
        }
        storesList.sortInPlace { $0["name"]?.lowercaseString < $1["name"]?.lowercaseString }
        storesList.forEach {
            var key = String($0["name"]!.characters.first!).uppercaseString
            
            if !alphabets.contains(key) {
                key = "#"
            }
            
            if !stores.keys.contains(key) {
                stores[key] = [$0]
            } else {
                stores[key]?.append($0)
            }
        }
        
        ShopStyleStoresModel.sharedInstance().stores = stores
        ShopStyleStoresModel.sharedInstance().saveStores()
    }
}
