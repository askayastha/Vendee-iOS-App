//
//  SortFilterViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 11/26/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics

class SortFilterViewController: UITableViewController {
    
    let sortsDict: OrderedDictionary<String, String> = [
        ("Most Popular", "Popular"),
        ("Newest", "Recency"),
        ("Lowest Price", "PriceLoHi"),
        ("Highest Price", "PriceHiLo")
    ]
    let filtersModel = FiltersModel.sharedInstanceCopy()
    
    var selectedSort: [String: String]!
    
    deinit {
        print("SortFilterViewController Deallocating !!!")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.FilterDidChangeNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshTable", name: CustomNotifications.FilterDidClearNotification, object: nil)
        
        selectedSort = filtersModel.sort
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        GoogleAnalytics.trackScreenForName("Sort Filter View")
        Answers.logCustomEventWithName("Sort Filter View", customAttributes: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortsDict.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SortCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = sortsDict.orderedKeys[indexPath.row]
        
        // Visually checkmark the selected sort
        if selectedSort.keys.contains((cell.textLabel?.text)!) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let sortName = (cell?.textLabel?.text)!
        
        if !selectedSort.keys.contains(sortName) {
            selectedSort[sortName] = sortsDict[sortName]
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            
        } else {
            selectedSort.removeAll()
            cell?.setSelected(false, animated: false)
            cell?.accessoryType = UITableViewCellAccessoryType.None
        }
        
        print(selectedSort)
        
        // Filter Stuff
        filtersModel.sort = selectedSort
        
        // Refresh Side Tab
        CustomNotifications.filterDidChangeNotification()
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        selectedSort.removeAll()
        cell?.accessoryType = UITableViewCellAccessoryType.None
    }
    
    func refreshTable() {
        selectedSort.removeAll()
        tableView.reloadData()
    }

}
