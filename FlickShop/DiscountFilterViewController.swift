//
//  DiscountFilterViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 11/25/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import NMRangeSlider

class DiscountFilterViewController: UITableViewController {
    
//    let discountsDict = [
//        "Regular and Sale Items": "d",
//        "10": "d0",
//        "20": "d1",
//        "30": "d2",
//        "40": "d3",
//        "50": "d4",
//        "60": "d5",
//        "70": "d6"
//    ]
    
    private let minValue = 0
    private let maxValue = 7
    
    let skipHighlightRows = [0, 1, 2, 5]
    
    let discountsDict: OrderedDictionary<String, String> = [
        ("Regular and Sale Items", ""),
        ("10", "d0"),
        ("20", "d1"),
        ("30", "d2"),
        ("40", "d3"),
        ("50", "d4"),
        ("60", "d5"),
        ("70", "d6")
    ]
    
    let offersDict: OrderedDictionary<String, String> = [
        ("New today", "d100"),
        ("New this week", "d101"),
        ("Free Shipping", "o0"),
        ("Special Offer", "o1"),
        ("Coupon Code", "o2")
    ]
    
    var saleCode: String?
    var selectedDiscount: [String: String]!
    var selectedOffers: [String: String]!
    
    var keys = [String]()
    
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var discountSlider: NMRangeSlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshTable", name: CustomNotifications.FilterDidClearNotification, object: nil)

        // Discount setup
        discountSlider.minimumValue = Float(minValue)
        discountSlider.maximumValue = Float(maxValue)
        discountSlider.upperValue = Float(maxValue)
        discountSlider.stepValue = 1
        discountSlider.stepValueContinuously = true
        discountSlider.upperHandleHidden = true
        
        selectedDiscount = appDelegate.filterParams["discount"] as! [String: String]
        selectedOffers = appDelegate.filterParams["offer"] as! [String: String]
        
        // Setup previous values
        if let discountKey = selectedDiscount.keys.first {
            discountSlider.lowerValue = Float(discountKey)!
            
            // Update UI
            discountSlider.setLowerValue(Float(discountKey)!, animated: false)
            updateUIForLowerValue(Int(discountKey)!)
            
        } else {
            discountSlider.lowerValue = Float(minValue)
        }
    }
    
    deinit {
        print("DiscountFilterViewController Deallocating !!!")
    }
    
    @IBAction func sliderValueChanged(sender: NMRangeSlider) {
        let index = Int(sender.lowerValue)
        
        if index == 0 {
            saleCode = nil
        } else {
            saleCode = discountsDict[discountsDict.orderedKeys[index]]
        }
        updateUIForLowerValue(index)
        
        print("SALE CODE: \(saleCode)")
        
        // Filter Stuff
        if let saleCode = saleCode {
            let discountKey = String(index)
            
            selectedDiscount.removeAll()
            selectedDiscount[discountKey] = saleCode
            
        } else {
            selectedDiscount.removeAll()
        }
        print(selectedDiscount)
        appDelegate.filterParams["discount"] = selectedDiscount
        
        // Refresh Side Tab
        NSNotificationCenter.defaultCenter().postNotificationName(CustomNotifications.FilterDidChangeNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        // Visually checkmark the selected offers.
        if !skipHighlightRows.contains(indexPath.row) && selectedOffers.keys.contains((cell.textLabel?.text)!) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let offerName = (cell?.textLabel?.text)!
        
        // Keep track of the offers
        if !selectedOffers.keys.contains(offerName) {
            if let offerCode = offersDict[offerName] {
                selectedOffers[offerName] = offerCode
                cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            
        } else {
            if let _ = selectedOffers.removeValueForKey(offerName) {
                cell?.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        print(selectedOffers)
        
        // Filter Stuff
        appDelegate.filterParams["offer"] = selectedOffers
        
        // Refresh Side Tab
        filterDidChangeNotification()
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if skipHighlightRows.contains(indexPath.row) {
            return false
        }
        
        return true
    }
    
    // MARK: - Helper methods
    
    private func updateUIForLowerValue(lowerValue: Int) {
        if lowerValue == 0 {
            discountLabel.text = discountsDict.orderedKeys[lowerValue]
        } else {
            discountLabel.text = discountsDict.orderedKeys[lowerValue] + "% on Sale"
        }
    }
    
    func refreshTable() {
        discountSlider.lowerValue = Float(minValue)
        
        // Update UI
        discountSlider.setLowerValue(Float(minValue), animated: true)
        updateUIForLowerValue(Int(minValue))
        
        selectedDiscount.removeAll()
        selectedOffers.removeAll()
        tableView.reloadData()
    }

}