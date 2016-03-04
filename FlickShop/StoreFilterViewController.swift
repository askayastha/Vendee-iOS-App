//
//  StoreTableViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 11/24/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class StoreFilterViewController: UIViewController {
    
    var searching = false
    
    var stores: [String: [NSDictionary]]!
    var keys: [String]!
    var filteredStores = [String]()
    var searchController: UISearchController!
    var selectedStores: [String: String]!
    
    let filtersModel = FiltersModel.sharedInstance()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    deinit {
        print("StoreFilterViewController Deallocating !!!")
        searchController.active = false
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.FilterDidChangeNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshTable", name: CustomNotifications.FilterDidClearNotification, object: nil)
        
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
        
        selectedStores = filtersModel.filterParams["store"] as! [String: String]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Google.trackScreenForName("Store Filter View")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        searchController.searchBar.sizeToFit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - Table view data source
extension StoreFilterViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return searching && !isKeywordEmpty() ? 1 : keys.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = keys[section]
        let storeSection = stores[key]!
        
        return searching && !isKeywordEmpty() ? filteredStores.count : storeSection.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StoreCell", forIndexPath: indexPath)
        
        if searching && !isKeywordEmpty() {
            cell.textLabel?.text = filteredStores[indexPath.row]
            
        } else {
            let key = keys[indexPath.section]
            let storeSection = stores[key]!
            
            cell.textLabel?.text = storeSection[indexPath.row]["name"] as? String
        }
        
        // Visually checkmark the selected stores.
        if selectedStores.keys.contains((cell.textLabel?.text)!) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
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
    
    // MARK: - Helper Methods
    
    private func isKeywordEmpty() -> Bool {
        let searchString = searchController.searchBar.text!
        
        return searchString.isEmpty
    }
    
    private func getCodeForStoreName(storeName: String) -> String? {
        let alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters.map { String($0) }
        
        var firstChar = String(storeName.characters.first!).uppercaseString
        var storeCode: String?
        
        if !alphabets.contains(firstChar) {
            firstChar = "#"
        }
        
        let storeSection = stores[firstChar]!
        
        for store in storeSection {
            if storeName == store["name"] as! String {
                let storeId = store["id"] as! String
                storeCode = "r\(storeId)"
                break
            }
        }
        
        return storeCode
    }
    
    func refreshTable() {
        selectedStores.removeAll()
        searchController.active = false
        tableView.reloadData()
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
        
        if !selectedStores.keys.contains(storeName) {
            if let storeCode = getCodeForStoreName(storeName) {
                selectedStores[storeName] = storeCode
                cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            
        } else {
            if let _ = selectedStores.removeValueForKey(storeName) {
                cell?.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        print(selectedStores)
        
        filtersModel.filterParams["store"] = selectedStores
        
        // Refresh Side Tab
        CustomNotifications.filterDidChangeNotification()
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
