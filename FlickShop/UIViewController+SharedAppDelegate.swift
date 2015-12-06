//
//  UIViewController+SharedAppDelegate.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 11/26/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var appDelegate: AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func filterDidChangeNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(CustomNotifications.FilterDidChangeNotification, object: nil)
    }
    
    func filterDidClearNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(CustomNotifications.FilterDidClearNotification, object: nil)
    }
}