//
//  SortFilterViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 11/26/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class SortFilterViewController: UITableViewController {
    
    let sortsDict: OrderedDictionary<String, String> = [
        ("Most Popular", "Popular"),
        ("Newest", "Recency"),
        ("Lowest Price", "PriceLoHi"),
        ("Highest Price", "PriceHiLo")
    ]
    
    var keys = [String]()
    var sort = ""
    var sortCode: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    deinit {
        print("SortFilterViewController Deallocating !!!")
        
//        if let sortCode = sortCode {
//            appDelegate.sort = sortCode
//        }
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
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        
        if sort != (cell?.textLabel?.text)! {
            sort = (cell?.textLabel?.text)!
            sortCode = sortsDict[sort]
            
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.None
            cell?.setSelected(false, animated: false)
            sort = ""
            sortCode = nil
        }
        
        print(sort)
        print(sortCode)
        
        // Filter Stuff
        appDelegate.sort = sortCode
        
        // Refresh Side Tab
        NSNotificationCenter.defaultCenter().postNotificationName(CustomNotifications.FilterDidChangeNotification, object: nil)
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.None
    }

}
