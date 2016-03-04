//
//  CategoryTableViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 11/20/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class CategoryFilterViewController: UITableViewController {
    
    private var requestingData = false
    
    var productCategory: String!
    var displayCategories: [String]!
    var tappedCategories: [String]!
    var categoriesIdDict: [String: String]!
    var categorySearch: CategorySearch!
    
    let filtersModel = FiltersModel.sharedInstance()
    
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
    
    deinit {
        print("CategoryFilterViewController Deallocating !!!")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.FilterDidClearNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshTable", name: CustomNotifications.FilterDidClearNotification, object: nil)
        
        productCategory = filtersModel.productCategory
        categorySearch = filtersModel.category["categorySearch"] as! CategorySearch
        displayCategories = filtersModel.category["displayCategories"] as! [String]
        tappedCategories = filtersModel.category["tappedCategories"] as! [String]
        categoriesIdDict = filtersModel.category["categoriesIdDict"] as! [String: String]
        
        print(displayCategories)
        print(tappedCategories)
        
        // Spinner setup
        tableView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([
            spinner.centerXAnchor.constraintEqualToAnchor(tableView.centerXAnchor),
            spinner.centerYAnchor.constraintEqualToAnchor(tableView.centerYAnchor)
            ])
        
        // Request display categories for the first load
        if displayCategories.count == 0 {
            requestCategoryFromShopStyle()
        } else {
            animateSpinner(false)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Google.trackScreenForName("Category Filter View")
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
        return displayCategories.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath)

        cell.textLabel?.text = displayCategories[indexPath.row]
        
        // Visually checkmark the selected categories.
        if tappedCategories.last == (cell.textLabel?.text)! {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let categoryName = displayCategories[indexPath.row]    ; print(categoryName)
        
        // Reload the table with new data if the tapped category isn't the currently selected one.
        if categoryName != tappedCategories.last {
            
            let subcategories = getSubcategoriesForCategoryName(categoryName)
            
            let oldCategoriesCount = displayCategories.count
            displayCategories.replaceRange(0..<displayCategories.count, with: subcategories)
            let newCategoriesCount = displayCategories.count
            tableView.reloadData()
            
            var indexPaths = [NSIndexPath]()
            
            for indexPath in tableView.indexPathsForVisibleRows! where indexPath.row > tappedCategories.count {
                indexPaths.append(indexPath)
            }
            
            print("Old Categories Count: \(oldCategoriesCount)")
            print("New Categories Count: \(newCategoriesCount)")
            
            // Animate the new display categories
            if newCategoriesCount > oldCategoriesCount {
                tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Bottom)
                print("EXPAND ANIMATION")
            } else {
                tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
                print("COLLAPSE ANIMATION")
            }
        }
        
        let selectedIndexPath = NSIndexPath(forRow: displayCategories.indexOf(categoryName)!, inSection: 0)
        
        let cell = tableView.cellForRowAtIndexPath(selectedIndexPath)
        cell?.setSelected(true, animated: false)
        cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        
        // Filter Stuff
        filtersModel.category["displayCategories"] = displayCategories
        filtersModel.category["tappedCategories"] = tappedCategories
        
        print(tappedCategories)
        
        // Refresh Side Tab
        CustomNotifications.filterDidChangeNotification()
    }
    
    private func getSubcategoriesForCategoryName(categoryName: String) -> [String] {
        let categoryId = categoriesIdDict[categoryName]
        var subcategories = [String]()
        
        // Keep track of the tapped categories.
        if categoryName != displayCategories[0] && !tappedCategories.contains(categoryName) {
            tappedCategories.append(categoryName)
            
            // Remove the child categories if parent category is selected.
        } else if tappedCategories.contains(categoryName) {
            let categoryIndex = tappedCategories.indexOf(categoryName)! + 1
            tappedCategories.removeRange(categoryIndex..<tappedCategories.count)
            
            // Clear the tapped categories if the root category is selected.
        } else {
            tappedCategories.removeRange(1..<tappedCategories.count)
        }
        
        subcategories.appendContentsOf(tappedCategories)
        
        for item in categorySearch.categories {
            let category = item as! CategoryInfo
            
            if category.parentId == categoryId {
                subcategories.append(category.shortName!)
            }
        }
        
        return subcategories
    }
    
    func refreshTable() {
        let oldCategoriesCount = displayCategories.count
        
        // Clear model
        displayCategories.removeAll()
        tappedCategories.removeAll()
        
        // Repopulate original model
        let categoryId = productCategory?.componentsSeparatedByString(":").last!
        let rootCategory = categorySearch.categories.objectAtIndex(0) as! CategoryInfo
        tappedCategories.append(rootCategory.shortName!)
        
        for item in categorySearch.categories {
            let category = item as! CategoryInfo
            
            if category.id == categoryId || category.parentId == categoryId {
                displayCategories.append(category.shortName!)
            }
            
            // Make of dictionary of [Category: CategoryID]
            categoriesIdDict[category.shortName!] = category.id!
        }
        let newCategoriesCount = displayCategories.count
        
        tableView.reloadData()
        
        var indexPaths = [NSIndexPath]()
        
        for indexPath in tableView.indexPathsForVisibleRows! where indexPath.row > tappedCategories.count {
            indexPaths.append(indexPath)
        }
        
        // Animate the new display categories
        if newCategoriesCount > oldCategoriesCount {
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Bottom)
            print("EXPAND ANIMATION")
        } else {
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
            print("COLLAPSE ANIMATION")
        }
    }

    private func requestCategoryFromShopStyle() {
        if requestingData { return }
        
        requestingData = true
        guard let productCategory = productCategory else { return }
        
        let categoryId = productCategory.componentsSeparatedByString(":").last!
        
        categorySearch.parseShopStyleForCategory(categoryId) { [weak self] success, description, lastItem in
            guard let strongSelf = self else { return }
            strongSelf.requestingData = false
            
            if !success {
                if strongSelf.categorySearch.retryCount < NumericConstants.retryLimit {
                    strongSelf.requestCategoryFromShopStyle()
                    strongSelf.categorySearch.incrementRetryCount()
                    print("Request Failed. Trying again...")
                    print("Request Count: \(strongSelf.categorySearch.retryCount)")
                } else {
                    strongSelf.categorySearch.resetRetryCount()
                    strongSelf.animateSpinner(false)
                }
                
            } else {
                strongSelf.animateSpinner(false)
                print("Product count: \(lastItem)")
                
                let rootCategory = strongSelf.categorySearch.categories.objectAtIndex(0) as! CategoryInfo
                strongSelf.tappedCategories.append(rootCategory.shortName!)
                
                for item in strongSelf.categorySearch.categories {
                    let category = item as! CategoryInfo
                    
                    if category.id == categoryId || category.parentId == categoryId {
                        strongSelf.displayCategories.append(category.shortName!)
                    }
                    
                    // Make of dictionary of [Category: CategoryID]
                    strongSelf.categoriesIdDict[category.shortName!] = category.id!
                }
                // Save for filter stuff
                strongSelf.filtersModel.category["categorySearch"] = strongSelf.categorySearch
                strongSelf.filtersModel.category["displayCategories"] = strongSelf.displayCategories
                strongSelf.filtersModel.category["tappedCategories"] = strongSelf.tappedCategories
                strongSelf.filtersModel.category["categoriesIdDict"] = strongSelf.categoriesIdDict
                
                strongSelf.tableView.reloadData()
            }
        }
    }
}
