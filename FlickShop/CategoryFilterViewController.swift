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
    
    var categories = [String]()
    var tappedCategories = [String]()
    var categoriesIdDict = [String: String]()
    
    let categorySearch = CategorySearch()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        productCategory = appDelegate.productCategory
        requestCategoryFromShopStyle()
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
        return categories.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath)

        cell.textLabel?.text = categories[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.None
        
        // Visually checkmark the selected brands.
        if tappedCategories.last == (cell.textLabel?.text)! {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let categoryName = categories[indexPath.row]    ; print(categoryName)
        
        // Reload the table with new data if the tapped category isn't the currently selected one.
        if categoryName != tappedCategories.last {
            
            let categoryId = categoriesIdDict[categoryName]
            var subcategories = [String]()
            
            // Keep track of the tapped categories.
            if categoryName != categories[0] && !tappedCategories.contains(categoryName) {
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
            
            let oldCategoriesCount = categories.count
            
            categories.replaceRange(0..<categories.count, with: subcategories)
            
            let newCategoriesCount = categories.count
            
            tableView.reloadData()
            
            var indexPaths = [NSIndexPath]()
            
//            for indexPath in tableView.indexPathsForVisibleRows! {
//                if indexPath.row > tappedCategories.count {
//                    indexPaths.append(indexPath)
//                }
//            }
            
            for indexPath in tableView.indexPathsForVisibleRows! where indexPath.row > tappedCategories.count {
                indexPaths.append(indexPath)
            }
            
            print("Old Categories Count: \(oldCategoriesCount)")
            print("New Categories Count: \(newCategoriesCount)")
            
            if newCategoriesCount > oldCategoriesCount {
                tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Bottom)
                print("EXPAND ANIMATION")
            } else {
                tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
                print("COLLAPSE ANIMATION")
            }
            
        }
        
        let selectedIndexPath = NSIndexPath(forRow: categories.indexOf(categoryName)!, inSection: 0)
        
        let cell = tableView.cellForRowAtIndexPath(selectedIndexPath)
        cell?.setSelected(true, animated: false)
        cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        
        // Filter Stuff
        if tappedCategories.count > 1 {
            appDelegate.category = categoriesIdDict[tappedCategories.last!]
        } else {
            appDelegate.category = nil
        }
        
        print(tappedCategories)
        
        
        // Refresh Side Tab
        NSNotificationCenter.defaultCenter().postNotificationName(CustomNotifications.FilterDidChangeNotification, object: nil)
    }

    private func requestCategoryFromShopStyle() {
        
        if requestingData {
            return
        }
        
        requestingData = true
        
        if let category = productCategory {
            categorySearch.parseShopStyleForCategory(category) { [weak self]
                success, lastItem in
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
                            
                            if category.id == strongSelf.productCategory || category.parentId == strongSelf.productCategory {
                                strongSelf.categories.append(category.shortName!)
                            }
                            
                            // Make of dictionary of [Category: CategoryID]
                            strongSelf.categoriesIdDict[category.shortName!] = category.id!
                        }
                        
                        strongSelf.tableView.reloadData()
                    }
                }
                
            }
        }
    }

}
