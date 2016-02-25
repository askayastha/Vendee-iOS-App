//
//  BrandsModel.swift
//  Vendee
//
//  Created by Ashish Kayastha on 2/25/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import Foundation

class BrandsModel {
    
    class func sharedInstance() -> BrandsModel {
        return modelSingletonGlobal
    }
    
    var brands: [Brand] = Brand.allBrands()
}

let modelSingletonGlobal = BrandsModel()


class Brand {
    
    class func allBrands() -> [Brand] {
        var brands = [Brand]()
        if let URL = NSBundle.mainBundle().URLForResource("Brands", withExtension: "plist") {
            if let brandsFromPlist = NSArray(contentsOfURL: URL) {
                for dictionary in brandsFromPlist {
                    let brand = Brand(dictionary: dictionary as! NSDictionary)
                    brands.append(brand)
                }
            }
        }
        return brands
    }
    
    var name: String
    var nickname: String
    var picURL: String
    
    init(name: String, nickname: String, picURL: String) {
        self.name = name
        self.nickname = nickname
        self.picURL = picURL
    }
    
    convenience init(dictionary: NSDictionary) {
        let name = dictionary["name"] as? String
        let nickname = dictionary["nickname"] as? String
        let picURL = dictionary["picURL"] as? String
        self.init(name: name!, nickname: nickname!, picURL: picURL!)
    }
    
}