//
//  SortFilterViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 11/26/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics
import FirebaseAnalytics

class SortFilterViewController: UITableViewController {
    
    let sortsDict: OrderedDictionary<String, String> = [
        ("Most Popular", "Popular"),
        ("Most Favorites", "Favorite"),
        ("Newest", "Recency"),
        ("Lowest Price", "PriceLoHi"),
        ("Highest Price", "PriceHiLo")
    ]
    let filtersModel: FiltersModel
    
    var selectedSort: [String: String]
    var selectedIndexPath: NSIndexPath!
    
    required init?(coder aDecoder: NSCoder) {
        filtersModel = (App.selectedTab == .Search) ? SearchFiltersModel.sharedInstanceCopy() : FiltersModel.sharedInstanceCopy()
        selectedSort = filtersModel.sort
        
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("SortFilterViewController Deallocating !!!")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.FilterDidChangeNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let key = selectedSort.keys.first {
            selectedIndexPath = NSIndexPath(forRow: sortsDict.orderedKeys.indexOf(key)!, inSection: 0)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshTable), name: CustomNotifications.FilterDidClearNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        GoogleAnalytics.trackScreenForName("Sort Filter View")
        FIRAnalytics.logEventWithName("Sort_Filter_View", parameters: nil)
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
        cell.tintColor = UIColor.vendeeColor()
        cell.textLabel?.text = sortsDict.orderedKeys[indexPath.row]
        
        // Visually checkmark the selected sort
        if selectedSort.keys.contains(sortsDict.orderedKeys[indexPath.row]) {
            let checkmark = UIImageView(image: UIImage(named: "selection_checkmark"))
            checkmark.tintImageColor(UIColor.vendeeColor())
            cell.accessoryView = checkmark
            
        } else {
            cell.accessoryView = nil
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if let indexPath = selectedIndexPath {
            selectedSort.removeAll()
            let selectedCell = tableView.cellForRowAtIndexPath(indexPath)
            selectedCell?.accessoryView = nil
            selectedCell?.accessoryType = .None
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedIndexPath = indexPath
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let sortName = (cell?.textLabel?.text)!
        
        if !selectedSort.keys.contains(sortName) {
            selectedSort[sortName] = sortsDict[sortName]
            let checkmark = UIImageView(image: UIImage(named: "selection_checkmark"))
            checkmark.tintImageColor(UIColor.vendeeColor())
            cell?.accessoryView = checkmark
        }
        
        print(selectedSort)
        
        // Filter Stuff
        filtersModel.sort = selectedSort
        
        // Refresh Side Tab
        CustomNotifications.filterDidChangeNotification()
    }
    
//    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        let cell = tableView.cellForRowAtIndexPath(indexPath)
//        selectedSort.removeAll()
//        cell?.accessoryType = .None
//    }
    
    func refreshTable() {
        selectedSort.removeAll()
        tableView.reloadData()
    }

}
