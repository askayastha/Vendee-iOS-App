//
//  SideTabTableViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 11/20/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

protocol SideTabDelegate: class {
    func showTab(identifier: String)
}

class SideTabViewController: UITableViewController {
    
    var sideTabs = ["Category", "Brand", "Store", "Price", "Discount", "Color", "Sort"]
    
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
        return sideTabs.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SideTabCell", forIndexPath: indexPath)
        
        let selectedImageView = cell.viewWithTag(1000) as? UIImageView!
        let textLabel = cell.viewWithTag(1001) as? UILabel

        selectedImageView?.hidden = !isSelectedFilter(sideTabs[indexPath.row])
        textLabel?.text = sideTabs[indexPath.row]

        return cell
    }
    
    func isSelectedFilter(filter: String) -> Bool {
        
        let filter = filter.lowercaseString
        var filterSelected = false
        
        switch filter {
            case "category":
                let displayCategories = appDelegate.category["displayCategories"] as! [String]
                let tappedCategories = appDelegate.category["tappedCategories"] as! [String]
                let categoryName = appDelegate.productCategory?.componentsSeparatedByString(":").first
                filterSelected = !(categoryName == tappedCategories.last || displayCategories.count == 0)
            case "sort":
                    filterSelected = appDelegate.sort.count > 0
            case "brand", "store", "color", "price":
                let codes = appDelegate.filterParams[filter] as! [String: String]
                    filterSelected = codes.count > 0
            case "discount":
                let discountCode = appDelegate.filterParams[filter] as! [String: String]
                let offerCodes = appDelegate.filterParams["offer"] as! [String: String]
                filterSelected = discountCode.count > 0 || offerCodes.count > 0
            default:
                filterSelected = false
        }
        
        return filterSelected
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let identifier = "Embed\(sideTabs[indexPath.row])"
        print("Filter Type: \(identifier)")
        delegate?.showTab(identifier)
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
