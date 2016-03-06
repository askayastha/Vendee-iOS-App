//
//  ContainerFilterViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 11/20/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics

class ContainerFilterViewController: UIViewController, SideTabDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var clearAllButton: UIBarButtonItem!
    
    var containerVC: ContainerViewController?
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.FilterDidChangeNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBar.barTintColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1.0)
        
        NSNotificationCenter.defaultCenter().addObserverForName(CustomNotifications.FilterDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            self.clearAllButton.enabled = true
            FiltersModel.sharedInstance().filtersAvailable = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done() {
        dismissViewControllerAnimated(true, completion: nil)
        
        // Log custom events
        GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped Filter Button", label: "Close", value: nil)
        Answers.logCustomEventWithName("Tapped Filter Button", customAttributes: ["Button": "Close"])
    }
    
    @IBAction func reset() {
        FiltersModel.sharedInstance().resetFilters()
        
        // Refresh side tab
        CustomNotifications.filterDidChangeNotification()
        
        // Refresh any visible filter view controllers
        CustomNotifications.filterDidClearNotification()
        
        clearAllButton.enabled = false
        FiltersModel.sharedInstance().filtersAvailable = false
        
        // Log custom events
        GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped Filter Button", label: "Clear All", value: nil)
        Answers.logCustomEventWithName("Tapped Filter Button", customAttributes: ["Button": "Clear All"])
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EmbedContainer" {
            containerVC = segue.destinationViewController as? ContainerViewController
        } else if segue.identifier == "EmbedSideTab" {
            let controller = segue.destinationViewController as! SideTabViewController
            controller.delegate = self
        }
    }
    
    func showTab(identifier: String) {
        containerVC?.switchViewControllerForIdentifier(identifier)
    }

}
