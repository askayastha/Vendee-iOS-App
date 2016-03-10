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
    @IBOutlet weak var applyButton: UIBarButtonItem!
    
    var containerVC: ContainerViewController?
    let filtersModel = FiltersModel.sharedInstanceCopy()
    
    deinit {
        print("ContainerFilterViewController Deallocating !!!")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.FilterDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.FilterDidClearNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBar.barTintColor = UIColor(hexString: "#E7E7E7")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshView", name: CustomNotifications.FilterDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "clearView", name: CustomNotifications.FilterDidClearNotification, object: nil)
        
        // Log custom events
        GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped Filter Button", label: "Open", value: nil)
        Answers.logCustomEventWithName("Tapped Filter Button", customAttributes: ["Button": "Open"])
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if filtersModel.filtersApplied {
            clearAllButton.enabled = true
        }
        if filtersModel.filtersAvailable {
            applyButton.enabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done() {
        // Log custom events
        GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped Filter Button", label: "Close", value: nil)
        Answers.logCustomEventWithName("Tapped Filter Button", customAttributes: ["Button": "Close"])
        
        if filtersModel.filtersAvailable {
            let alert = UIAlertController(title: "Vendee", message: "Are you sure you want to close without applying your filters?", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default) { _ in
                FiltersModel.revertFiltersModel()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
            
        } else {
            FiltersModel.revertFiltersModel()
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func reset() {
        filtersModel.resetFilters()
        
        // Refresh side tab
        CustomNotifications.filterDidChangeNotification()
        
        // Refresh any visible filter view controllers
        CustomNotifications.filterDidClearNotification()
        
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
    
    func refreshView() {
        filtersModel.filtersAvailable = true
        clearAllButton.enabled = true
        applyButton.enabled = true
    }
    
    func clearView() {
        filtersModel.filtersAvailable = false
        clearAllButton.enabled = false
        applyButton.enabled = true
    }

}
