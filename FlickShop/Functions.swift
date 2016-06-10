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
import FirebaseAnalytics

func afterDelay(seconds: Double, closure: () -> ()) {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue(), closure)
}

func fixFrame(frame: CGRect) -> CGRect {
    let headerView: CGFloat = 60
    let imageViewGap: CGFloat = 20
    let actionView: CGFloat = 52
    
    var fixedFrame = frame
    if frame.size.width > ScreenConstants.width {
        fixedFrame.size.width = ScreenConstants.width
        fixedFrame.size.height = ScreenConstants.height - headerView - imageViewGap - actionView
    }
    return fixedFrame
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
    GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped Filter Action Button", label: "Apply", value: nil)
    FIRAnalytics.logEventWithName("Tapped_Filter_Action_Button", parameters: ["Button": "Apply"])
    Answers.logCustomEventWithName("Tapped Filter Action Button", customAttributes: ["Button": "Apply"])
    let filtersModel = (App.selectedTab == .Search) ? SearchFiltersModel.sharedInstance() : FiltersModel.sharedInstance()
    
    // Log applied category filter
    let tappedCategories = filtersModel.category["tappedCategories"] as! [String]
    if let category = tappedCategories.last {
        FIRAnalytics.logEventWithName("Applied_Filters", parameters: ["Category": category])
        Answers.logCustomEventWithName("Applied Filters", customAttributes: ["Category": category])
    }
    
    // Log other applied filters
    for (filter, params) in filtersModel.filterParams {
        for paramName in (params as! [String: String]).keys {
            FIRAnalytics.logEventWithName("Applied_Filters", parameters: [filter.capitalizedString: paramName])
            Answers.logCustomEventWithName("Applied Filters", customAttributes: [filter.capitalizedString: paramName])
        }
    }
    
    // Log sort filter
    if let sort = filtersModel.sort.keys.first {
        FIRAnalytics.logEventWithName("Applied_Filters", parameters: ["Sort": sort])
        Answers.logCustomEventWithName("Applied Filters", customAttributes: ["Sort": sort])
    }
}

func getAppVersionBuild() -> String {
    let dictionary = NSBundle.mainBundle().infoDictionary!
    let version = dictionary["CFBundleShortVersionString"] as! String
    let build = dictionary["CFBundleVersion"] as! String
    
    return "\(version) (\(build))"
}

func getAppVersion() -> String {
    let dictionary = NSBundle.mainBundle().infoDictionary!
    let version = dictionary["CFBundleShortVersionString"] as! String
    
    return "\(version)"
}