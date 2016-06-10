//
//  Filter.swift
//  Vendee
//
//  Created by Ashish Kayastha on 12/10/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

private let filtersModelSingleton = FiltersModel()
private let filtersModelCopySingleton = FiltersModel()

class FiltersModel {
    
    class func sharedInstance() -> FiltersModel {
        return filtersModelSingleton
    }
    
    class func sharedInstanceCopy() -> FiltersModel {
        return filtersModelCopySingleton
    }
    
    class func synchronizeFiltersModel() {
        filtersModelCopySingleton.filtersApplied = filtersModelCopySingleton.filtersAvailable
        filtersModelCopySingleton.filtersAvailable = false
        
        filtersModelSingleton.filtersAvailable = filtersModelCopySingleton.filtersAvailable
        filtersModelSingleton.filtersApplied = filtersModelCopySingleton.filtersApplied
        filtersModelSingleton.productCategory = filtersModelCopySingleton.productCategory
        filtersModelSingleton.category = filtersModelCopySingleton.category
        filtersModelSingleton.categories = filtersModelCopySingleton.categories.mutableCopy() as! NSMutableOrderedSet
        filtersModelSingleton.filterParams = filtersModelCopySingleton.filterParams
        filtersModelSingleton.sort = filtersModelCopySingleton.sort
    }
    
    class func revertFiltersModel() {
        filtersModelCopySingleton.filtersAvailable = filtersModelSingleton.filtersAvailable
        filtersModelCopySingleton.filtersApplied = filtersModelSingleton.filtersApplied
        filtersModelCopySingleton.productCategory = filtersModelSingleton.productCategory
        filtersModelCopySingleton.category = filtersModelSingleton.category
        filtersModelCopySingleton.categories = filtersModelSingleton.categories.mutableCopy() as! NSMutableOrderedSet
        filtersModelCopySingleton.filterParams = filtersModelSingleton.filterParams
        filtersModelCopySingleton.sort = filtersModelSingleton.sort
    }
    
    var filtersAvailable: Bool
    var filtersApplied: Bool
    var productCategory: String?
    var category: [String: AnyObject]
    var categories: NSMutableOrderedSet
    var filterParams: [String: AnyObject]
    var sort: [String: String]
    
    init() {
        filtersAvailable = false
        filtersApplied = false
        category = [
            "displayCategories": [String](),
            "tappedCategories": [String](),
            "categoriesIdDict": [String: String]()
        ]
        categories = NSMutableOrderedSet()
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
        
        filtersAvailable = false
        filtersApplied = false
        category = [
            "displayCategories": [String](),
            "tappedCategories": [String](),
            "categoriesIdDict": [String: String]()
        ]
        categories = NSMutableOrderedSet()
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