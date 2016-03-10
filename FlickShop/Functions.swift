//
//  Functions.swift
//  Vendee
//
//  Created by Ashish Kayastha on 9/1/15.
//  Copyright (c) 2015 Ashish Kayastha. All rights reserved.
//

import Foundation
import UIKit
import Dispatch
import SwiftyJSON
import Crashlytics

func afterDelay(seconds: Double, closure: () -> ()) {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue(), closure)
}

func fixFrame(var frame: CGRect) -> CGRect {
    let headerView: CGFloat = 60.0
    let imageViewGap: CGFloat = 20.0
    let actionView: CGFloat = 52.2
    if frame.size.width > ScreenConstants.width {
        frame.size.width = ScreenConstants.width
        frame.size.height = ScreenConstants.height - headerView - imageViewGap - actionView
    }
    return frame
}

func getCategoryForProduct(product: Product) -> String? {
    guard let categories = product.categories else { return nil }
    
    let categoryIds = JSON(categories).arrayValue.map { $0["name"].stringValue }
    return categoryIds.first
}

func getBrandForProduct(product: Product) -> String? {
    guard let brand = product.brand else { return nil }
    
    return JSON(brand)["name"].string
}

func getRetailerForProduct(product: Product) -> String? {
    guard let retailer = product.retailer else { return nil }
    
    return JSON(retailer)["name"].string
}

func getDiscountForProduct(product: Product) -> Int? {
    guard let salePrice = product.salePrice else { return nil }
    let discount = (product.price - salePrice) * 100 / product.price
    
    return Int(discount)
}

func getAttributesForProduct(product: Product) -> [String: AnyObject] {
    let attributes: [String: AnyObject] = [
        "Product ID": product.id,
        "Category": getCategoryForProduct(product) ?? "Unknown",
        "Brand": getBrandForProduct(product) ?? "Unknown",
        "Retailer": getRetailerForProduct(product) ?? "Unknown",
        "Discount": getDiscountForProduct(product) ?? 0
    ]
    
    return attributes
}

func logEventsForFilter() {
    Answers.logCustomEventWithName("Tapped Filter Button", customAttributes: ["Button": "Apply"])
    let filtersModel = FiltersModel.sharedInstance()
    
    // Log applied category filter
    let tappedCategories = filtersModel.category["tappedCategories"] as! [String]
    if let category = tappedCategories.last {
        Answers.logCustomEventWithName("Applied Filters", customAttributes: ["Category": category])
    }
    
    // Log other applied filters
    for (filter, params) in filtersModel.filterParams {
        for paramName in (params as! [String: String]).keys {
            Answers.logCustomEventWithName("Applied Filters", customAttributes: [filter.capitalizedString: paramName])
        }
    }
    
    // Log sort filter
    if let sort = filtersModel.sort.keys.first {
        Answers.logCustomEventWithName("Applied Filters", customAttributes: ["Sort": sort])
    }
}