//
//  StoreTableViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 11/24/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics

class StoreFilterViewController: UIViewController {
    
    private(set) var searching = false
    private(set) var requestingData = false
    
//    var stores: [String: [NSDictionary]]!
    var keys: [String]!
    var filteredStores = [String]()
    var searchController: UISearchController!
    var selectedStores: [String: String]
    var storeSearch = StoreSearch()
    
    let filtersModel = FiltersModel.sharedInstanceCopy()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    lazy private var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.color = UIColor(white: 0.1, alpha: 0.5)
        spinner.startAnimating()
        
        return spinner
    }()
    
    private func animateSpinner(animate: Bool) {
        if animate {
            self.spinner.startAnimating()
            UIView.animateWithDuration(0.3, animations: {
                self.spinner.transform = CGAffineTransformIdentity
                self.spinner.alpha = 1.0
                }, completion: nil)
            
        } else {
            UIView.animateWithDuration(0.3, animations: {
                self.spinner.transform = CGAffineTransformMakeScale(0.1, 0.1)
                self.spinner.alpha = 0.0
                }, completion: { _ in
                    self.spinner.stopAnimating()
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        selectedStores = filtersModel.filterParams["store"] as! [String: String]
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("StoreFilterViewController Deallocating !!!")
        searchController.active = false
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.FilterDidChangeNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshTable), name: CustomNotifications.FilterDidClearNotification, object: nil)
        
        requestDataFromShopStyle()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        GoogleAnalytics.trackScreenForName("Store Filter View")
        Answers.logCustomEventWithName("Store Filter View", customAttributes: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        searchController.searchBar.sizeToFit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupView() {
        
        // Spinner setup
        tableView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([
            spinner.centerXAnchor.constraintEqualToAnchor(tableView.centerXAnchor),
            spinner.centerYAnchor.constraintEqualToAnchor(tableView.centerYAnchor, constant: -44)
            ])
        
        // Table view setup
        tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: FilterViewCellIdentifiers.headerCell)
        tableView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        searchController = UISearchController(searchResultsController: nil)
        
        let searchBar = searchController.searchBar
        searchBar.placeholder = "Search"
        searchBar.barTintColor = UIColor(hexString: "#F1F2F3")
        searchBar.layer.borderWidth = 1.0
        searchBar.layer.borderColor = UIColor(hexString: "#F1F2F3")?.CGColor
        
        headerView.addSubview(searchBar)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.delegate = self
    }
}

// MARK: - Table view data source
extension StoreFilterViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return searching && !isKeywordEmpty() ? 1 : storeSearch.stores.keys.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = keys[section]
        let storesList = storeSearch.stores[key]!
        
        return searching && !isKeywordEmpty() ? filteredStores.count : storesList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StoreCell", forIndexPath: indexPath)
        
        if searching && !isKeywordEmpty() {
            cell.textLabel?.text = filteredStores[indexPath.row]
            
        } else {
            let key = keys[indexPath.section]
            let storeSection = storeSearch.stores[key]!
            
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
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return searching && !isKeywordEmpty() ? nil : keys
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier(FilterViewCellIdentifiers.headerCell)
        cell?.backgroundView = UIView()
        
        if searching && !isKeywordEmpty() {
            cell?.backgroundView?.backgroundColor = UIColor.clearColor()
            return cell
        }
        
        cell?.backgroundView?.backgroundColor = UIColor(hexString: "#F1F2F3")
        
        // Reuse views
        if cell?.contentView.subviews.count == 0 {
            let sectionLabel = UILabel()
            sectionLabel.font = UIFont(name: "FaktFlipboard-Normal", size: 14.0)!
            sectionLabel.textColor = UIColor.lightGrayColor()
            cell?.contentView.addSubview(sectionLabel)
            
            sectionLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activateConstraints([
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:|-15-[label]-15-|",
                    options: [],
                    metrics: nil,
                    views: ["label" : sectionLabel]),
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|[label]|",
                    options: [],
                    metrics: nil,
                    views: ["label": sectionLabel])
                ].flatten().map{$0})
        }
        
        let sectionLabel = cell?.contentView.subviews[0] as! UILabel
        
        let section = keys[section]
        let sectionTitle = "\(section) (\(storeSearch.stores[section]!.count) STORES)"
        sectionLabel.text = sectionTitle
        
        return cell
    }
    
    // MARK: - Helper Methods
    
    private func isKeywordEmpty() -> Bool {
        let searchString = searchController.searchBar.text!
        
        return searchString.isEmpty
    }
    
    private func getCodeForStoreName(storeName: String) -> String? {
        let alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters.map { String($0) }
        
        var key = String(storeName.characters.first!).uppercaseString
        var storeCode: String?
        
        if !alphabets.contains(key) {
            key = "#"
        }
        
        let storesList = storeSearch.stores[key]!
        
        for store in storesList {
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
    
    private func requestDataFromShopStyle() {
        if requestingData { return }
        requestingData = true
        
        storeSearch.requestShopStyleStores { [weak self] success, description, lastItem in
            guard let strongSelf = self else { return }
            strongSelf.requestingData = false
            
            if !success {
                if strongSelf.storeSearch.retryCount < NumericConstants.retryLimit {
                    strongSelf.requestDataFromShopStyle()
                    strongSelf.storeSearch.incrementRetryCount()
                    print("Request Failed. Trying again...")
                    print("Request Count: \(strongSelf.storeSearch.retryCount)")
                } else {
                    strongSelf.storeSearch.resetRetryCount()
                    strongSelf.animateSpinner(false)
                    
                    // Log custom events
                    GoogleAnalytics.trackEventWithCategory("Error", action: "Network Error", label: description, value: nil)
                    Answers.logCustomEventWithName("Network Error", customAttributes: ["Description": description])
                }
                
            } else {
                strongSelf.keys = [String](strongSelf.storeSearch.stores.keys).sort()
                strongSelf.animateSpinner(false)
                strongSelf.tableView.reloadData()
            }
        }
    }
}

// MARK: - Table view delegate
extension StoreFilterViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        searchController.searchBar.resignFirstResponder()
        
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
            
            keys?.forEach {
                let storesForKey = storeSearch.stores[$0]!
                var storesList = [String]()
                
                for dictionary in storesForKey {
                    let storeName = dictionary["name"] as! String
                    storesList.append(storeName)
                }
                
                let matches = storesList.filter(filter)
                filteredStores += matches
            }
        }
        
        if let _ = keys {
            tableView.reloadData()
        }
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
