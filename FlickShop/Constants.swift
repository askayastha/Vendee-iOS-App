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

struct CKRecordTypes {
    static let PreselectedFilter = "PreselectedFilter"
}

struct CustomNotifications {
    static let FilterDidChangeNotification = "FilterDidChange"
    static let FilterDidClearNotification = "FilterDidClear"
    static let FavoritesModelDidChangeNotification = "FavoritesModelDidChange"
    static let NetworkDidChangeToReachableNotification = "NetworkDidChangeToReachable"
    
    static func filterDidChangeNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(CustomNotifications.FilterDidChangeNotification, object: nil)
    }
    
    static func filterDidClearNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(CustomNotifications.FilterDidClearNotification, object: nil)
    }
    
    static func favoritesModelDidChangeNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(CustomNotifications.FavoritesModelDidChangeNotification, object: nil)
    }
    
    static func networkDidChangeToReachableNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(CustomNotifications.NetworkDidChangeToReachableNotification, object: nil)
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