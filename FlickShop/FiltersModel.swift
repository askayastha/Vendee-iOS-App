//
//  Filter.swift
//  Vendee
//
//  Created by Ashish Kayastha on 12/10/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

private let filtersModelSingleton = FiltersModel()

class FiltersModel {
    
    class func sharedInstance() -> FiltersModel {
        return filtersModelSingleton
    }
    
    var productCategory: String?
    var category: [String: AnyObject]
    var filterParams: [String: AnyObject]
    var sort: [String: String]
    
    private init() {
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
        
        sort = [String: String]()
    }
    
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