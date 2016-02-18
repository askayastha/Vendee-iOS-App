//
//  Constants.swift
//  Vendee
//
//  Created by Ashish Kayastha on 12/5/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import Foundation
import UIKit

struct CustomNotifications {
    static let FilterDidChangeNotification = "FilterDidChange"
    static let FilterDidClearNotification = "FilterDidClear"
    static let DataModelDidChangeNotification = "DataModelDidChange"
    static let NetworkDidChangeToReachableNotification = "NetworkDidChangeToReachable"
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