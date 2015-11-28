//
//  StoreTableViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 11/24/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class StoreFilterViewController: UIViewController {
    
    var stores: [String: [NSDictionary]]!
    var keys: [String]!
    var filteredStores = [String]()
    var searchController: UISearchController!
    var searching = false
    
    var selectedStores = [String]()
    var selectedStoreCodes: [String]?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        tableView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        
        if let URL = NSBundle.mainBundle().URLForResource("Shopstyle_Stores", withExtension: "plist") {
            if let storesFromPlist = NSDictionary(contentsOfURL: URL) {
                stores = storesFromPlist as! [String: [NSDictionary]]
                keys = (storesFromPlist.allKeys as! [String]).sort()
            }
        }
        
        searchController = UISearchController(searchResultsController: nil)
        
        let searchBar = searchController.searchBar
        searchBar.placeholder = "Search"
        //        searchBar.sizeToFit()
        
        //        tableView.tableHeaderView = searchBar
        headerView.addSubview(searchBar)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.delegate = self
    }
    
    deinit {
        populateStoreCodes()
        
        if let storeCodes = selectedStoreCodes {
            appDelegate.filterParams.appendContentsOf(storeCodes)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        searchController.searchBar.sizeToFit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateStoreCodes() {
        let alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters.map { String($0) }
        
        if !selectedStores.isEmpty {
            var selectedStoreCodesArray = [String]()
            
            for selectedStore in selectedStores {
                var firstChar = String(selectedStore.characters.first!).uppercaseString
                
                if !alphabets.contains(firstChar) {
                    firstChar = "#"
                }
                
                let storeSection = stores[firstChar]!
                
                for store in storeSection {
                    if selectedStore == store["name"] as! String {
                        let storeCode = store["id"] as! String
                        selectedStoreCodesArray.append("r" + storeCode)
                        break
                    }
                }
            }
            
            selectedStoreCodes = selectedStoreCodesArray
            
        } else {
            selectedStoreCodes = nil
        }
    }
    
}

// MARK: - Table view data source
extension StoreFilterViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return searching && !isKeywordEmpty() ? 1 : keys.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let key = keys[section]
        let storeSection = stores[key]!
        
        return searching && !isKeywordEmpty() ? filteredStores.count : storeSection.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StoreCell", forIndexPath: indexPath)
        
        cell.accessoryType = UITableViewCellAccessoryType.None
        
        if searching && !isKeywordEmpty() {
            cell.textLabel?.text = filteredStores[indexPath.row]
            
        } else {
            let key = keys[indexPath.section]
            let storeSection = stores[key]!
            
            cell.textLabel?.text = storeSection[indexPath.row]["name"] as? String
        }
        
        // Visually checkmark the selected stores.
        if selectedStores.contains((cell.textLabel?.text)!) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
        //        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
        //            if selectedIndexPaths.contains(indexPath) && selectedStores.contains((cell.textLabel?.text)!) {
        //                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        //                cell.highlighted = true
        //            }
        //        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searching && !isKeywordEmpty() ? nil : keys[section]
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return searching && !isKeywordEmpty() ? nil : keys
    }
    
    func isKeywordEmpty() -> Bool {
        let searchString = searchController.searchBar.text!
        
        return searchString.isEmpty
    }
}

// MARK: - Table view delegate
extension StoreFilterViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let storeName = (cell?.textLabel?.text)!
        
//        if searching && !isKeywordEmpty() {
//            storeName = selectedStores[indexPath.row]
//            
//        } else {
//            let key = keys[indexPath.section]
//            let storeSection = stores[key]!
//            
//            storeName = storeSection[indexPath.row]["name"] as! String
//        }
        
        if !selectedStores.contains(storeName) {
            selectedStores.append(storeName)
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            
        } else {
            let removeIndex = selectedStores.indexOf(storeName)!
            selectedStores.removeAtIndex(removeIndex)
            cell?.accessoryType = UITableViewCellAccessoryType.None
        }
        
        print(selectedStores)
    }
}

extension StoreFilterViewController: UISearchResultsUpdating {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text!
        filteredStores.removeAll(keepCapacity: true)
        
        if !searchString.isEmpty {
            let filter: String -> Bool = { name in
                let range = name.rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch)
                
                return range != nil
            }
            
            for key in keys {
                let storesForKey = stores[key]!
                var storesList = [String]()
                
                for dictionary in storesForKey {
                    let storeName = dictionary["name"] as! String
                    storesList.append(storeName)
                }
                
                let matches = storesList.filter(filter)
                filteredStores += matches
                
            }
        }
        
        tableView.reloadData()
    }
}

extension StoreFilterViewController: UISearchControllerDelegate {
    
    func willPresentSearchController(searchController: UISearchController) {
        searching = true
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        searching = false
    }
}
