//
//  SideTabTableViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 11/20/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics
import FirebaseAnalytics

protocol SideTabDelegate: class {
    func showTab(identifier: String)
}

class SideTabViewController: UITableViewController {
    
    var selectedFilter = "Category"
    
    let sideTabsDict: OrderedDictionary<String, String> = [
        ("Category", "tab_category"),
        ("Brand", "tab_brand"),
        ("Store", "tab_store"),
        ("Price", "tab_price"),
        ("Discount", "tab_discount"),
        ("Color", "tab_color"),
        ("Sort", "tab_sort")
    ]
    let filtersModel: FiltersModel
    
    weak var delegate: SideTabDelegate?
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.FilterDidChangeNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        filtersModel = (App.selectedTab == .Search) ? SearchFiltersModel.sharedInstanceCopy() : FiltersModel.sharedInstanceCopy()
        
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Need to enable scroll for 3.5" screens (iPhone 4S and before) due to limited screen height
        if ScreenConstants.height == 480 {
            tableView.scrollEnabled = true
        }
        
        tableView.backgroundColor = UIColor(hexString: "#F1F2F3")
        tableView.showsVerticalScrollIndicator = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshTable), name: CustomNotifications.FilterDidChangeNotification, object: nil)
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
        return sideTabsDict.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SideTabCell", forIndexPath: indexPath)
        
        let selectedImageView = cell.viewWithTag(1000) as? UIImageView
        let textLabel = cell.viewWithTag(1001) as? UILabel
        let imageView = cell.viewWithTag(1002) as? UIImageView

        cell.backgroundColor = UIColor(hexString: "#F1F2F3")
        selectedImageView?.tintImageColor(UIColor(hexString: "#4A4A4A")!)
        selectedImageView?.hidden = !isSelectedFilter(sideTabsDict.orderedKeys[indexPath.row])
        textLabel?.text = sideTabsDict.orderedKeys[indexPath.row].uppercaseString
        textLabel?.textColor = UIColor(hexString: "#4A4A4A")
        imageView?.image = UIImage(named: sideTabsDict.orderedValues[indexPath.row])
        imageView?.tintImageColor(UIColor(hexString: "#4A4A4A")!)
        
        if selectedFilter.uppercaseString == textLabel?.text {
            cell.backgroundColor = UIColor.whiteColor()
            textLabel?.textColor = UIColor.vendeeColor()
            imageView?.tintImageColor(UIColor.vendeeColor())
            selectedImageView?.tintImageColor(UIColor.vendeeColor())
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let statusBar: CGFloat = 20
        let navBar: CGFloat = 44
        let toolBar: CGFloat = 44
        
        let rowHeight = (ScreenConstants.height - statusBar - navBar - toolBar) / CGFloat(sideTabsDict.count)
        let defaultHeight = (580 - statusBar - navBar - toolBar) / CGFloat(sideTabsDict.count)
        
        return rowHeight < 65 ? defaultHeight : rowHeight
    }
    
    func isSelectedFilter(filter: String) -> Bool {
        
        let filter = filter.lowercaseString
        var filterSelected = false
        
        switch filter {
        case "category":
            let displayCategories = filtersModel.category["displayCategories"] as! [String]
            let tappedCategories = filtersModel.category["tappedCategories"] as! [String]
            let categoryName = filtersModel.productCategory?.componentsSeparatedByString(":").first
            let tappedCategoryName = tappedCategories.last?.componentsSeparatedByString(":").first!
            filterSelected = !(categoryName == tappedCategoryName || displayCategories.count == 0)
            
        case "sort":
            filterSelected = filtersModel.sort.count > 0
        
        case "brand", "store", "color", "price":
            let codes = filtersModel.filterParams[filter] as! [String: String]
            filterSelected = codes.count > 0
        
        case "discount":
            let discountCode = filtersModel.filterParams[filter] as! [String: String]
            let offerCodes = filtersModel.filterParams["offer"] as! [String: String]
            filterSelected = discountCode.count > 0 || offerCodes.count > 0
        
        default:
            filterSelected = false
        }
        
        return filterSelected
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let filter = sideTabsDict.orderedKeys[indexPath.row]
        let identifier = "Embed\(sideTabsDict.orderedKeys[indexPath.row])"
        print("Filter Type: \(identifier)")
        
        // Log custom events
        GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped Filter Tab", label: filter, value: nil)
        FIRAnalytics.logEventWithName("Tapped_Filter_Tab", parameters: ["Filter Tab": filter])
        Answers.logCustomEventWithName("Tapped Filter Tab", customAttributes: ["Filter Tab": filter])
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let textLabel = cell?.viewWithTag(1001) as? UILabel
        
        if selectedFilter != textLabel?.text {
            delegate?.showTab(identifier)
        }
        
        selectedFilter = (textLabel?.text)!
        tableView.reloadData()
    }
    
    func refreshTable() {
        tableView.reloadData()
    }
}

