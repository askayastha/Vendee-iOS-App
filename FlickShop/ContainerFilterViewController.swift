//
//  ContainerFilterViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 11/20/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics
import FirebaseAnalytics

class ContainerFilterViewController: UIViewController, SideTabDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var clearAllButton: UIBarButtonItem!
    @IBOutlet weak var applyButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var containerVC: ContainerViewController?
    let filtersModel: FiltersModel
    
    deinit {
        print("ContainerFilterViewController Deallocating !!!")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.FilterDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.FilterDidClearNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        filtersModel = (App.selectedTab == .Search) ? SearchFiltersModel.sharedInstanceCopy() : FiltersModel.sharedInstanceCopy()
        
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        navigationBar.barTintColor = UIColor(hexString: "#E7E7E7")
        view.backgroundColor = UIColor(hexString: "#F8F8F8")
        navigationBar.barTintColor = UIColor(hexString: "#F8F8F8")
        toolBar.barTintColor = UIColor(hexString: "#F1F2F3")
        toolBar.tintColor = UIColor(hexString: "#353535")
        toolBar.clipsToBounds = true
        
        let normalTextAttributes: [String: AnyObject] = [
            NSFontAttributeName: UIFont(name: "CircularSPUI-Book", size: 16.0)!
        ]
        clearAllButton.setTitleTextAttributes(normalTextAttributes, forState: .Normal)
        applyButton.setTitleTextAttributes(normalTextAttributes, forState: .Normal)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshView), name: CustomNotifications.FilterDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(clearView), name: CustomNotifications.FilterDidClearNotification, object: nil)
        
        // Log custom events
        GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped Filter", label: nil, value: nil)
        FIRAnalytics.logEventWithName("Tapped_Filter", parameters: nil)
        Answers.logCustomEventWithName("Tapped Filter", customAttributes: nil)
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
        CustomNotifications.filterWillCloseNotification()
        
        // Log custom events
        GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped Filter Action Button", label: "Close", value: nil)
        FIRAnalytics.logEventWithName("Tapped_Filter_Action_Button", parameters: ["Button": "Close"])
        Answers.logCustomEventWithName("Tapped Filter Action Button", customAttributes: ["Button": "Close"])
        
        if filtersModel.filtersAvailable {
            let alert = UIAlertController(title: "Vendee", message: "Are you sure you want to close without applying your filters?", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default) { _ in
                (App.selectedTab == .Search) ? SearchFiltersModel.revertFiltersModel() : FiltersModel.revertFiltersModel()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            presentViewController(alert, animated: true, completion: nil)
            alert.view.tintColor = UIColor.vendeeColor()
            
        } else {
            (App.selectedTab == .Search) ? SearchFiltersModel.revertFiltersModel() : FiltersModel.revertFiltersModel()
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
        GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped Filter Action Button", label: "Clear All", value: nil)
        FIRAnalytics.logEventWithName("Tapped_Filter_Action_Button", parameters: ["Button": "Clear All"])
        Answers.logCustomEventWithName("Tapped Filter Action Button", customAttributes: ["Button": "Clear All"])
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
