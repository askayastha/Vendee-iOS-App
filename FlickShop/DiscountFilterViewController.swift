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
    
    let discountsDict: OrderedDictionary<String, String> = [
        ("Regular and Sale Items", "d"),
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
    var offerCodes: [String]?
    
    var offers = [String]()
    var keys = [String]()
    
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var discountSlider: NMRangeSlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        discountSlider.minimumValue = 0
        discountSlider.maximumValue = 7
        discountSlider.lowerValue = 0
        discountSlider.upperValue = 7
        
        discountSlider.stepValue = 1
        discountSlider.stepValueContinuously = true
        discountSlider.upperHandleHidden = true
    }
    
    deinit {
        print("DiscountFilterViewController Deallocating !!!")
        
        
    }
    
    @IBAction func sliderValueChanged(sender: NMRangeSlider) {
        let index: Int = Int(sender.lowerValue)
        
        if index == 0 {
            discountLabel.text = discountsDict.orderedKeys[index]
            saleCode = nil
        } else {
            discountLabel.text = discountsDict.orderedKeys[index] + "% on Sale"
            saleCode = discountsDict[discountsDict.orderedKeys[index]]
        }
        
        print("SALE CODE: \(saleCode)")
        
        // Filter Stuff
        if let saleCode = saleCode {
            if !appDelegate.filterParams.contains(saleCode) {
                appDelegate.filterParams.append(saleCode)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let offerName = (cell?.textLabel?.text)!
        
        // Keep track of the offers
        if !offers.contains(offerName) {
            offers.append(offerName)
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            
        } else {
            let removeIndex = offers.indexOf(offerName)!
            offers.removeAtIndex(removeIndex)
            cell?.accessoryType = UITableViewCellAccessoryType.None
        }
        
        // Keep track of the offer codes
        if !offers.isEmpty {
            var offerCodesArray = [String]()
            
            for offer in offers {
                let offerCode = offersDict[offer]!
                offerCodesArray.append(offerCode)
            }
            
            offerCodes = offerCodesArray
            
        } else {
            offerCodes = nil
        }
        
        print(offers)
        print(offerCodes)
        
        // Filter Stuff
        if let offerCodes = offerCodes {
            appDelegate.filterParams.appendContentsOf(offerCodes)
        }
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let skipHighlightRows = [0, 1, 2, 5]
        
        if skipHighlightRows.contains(indexPath.row) {
            return false
        }
        
        return true
    }

}
