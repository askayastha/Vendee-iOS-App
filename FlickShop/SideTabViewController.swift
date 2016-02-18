//
//  SideTabTableViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 11/20/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

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
    
    weak var delegate: SideTabDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshTable", name: CustomNotifications.FilterDidChangeNotification, object: nil)
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

        cell.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
        selectedImageView?.hidden = !isSelectedFilter(sideTabsDict.orderedKeys[indexPath.row])
        textLabel?.text = sideTabsDict.orderedKeys[indexPath.row]
        textLabel?.textColor = UIColor.blackColor()
        imageView?.image = UIImage(named: sideTabsDict.orderedValues[indexPath.row])
        
        if selectedFilter == textLabel?.text {
            cell.backgroundColor = UIColor.whiteColor()
            textLabel?.textColor = UIColor(red: 255/255, green: 168/255, blue: 0, alpha: 1.0)
            imageView?.image = UIImage(named: sideTabsDict.orderedValues[indexPath.row] + "_selected")
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    func isSelectedFilter(filter: String) -> Bool {
        
        let filter = filter.lowercaseString
        var filterSelected = false
        
        switch filter {
            case "category":
                let displayCategories = appDelegate.filter.category["displayCategories"] as! [String]
                let tappedCategories = appDelegate.filter.category["tappedCategories"] as! [String]
                let categoryName = appDelegate.filter.productCategory?.componentsSeparatedByString(":").first
                filterSelected = !(categoryName == tappedCategories.last || displayCategories.count == 0)
            case "sort":
                    filterSelected = appDelegate.filter.sort.count > 0
            case "brand", "store", "color", "price":
                let codes = appDelegate.filter.filterParams[filter] as! [String: String]
                    filterSelected = codes.count > 0
            case "discount":
                let discountCode = appDelegate.filter.filterParams[filter] as! [String: String]
                let offerCodes = appDelegate.filter.filterParams["offer"] as! [String: String]
                filterSelected = discountCode.count > 0 || offerCodes.count > 0
            default:
                filterSelected = false
        }
        
        return filterSelected
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let identifier = "Embed\(sideTabsDict.orderedKeys[indexPath.row])"
        print("Filter Type: \(identifier)")
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let textLabel = cell?.viewWithTag(1001) as? UILabel
        
        if selectedFilter != textLabel?.text {
            delegate?.showTab(identifier)
        }
        
        selectedFilter = (textLabel?.text)!
        tableView.reloadData()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func refreshTable() {
        tableView.reloadData()
    }

}
