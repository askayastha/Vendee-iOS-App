//
//  SearchFiltersModel.swift
//  Vendee
//
//  Created by Ashish Kayastha on 6/9/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

private let filtersModelSingleton = SearchFiltersModel()
private let filtersModelCopySingleton = SearchFiltersModel()

class SearchFiltersModel: FiltersModel {
    
    override class func sharedInstance() -> SearchFiltersModel {
        return filtersModelSingleton
    }
    
    override class func sharedInstanceCopy() -> SearchFiltersModel {
        return filtersModelCopySingleton
    }
    
    override class func synchronizeFiltersModel() {
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
    
    override class func revertFiltersModel() {
        filtersModelCopySingleton.filtersAvailable = filtersModelSingleton.filtersAvailable
        filtersModelCopySingleton.filtersApplied = filtersModelSingleton.filtersApplied
        filtersModelCopySingleton.productCategory = filtersModelSingleton.productCategory
        filtersModelCopySingleton.category = filtersModelSingleton.category
        filtersModelCopySingleton.categories = filtersModelSingleton.categories.mutableCopy() as! NSMutableOrderedSet
        filtersModelCopySingleton.filterParams = filtersModelSingleton.filterParams
        filtersModelCopySingleton.sort = filtersModelSingleton.sort
    }
}