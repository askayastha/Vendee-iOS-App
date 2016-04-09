//
//  BrandTableViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 11/22/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics

struct FilterViewCellIdentifiers {
    static let headerCell = "HeaderCell"
}

class BrandFilterViewController: UIViewController {
    
    private(set) var searching = false
    private(set) var requestingData = false
    
//    var brands: [String: [NSDictionary]]!
    var keys: [String]!
    var filteredBrands = [String]()
    var searchController: UISearchController!
    var selectedBrands: [String: String]
    var brandSearch = BrandSearch()
    
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
        selectedBrands = filtersModel.filterParams["brand"] as! [String: String]
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("BrandFilterViewController Deallocating !!!")
        searchController.active = false
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.FilterDidChangeNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshTable), name: CustomNotifications.FilterDidClearNotification, object: nil)
        
        setupView()
        requestDataFromShopStyle()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        GoogleAnalytics.trackScreenForName("Brand Filter View")
        Answers.logCustomEventWithName("Brand Filter View", customAttributes: nil)
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
        tableView.showsVerticalScrollIndicator = false
        tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        tableView.sectionIndexTrackingBackgroundColor = UIColor.clearColor()
        tableView.sectionIndexColor = UIColor.lightGrayColor()
        
        // SearchController setup
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
extension BrandFilterViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return searching && !isKeywordEmpty() ? 1 : brandSearch.brands.keys.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = keys[section]
        let brandsList = brandSearch.brands[key]!
        
        return searching && !isKeywordEmpty() ? filteredBrands.count : brandsList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BrandCell", forIndexPath: indexPath)
        
        if searching && !isKeywordEmpty() {
            cell.textLabel?.text = filteredBrands[indexPath.row]
            
        } else {
            let key = keys[indexPath.section]
            let brandsList = brandSearch.brands[key]!
            
            cell.textLabel?.text = brandsList[indexPath.row]["name"] as? String
        }
        
        // Visually checkmark the selected brands.
        if selectedBrands.keys.contains((cell.textLabel?.text)!) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
//        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
//            if selectedIndexPaths.contains(indexPath) && selectedBrands.contains((cell.textLabel?.text)!) {
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
        cell?.backgroundView?.backgroundColor = UIColor(hexString: "#F1F2F3")
        
        // Reuse views
        if cell?.contentView.subviews.count == 0 {
            let sectionLabel = UILabel()
            sectionLabel.font = UIFont(name: "FaktFlipboard-Medium", size: 14.0)!
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
        
        let sectionKey = keys[section]
        let sectionTitle = "\(sectionKey) (\(brandSearch.brands[sectionKey]!.count) BRANDS)"
        sectionLabel.text = sectionTitle
        
        if searching && !isKeywordEmpty() {
            sectionLabel.text = "BEST MATCHES"
        }
        
        return cell
    }
    
    // MARK: - Helper Methods
    
    private func isKeywordEmpty() -> Bool {
        let searchString = searchController.searchBar.text!
        
        return searchString.isEmpty
    }
    
    private func getCodeForBrandName(brandName: String) -> String? {
        let alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters.map { String($0) }
        
        var key = String(brandName.characters.first!).uppercaseString
        var brandCode: String?
        
        if !alphabets.contains(key) {
            key = "#"
        }
        
        let brandsList = brandSearch.brands[key]!
        
        for brand in brandsList {
            if brandName == brand["name"] as! String {
                let brandId = brand["id"] as! String
                brandCode = "b\(brandId)"
                break
            }
        }
        
        return brandCode
    }
    
    func refreshTable() {
        selectedBrands.removeAll()
        searchController.active = false
        tableView.reloadData()
    }
    
    private func requestDataFromShopStyle() {
        if requestingData { return }
        requestingData = true
        
        brandSearch.requestShopStyleBrands { [weak self] success, description, lastItem in
            guard let strongSelf = self else { return }
            strongSelf.requestingData = false
            
            if !success {
                if strongSelf.brandSearch.retryCount < NumericConstants.retryLimit {
                    strongSelf.requestDataFromShopStyle()
                    strongSelf.brandSearch.incrementRetryCount()
                    print("Request Failed. Trying again...")
                    print("Request Count: \(strongSelf.brandSearch.retryCount)")
                } else {
                    strongSelf.brandSearch.resetRetryCount()
                    strongSelf.animateSpinner(false)
                    
                    // Log custom events
                    GoogleAnalytics.trackEventWithCategory("Error", action: "Network Error", label: description, value: nil)
                    Answers.logCustomEventWithName("Network Error", customAttributes: ["Description": description])
                }
                
            } else {
                // Sort section keys and change the order of section "#"
                var sectionKeys = [String](strongSelf.brandSearch.brands.keys).sort()
                if sectionKeys.first == "#" {
                    sectionKeys.append(sectionKeys.removeFirst())
                }
                
                strongSelf.keys = sectionKeys
                strongSelf.animateSpinner(false)
                strongSelf.tableView.reloadData()
            }
        }
    }
}

// MARK: - Table view delegate
extension BrandFilterViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        searchController.searchBar.resignFirstResponder()
        
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
        
        if !selectedBrands.keys.contains(brandName) {
            if let brandCode = getCodeForBrandName(brandName) {
                selectedBrands[brandName] = brandCode
                cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            
        } else {
            if let _ = selectedBrands.removeValueForKey(brandName) {
                cell?.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        print(selectedBrands)
        
        filtersModel.filterParams["brand"] = selectedBrands
        
        // Refresh Side Tab
        CustomNotifications.filterDidChangeNotification()
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
            
            keys?.forEach {
                let brandsForKey = brandSearch.brands[$0]!
                var brandsList = [String]()
                
                for dictionary in brandsForKey {
                    let brandName = dictionary["name"] as! String
                    brandsList.append(brandName)
                }
                
                let matches = brandsList.filter(filter)
                filteredBrands += matches
            }
        }
        
        if let _ = keys {
            tableView.reloadData()
        }
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
