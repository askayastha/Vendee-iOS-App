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
    
//    let discounts = [
//        "Regular and Sale Items": "d",
//        "10": "d0",
//        "20": "d1",
//        "30": "d2",
//        "40": "d3",
//        "50": "d4",
//        "60": "d5",
//        "70": "d6"
//    ]
    
    let discounts: OrderedDictionary<String, String> = [
        ("Regular and Sale Items", "d"),
        ("10", "d0"),
        ("20", "d1"),
        ("30", "d2"),
        ("40", "d3"),
        ("50", "d4"),
        ("60", "d5"),
        ("70", "d6")
    ]
    
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
    
    @IBAction func sliderValueChanged(sender: NMRangeSlider) {
        let index: Int = Int(sender.lowerValue)
        
        if index == 0 {
            discountLabel.text = discounts.orderedKeys[index]
        } else {
            discountLabel.text = discounts.orderedKeys[index] + "% on Sale"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
