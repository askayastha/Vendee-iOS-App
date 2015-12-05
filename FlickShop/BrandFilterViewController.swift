//
//  BrandTableViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 11/22/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class BrandFilterViewController: UIViewController {
    
    var brands: [String: [NSDictionary]]!
    var keys: [String]!
    var filteredBrands = [String]()
    var searchController: UISearchController!
    var searching = false
    
    var selectedBrands = [String]()
    var selectedBrandCodes = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        tableView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)

        if let URL = NSBundle.mainBundle().URLForResource("Shopstyle_Brands", withExtension: "plist") {
            if let brandsFromPlist = NSDictionary(contentsOfURL: URL) {
                brands = brandsFromPlist as! [String: [NSDictionary]]
                keys = (brandsFromPlist.allKeys as! [String]).sort()
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
        print("BrandFilterViewController Deallocating !!!")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        searchController.searchBar.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateBrandCodes() {
        let alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters.map { String($0) }
        
        if !selectedBrands.isEmpty {
            var selectedBrandCodesArray = [String]()
            
            for selectedBrand in selectedBrands {
                var firstChar = String(selectedBrand.characters.first!).uppercaseString
            
                if !alphabets.contains(firstChar) {
                    firstChar = "#"
                }
                
                let brandSection = brands[firstChar]!
                
                for brand in brandSection {
                    if selectedBrand == brand["name"] as! String {
                        let brandCode = brand["id"] as! String
                        selectedBrandCodesArray.append("b" + brandCode)
                        break
                    }
                }
            }
            
            selectedBrandCodes = selectedBrandCodesArray
            
        } else {
            selectedBrandCodes.removeAll()
        }
    }

}

// MARK: - Table view data source
extension BrandFilterViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return searching && !isKeywordEmpty() ? 1 : keys.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = keys[section]
        let brandSection = brands[key]!
        
        return searching && !isKeywordEmpty() ? filteredBrands.count : brandSection.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BrandCell", forIndexPath: indexPath)
        
        cell.accessoryType = UITableViewCellAccessoryType.None
        
        if searching && !isKeywordEmpty() {
            cell.textLabel?.text = filteredBrands[indexPath.row]
            
        } else {
            let key = keys[indexPath.section]
            let brandSection = brands[key]!
            
            cell.textLabel?.text = brandSection[indexPath.row]["name"] as? String
        }
        
        // Visually checkmark the selected brands.
        if selectedBrands.contains((cell.textLabel?.text)!) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
//        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
//            if selectedIndexPaths.contains(indexPath) && selectedBrands.contains((cell.textLabel?.text)!) {
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
extension BrandFilterViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let brandName = (cell?.textLabel?.text)!
        
//        if searching && !isKeywordEmpty() {
//            brandName = filteredBrands[indexPath.row]
//            
//        } else {
//            let key = keys[indexPath.section]
//            let brandSection = brands[key]!
//            
//            brandName = brandSection[indexPath.row]["name"] as! String
//        }
        
        if !selectedBrands.contains(brandName) {
            selectedBrands.append(brandName)
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            
        } else {
            let removeIndex = selectedBrands.indexOf(brandName)!
            selectedBrands.removeAtIndex(removeIndex)
            cell?.accessoryType = UITableViewCellAccessoryType.None
        }
        
        print(selectedBrands)
        
        // Filter Stuff
        populateBrandCodes()
        
        appDelegate.filterParams["brand"] = selectedBrandCodes
        
        // Refresh Side Tab
        NSNotificationCenter.defaultCenter().postNotificationName(CustomNotifications.FilterDidChangeNotification, object: nil)
    }
}

extension BrandFilterViewController: UISearchResultsUpdating {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text!
        filteredBrands.removeAll(keepCapacity: true)
        
        if !searchString.isEmpty {
            let filter: String -> Bool = { name in
                let range = name.rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch)
                
                return range != nil
            }
            
            for key in keys {
                let brandsForKey = brands[key]!
                var brandsList = [String]()
                
                for dictionary in brandsForKey {
                    let brandName = dictionary["name"] as! String
                    brandsList.append(brandName)
                }
                
                let matches = brandsList.filter(filter)
                filteredBrands += matches
                
            }
        }
        
        tableView.reloadData()
    }
}

extension BrandFilterViewController: UISearchControllerDelegate {
    
    func willPresentSearchController(searchController: UISearchController) {
        searching = true
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        searching = false
    }
}
