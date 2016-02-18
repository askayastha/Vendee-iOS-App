//
//  Filter.swift
//  Vendee
//
//  Created by Ashish Kayastha on 12/10/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import Foundation

class Filter {
    
    var productCategory: String?
    var category: [String: AnyObject] = [
        "categorySearch": CategorySearch(),
        "displayCategories": [String](),
        "tappedCategories": [String](),
        "categoriesIdDict": [String: String]()
    ]
    var filterParams: [String: AnyObject] = [
        "brand": [String: String](),
        "store": [String: String](),
        "price": [String: String](),
        "discount": [String: String](),
        "offer": [String: String](),
        "color": [String: String]()
    ]
    var sort = [String: String]()
    
    func resetFilters() {
        print("FILTERS CLEARED !!!")
        category = [
            "categorySearch": CategorySearch(),
            "displayCategories": [String](),
            "tappedCategories": [String](),
            "categoriesIdDict": [String: String]()
        ]
        filterParams = [
            "brand": [String: String](),
            "store": [String: String](),
            "price": [String: String](),
            "discount": [String: String](),
            "offer": [String: String](),
            "color": [String: String]()
        ]
        sort.removeAll()
    }
}