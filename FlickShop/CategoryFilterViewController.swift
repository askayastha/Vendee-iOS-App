//
//  CategoryTableViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 11/20/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class CategoryFilterViewController: UITableViewController {
    
    var requestingData = false
    var productCategory: String?
    
    var displayCategories: [String]!
    var tappedCategories: [String]!
    var categoriesIdDict: [String: String]!
    var categorySearch: CategorySearch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshTable", name: CustomNotifications.FilterDidClearNotification, object: nil)
        
        productCategory = appDelegate.productCategory
        
        categorySearch = appDelegate.category["categorySearch"] as! CategorySearch
        displayCategories = appDelegate.category["displayCategories"] as! [String]
        tappedCategories = appDelegate.category["tappedCategories"] as! [String]
        categoriesIdDict = appDelegate.category["categoriesIdDict"] as! [String: String]
        
        print(displayCategories)
        print(tappedCategories)
        
        // Request display categories for the first load
        if displayCategories.count == 0 {
            requestCategoryFromShopStyle()
        }
    }
    
    deinit {
        print("CategoryFilterViewController Deallocating !!!")
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
        appDelegate.category["displayCategories"] = displayCategories
        appDelegate.category["tappedCategories"] = tappedCategories
        
        print(tappedCategories)
        
        // Refresh Side Tab
        filterDidChangeNotification()
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
        if requestingData {
            return
        }
        requestingData = true
        
        if let productCategory = productCategory {
            let categoryId = productCategory.componentsSeparatedByString(":").last!
            
            categorySearch.parseShopStyleForCategory(categoryId) { [weak self] success, lastItem in
                if let strongSelf = self {
                    if !success {
                        print("Products Count: \(lastItem)")
                        
                        print("Request Failed. Trying again...")
                        strongSelf.requestingData = false
                        strongSelf.requestCategoryFromShopStyle()
                        
                    } else {
                        strongSelf.requestingData = false
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
                        strongSelf.appDelegate.category["categorySearch"] = strongSelf.categorySearch
                        strongSelf.appDelegate.category["displayCategories"] = strongSelf.displayCategories
                        strongSelf.appDelegate.category["tappedCategories"] = strongSelf.tappedCategories
                        strongSelf.appDelegate.category["categoriesIdDict"] = strongSelf.categoriesIdDict
                        
                        strongSelf.tableView.reloadData()
                    }
                }
            }
        }
    }
}
