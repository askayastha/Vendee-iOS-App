//
//  AppDelegate.swift
//  Vendee
//
//  Created by Ashish Kayastha on 8/23/15.
//  Copyright (c) 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Alamofire
import TSMessages

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let filter = Filter()
    let networkManager = NetworkReachabilityManager(host: "api.shopstyle.com")

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window!.layer.cornerRadius = 5.0
        window!.layer.masksToBounds = true
        TSMessage.setDelegate(self)
        customizeNavBar()
        customizeTabBar()
        
        PreselectedFiltersModel.sharedInstance().loadPreselectedFilters()
        
        networkManager?.listener = { status in
            print("Network Status Changed: \(status)")
            
            switch status {
            case .NotReachable:
                TSMessage.addCustomDesignFromFileWithName(Files.TSDesignFileName)
                TSMessage.showNotificationWithTitle("Network Error", subtitle: "Check your internet connection and try again later.", type: .Error)
                
            case .Reachable(_):
                TSMessage.addCustomDesignFromFileWithName(Files.TSDesignFileName)
                TSMessage.showNotificationWithTitle("Network Reachable", subtitle: "Network is reachable. Post reachability notification.", type: .Success)
                NSNotificationCenter.defaultCenter().postNotificationName(CustomNotifications.NetworkDidChangeToReachableNotification, object: nil)
                
            default:
                break
            }
        }
        networkManager?.startListening()
        
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
                TSMessage.addCustomDesignFromFileWithName(Files.TSDesignFileName)
                TSMessage.showNotificationWithTitle("Error", subtitle: "URL not valid.", type: .Warning)
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
        
        search.parseShopStyleForProductId(productId) { success, description, _ in
            if !success {
                if search.retryCount < NumericConstants.retryLimit {
                    print("Request Failed. Trying again...")
                    self.requestDataForProductId(productId, forSearch: search)
                    print("Request Count: \(search.retryCount)")
                    search.incrementRetryCount()
                    
                } else {
                    search.resetRetryCount()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    TSMessage.addCustomDesignFromFileWithName(Files.TSDesignFileName)
                    TSMessage.showNotificationWithTitle("Network Error", subtitle: description, type: .Error)
                }
                
            } else {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let flickVC = storyboard.instantiateViewControllerWithIdentifier("ContainerFlickViewController") as? ContainerFlickViewController
                
                if let controller = flickVC {
                    controller.search = search
                    controller.hidesBottomBarWhenPushed = true
                    let tabBarController = self.window!.rootViewController as! UITabBarController
                    
                    if let tabBarControllers = tabBarController.viewControllers, let navigationController = tabBarControllers[0] as? UINavigationController {
                        
                        if navigationController.topViewController is ContainerFlickViewController {
                            navigationController.popToRootViewControllerAnimated(true)
                        }
                        navigationController.pushViewController(controller, animated: true)
                    }
                }
            }
        }
    }
    
    private func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = window!.rootViewController!
        
        if let presentedViewControler = rootViewController.presentedViewController {
            return presentedViewControler
        }
        return rootViewController
    }

    private func customizeTabBar() {
        let tabBarController = window!.rootViewController as! UITabBarController
        
        if let tabBarControllers = tabBarController.viewControllers {
            var navigationController = tabBarControllers[0] as! UINavigationController
            navigationController.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
            
            navigationController = tabBarControllers[1] as! UINavigationController
            navigationController.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
            
            navigationController = tabBarControllers[2] as! UINavigationController
            navigationController.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        }
    }
    
    private func customizeNavBar() {
        let navAppearance = UINavigationBar.appearance()
        
        let backImage = UIImage(named: "nav_back_arrow")
        navAppearance.backIndicatorImage = backImage
        navAppearance.backIndicatorTransitionMaskImage = backImage
        navAppearance.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "FaktFlipboard-Medium", size: 16.0)!
        ]
        navAppearance.tintColor = UIColor.blackColor()
        
        let barButtonAppearance = UIBarButtonItem.appearance()
        barButtonAppearance.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics: .Default)
        barButtonAppearance.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics: .Compact)
    }

}

extension AppDelegate: TSMessageViewProtocol {
    
    func customizeMessageView(messageView: TSMessageView!) {
        messageView.alpha = 0.8
    }
}