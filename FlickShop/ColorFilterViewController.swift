//
//  ColorFilterViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 11/26/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Foundation

class ColorFilterViewController: UITableViewController {
    
//    let colors = [
//        "Red": "c7",
//        "Orange": "c3",
//        "Yellow": "c4",
//        "Green": "c13",
//        "Blue": "c10",
//        "Purple": "c8",
//        "Pink": "c17",
//        "Black": "c16",
//        "White": "c15",
//        "Gray": "c14",
//        "Beige": "c20",
//        "Brown": "c1",
//        "Gold": "c18",
//        "Silver": "c19"
//    ]
    
    let colors: OrderedDictionary<String, String> = [
        ("Red", "c7"),
        ("Orange", "c3"),
        ("Yellow", "c4"),
        ("Green", "c13"),
        ("Blue", "c10"),
        ("Purple", "c8"),
        ("Pink", "c17"),
        ("Black", "c16"),
        ("White", "c15"),
        ("Gray", "c14"),
        ("Beige", "c20"),
        ("Brown", "c1"),
        ("Gold", "c18"),
        ("Silver", "c19")
    ]
    
    var keys = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return colors.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ColorCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = colors.orderedKeys[indexPath.row]
        
        return cell
    }

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
