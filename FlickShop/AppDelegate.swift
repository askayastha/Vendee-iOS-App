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
import Fabric
import Crashlytics
import iRate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let networkManager = NetworkReachabilityManager(host: "api.shopstyle.com")
    
    override class func initialize() -> Void {
//        iRate.sharedInstance().previewMode = true
        iRate.sharedInstance().messageTitle = "Vendee Feedback"
        iRate.sharedInstance().message = "Love the app? Give us 5 stars!"
        iRate.sharedInstance().rateButtonLabel = "Sure! ⭐️⭐️⭐️⭐️⭐️"
        iRate.sharedInstance().remindButtonLabel = "Remind me later"
        iRate.sharedInstance().cancelButtonLabel = "No thanks"
        iRate.sharedInstance().daysUntilPrompt = 5
        iRate.sharedInstance().usesUntilPrompt = 5
        iRate.sharedInstance().remindPeriod = 1
        iRate.sharedInstance().useAllAvailableLanguages = false
        iRate.sharedInstance().promptForNewVersionIfUserRated = true
        iRate.sharedInstance().onlyPromptIfLatestVersion = true
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        TSMessage.setDelegate(self)
        customizeWindow()
        customizeNavBar()
        customizeTabBar()
        customizeSearchBar()
        customizeTableView()
        configureNetworkManager()
        configureGoogleAnalytics()
        configureFabric()
        PreselectedFiltersModel.sharedInstance().loadPreselectedFilters()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        ShopStyleBrandsModel.sharedInstance().removeBrands()
        ShopStyleStoresModel.sharedInstance().removeStores()
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
            case "vendeeapp.com":
                    switch path {
                    case "/item":
                        if let productId = findProductId(components) {
                            print("Product Id: \(productId)")
                            requestDataForProductId(productId, forSearch: Search())
                            
                            return true
                        }
                    
                    case "":
                        UIApplication.sharedApplication().openURL(url)
                        return true
                    
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
                    if let valueString = item.value { return valueString }
                }
            }
        }
        
        return nil
    }
    
    private func requestDataForProductId(productId: String, forSearch search: Search) {
        
        search.requestShopStyleProductId(productId) { success, description, _ in
            if !success {
                if search.retryCount < NumericConstants.retryLimit {
                    self.requestDataForProductId(productId, forSearch: search)
                    search.incrementRetryCount()
                    print("Request Failed. Trying again...")
                    print("Request Count: \(search.retryCount)")
                    
                } else {
                    search.resetRetryCount()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    TSMessage.addCustomDesignFromFileWithName(Files.TSDesignFileName)
                    TSMessage.showNotificationWithTitle("Network Error", subtitle: description, type: .Error)
                    
                    // Log custom events
                    GoogleAnalytics.trackEventWithCategory("Error", action: "Network Error", label: description, value: nil)
                    Answers.logCustomEventWithName("Network Error", customAttributes: ["Description": description])
                }
                
            } else {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let flickVC = storyboard.instantiateViewControllerWithIdentifier("ContainerFlickViewController") as? ContainerFlickViewController
                
                if let controller = flickVC {
                    controller.search = search
                    controller.hidesBottomBarWhenPushed = true
                    let tabBarController = self.window!.rootViewController as! UITabBarController
                    tabBarController.selectedIndex = 0
                    
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
    
    private func customizeWindow() {
        window!.layer.cornerRadius = 5.0
        window!.layer.masksToBounds = true
    }

    private func customizeTabBar() {
        let tabBarController = window!.rootViewController as! UITabBarController
        let tabBar = tabBarController.tabBar
        tabBar.backgroundImage = UIImage.imageWithColor(UIColor(hexString: "#F6F6F6")!, andSize: CGSizeMake(tabBar.bounds.size.width, tabBar.bounds.size.height))
        
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
        navAppearance.tintColor = UIColor(hexString: "#353535")
        navAppearance.backIndicatorImage = backImage
        navAppearance.backIndicatorTransitionMaskImage = backImage
        navAppearance.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "CircularSpUI-Bold", size: 16.0)!,
            NSForegroundColorAttributeName: UIColor(hexString: "#353535")!
        ]
        
        let barButtonAppearance = UIBarButtonItem.appearance()
        barButtonAppearance.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics: .Default)
        barButtonAppearance.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics: .Compact)
        
//        navAppearance.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
//        navAppearance.shadowImage = UIImage()
    }
    
    private func customizeSearchBar() {
        UISearchBar.appearance().tintColor = UIColor(hexString: "#353535")
        let normalTextAttributes: [String: AnyObject] = [
            NSFontAttributeName: UIFont(name: "CircularSPUI-Book", size: 14.0)!,
            NSForegroundColorAttributeName: UIColor(hexString: "#353535")!
        ]
        UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).setTitleTextAttributes(normalTextAttributes, forState: .Normal)
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).defaultTextAttributes = normalTextAttributes
    }
    
    private func customizeTableView() {
        let colorView = UIView()
        colorView.backgroundColor = UIColor(hexString: "#F5F5F5")
        
        UITableViewCell.appearance().selectedBackgroundView = colorView
    }
    
    private func configureNetworkManager() {
        networkManager?.listener = { status in
            print("Network Status Changed: \(status)")
            
            switch status {
            case .NotReachable:
                TSMessage.addCustomDesignFromFileWithName(Files.TSDesignFileName)
                TSMessage.showNotificationWithTitle("Network Error", subtitle: "Check your internet connection and try again later.", type: .Error)
                
            case .Reachable(_):
//                TSMessage.addCustomDesignFromFileWithName(Files.TSDesignFileName)
//                TSMessage.showNotificationWithTitle("Network Reachable", subtitle: "Network is reachable. Post reachability notification.", type: .Success)
                NSNotificationCenter.defaultCenter().postNotificationName(CustomNotifications.NetworkDidChangeToReachableNotification, object: nil)
                
            default:
                break
            }
        }
        networkManager?.startListening()
    }
    
    private func configureGoogleAnalytics() {
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true  // report uncaught exceptions
//        gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
    }
    
    private func configureFabric() {
        // Register Crashlytics and Answers with Fabric.
        Fabric.with([Crashlytics.self])
    }

}

extension AppDelegate: TSMessageViewProtocol {
    
    func customizeMessageView(messageView: TSMessageView!) {
        messageView.alpha = 0.8
    }
}

extension AppDelegate: iRateDelegate {
    
    func iRateDidPromptForRating() {
        // Log custom events
        GoogleAnalytics.trackScreenForName("Rate Prompt")
        Answers.logCustomEventWithName("Rate Prompt", customAttributes: nil)
    }
    
    func iRateUserDidAttemptToRateApp() {
        // Log custom events
        GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped Rate Action Button", label: "Sure!", value: nil)
        Answers.logCustomEventWithName("Tapped Rate Action Button", customAttributes: ["Button": "Sure!"])
    }
    
    func iRateUserDidDeclineToRateApp() {
        // Log custom events
        GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped Rate Action Button", label: "No thanks", value: nil)
        Answers.logCustomEventWithName("Tapped Rate Action Button", customAttributes: ["Button": "No thanks"])
    }
    
    func iRateUserDidRequestReminderToRateApp() {
        // Log custom events
        GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped Rate Action Button", label: "Remind me later", value: nil)
        Answers.logCustomEventWithName("Tapped Rate Action Button", customAttributes: ["Button": "Remind me later"])
    }
}
