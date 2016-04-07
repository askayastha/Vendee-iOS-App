//
//  ColorSearch.swift
//  Vendee
//
//  Created by Ashish Kayastha on 4/4/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ColorSearch {
    
    enum State {
        case Idle
        case Loading
        case Success
        case Failed
    }
    
    private(set) var dataRequest: Alamofire.Request?
    private(set) var state: State = .Idle
    private(set) var colors: NSMutableOrderedSet
    private(set) var retryCount = 0
    
    var lastItem: Int {
        return colors.count
    }
    
    deinit {
        print("COLOR SEARCH DEALLOCATING !!!!!")
        dataRequest?.cancel()
    }
    
    init() {
        colors = NSMutableOrderedSet()
    }
    
    init(colors: NSMutableOrderedSet) {
        self.colors = colors
    }
    
    func incrementRetryCount() {
        retryCount += 1
    }
    
    func resetRetryCount() {
        retryCount = 0
    }
    
    func requestShopStyleColors(completion: SearchComplete) {
        if state == .Loading { return }     // Do not request more data if a request is in process.
        
        if let _ = ShopStyleColorsModel.sharedInstance().colors {
            colors = ShopStyleColorsModel.sharedInstance().colors
            completion(true, "Colors loaded from cache.", self.lastItem)
            return
        }
        
        state = .Loading
        
        dataRequest = Alamofire.request(ShopStyle.Router.Colors).validate().responseJSON() {
            response in
            
            if response.result.isSuccess {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    print("----------Got results!----------")
                    
                    let jsonData = JSON(response.result.value!)
                    self.populateColors(data: jsonData)
                    
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
    
    private func populateColors(data data: JSON) {
        if let colorsArray = data["colors"].array {
            colors.addObjectsFromArray(colorsArray.map { Color(data: $0) })
        }
        
        ShopStyleColorsModel.sharedInstance().colors = colors
        ShopStyleColorsModel.sharedInstance().saveColors()
    }
}

class Color: NSObject, NSCoding {
    var id: String!
    var name: String!
    
    init(data: JSON) {
        // ShopStyle Properties
        self.id = data["id"].string
        self.name = data["name"].string
    }
    
    required init?(coder aDecoder: NSCoder) {
        // ShopStyle Properties
        id = aDecoder.decodeObjectForKey("Id") as? String
        name = aDecoder.decodeObjectForKey("Name") as? String
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        // ShopStyle Properties
        aCoder.encodeObject(id, forKey: "Id")
        aCoder.encodeObject(name, forKey: "Name")
    }
}
