//
//  AppDelegate.swift
//  AmazonProduct
//
//  Created by Ashish Kayastha on 8/23/15.
//  Copyright (c) 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let filter = Filter()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        customizeAppearance()
        window!.layer.cornerRadius = 5.0
        window!.layer.masksToBounds = true
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            let productURL = userActivity.webpageURL!
            
            if !presentURL(productURL) {
                let alert = UIAlertController(title: "Error", message: "Product not found.", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(okAction)
                
                window!.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        return true
    }
    
    private func presentURL(url: NSURL) -> Bool {
        if let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true), let host = components.host, let path = components.path {
            switch host {
                case "www.vendeeapp.com":
                    switch path {
                    case "/product":
                        if let productId = findProductId(components) {
                            print("Product Id: \(productId)")
                            requestDataForProductId(productId, forSearch: Search())
                            
                            return true
                        }
                    default:
                        return false
                }
            default:
                return false
            }
        }
        return false
    }
    
    private func findProductId(components: NSURLComponents) -> String? {
        if let fragmentString = components.fragment {
            return fragmentString
        } else if let queryItems = components.queryItems {
            for item in queryItems {
                if item.name == "id" {
                    if let valueString = item.value {
                        return valueString
                    }
                }
            }
        }
        
        return nil
    }
    
    private func requestDataForProductId(productId: String, forSearch search: Search) {
        
        search.parseShopStyleForProductId(productId) { success, _ in
            if !success {
                if search.retryCount < NumericConstants.retryLimit {
                    print("Request Failed. Trying again...")
                    self.requestDataForProductId(productId, forSearch: search)
                    print("Request Count: \(search.retryCount)")
                    search.incrementRetryCount()
                    
                } else {
                    search.resetRetryCount()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
                
            } else {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let flickVC = storyboard.instantiateViewControllerWithIdentifier("ContainerFlickViewController") as? ContainerFlickViewController
                
                if let controller = flickVC {
                    controller.moreRequests = false
                    controller.search = search
                    controller.brands = Brand.allBrands()
                    let navigationController = self.window!.rootViewController as! UINavigationController
                    
                    if navigationController.topViewController is ContainerFlickViewController {
                        navigationController.popToRootViewControllerAnimated(true)
                    }
                    navigationController.pushViewController(controller, animated: true)
                }
            }
        }
    }

    private func customizeAppearance() {
//        let barTintColor = UIColor(red: 223/255, green: 223/255, blue: 223/255, alpha: 1)  // Translucent Gray
        
//        UINavigationBar.appearance().barTintColor = barTintColor
//        UINavigationBar.appearance().titleTextAttributes = [
//            NSForegroundColorAttributeName: UIColor.whiteColor(),
//            NSFontAttributeName: UIFont(name: "ProximaNova-Semibold", size: 16.0)!
//        ]
//        UINavigationBar.appearance().translucent = false
    }

}

