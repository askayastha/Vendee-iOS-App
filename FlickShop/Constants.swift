//
//  Constants.swift
//  Vendee
//
//  Created by Ashish Kayastha on 12/5/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import Foundation
import UIKit

struct Files {
    static let TSDesignFileName = "TSMessagesCustomDesign.json"
}

struct App {
    static let storeId = "1092199423"
    static let storeURL = "https://itunes.apple.com/us/app/vendee-find-out-all-thats/id1092199423?ls=1&mt=8"
}

struct CKRecordTypes {
    static let PreselectedFilter = "PreselectedFilter"
}

struct CustomNotifications {
    static let FilterDidChangeNotification = "FilterDidChange"
    static let FilterDidClearNotification = "FilterDidClear"
    static let FilterDidApplyNotification = "FilterDidApply"
    static let FavoritesModelDidChangeNotification = "FavoritesModelDidChange"
    static let NetworkDidChangeToReachableNotification = "NetworkDidChangeToReachable"
    static let PhotosDidTapNotification = "PhotosDidTapNotification"
    
    static func filterDidChangeNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(FilterDidChangeNotification, object: nil)
    }
    
    static func filterDidClearNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(FilterDidClearNotification, object: nil)
    }
    
    static func filterDidApplyNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(FilterDidApplyNotification, object: nil)
    }
    
    static func favoritesModelDidChangeNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(FavoritesModelDidChangeNotification, object: nil)
    }
    
    static func networkDidChangeToReachableNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(NetworkDidChangeToReachableNotification, object: nil)
    }
    
    static func photosDidTapNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(PhotosDidTapNotification, object: nil)
    }
}

struct GoogleAnalytics {
    static func trackScreenForName(name: String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    static func trackEventWithCategory(category: String!, action: String!, label: String!, value: NSNumber!) {
        let tracker = GAI.sharedInstance().defaultTracker
        let event = GAIDictionaryBuilder.createEventWithCategory(category, action: action, label: label, value: value)
        tracker.send(event.build() as [NSObject : AnyObject])
    }
}

struct NumericConstants {
    static let requestLimit = 10
    static let retryLimit = 5
    static let populateLimit = 2
}

struct ScreenConstants {
    static let width = UIScreen.mainScreen().bounds.width
    static let height = UIScreen.mainScreen().bounds.height
}