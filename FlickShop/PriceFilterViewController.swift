//
//  PriceViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 11/25/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import NMRangeSlider

class PriceFilterViewController: UITableViewController {
    
    private let minValue = 0
    private let maxValue = 29
    
    let prices = [
        "0", "10", "25", "50", "75", "100", "125", "150", "200", "250",
        "300", "350", "400", "500", "600", "700", "800", "900", "1000", "1250",
        "1500", "1750", "2000", "2250", "2500", "3000", "3500", "4000", "4500", "5000+"
    ]
    
    var priceRangeCode: String?
    
    @IBOutlet weak var minPriceLabel: UILabel!
    @IBOutlet weak var maxPriceLabel: UILabel!
    @IBOutlet weak var priceRangeSlider: NMRangeSlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        priceRangeSlider.minimumValue = Float(minValue)
        priceRangeSlider.maximumValue = Float(maxValue)
        priceRangeSlider.lowerValue = Float(minValue)
        priceRangeSlider.upperValue = Float(maxValue)
        priceRangeSlider.minimumRange = 1
        priceRangeSlider.stepValue = 1
        priceRangeSlider.stepValueContinuously = true
    }
    
    @IBAction func sliderValueChanged(sender: NMRangeSlider) {
        let minIndex: Int = Int(sender.lowerValue)
        let maxIndex: Int = Int(sender.upperValue)
        
        minPriceLabel.text = "$" + prices[minIndex]
        maxPriceLabel.text = "$" + prices[maxIndex]
        
        if minIndex == minValue && maxIndex == maxValue {
            priceRangeCode = nil
        } else {
            priceRangeCode = "p\(minIndex + 20):\(maxIndex + 20)"
        }
        
        print("PRICE RANGE CODE: \(priceRangeCode)")
        
        // Filter Stuff
        if let priceRangeCode = priceRangeCode {
            appDelegate.filterParams["price"] = priceRangeCode
        } else {
            appDelegate.filterParams["price"] = nil
        }
        
        // Refresh Side Tab
        NSNotificationCenter.defaultCenter().postNotificationName(CustomNotifications.FilterDidChangeNotification, object: nil)
    }
    
    deinit {
        print("PriceFilterViewController Deallocating !!!")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

}
