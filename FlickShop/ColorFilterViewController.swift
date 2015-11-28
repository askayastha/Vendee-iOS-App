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
    
//    let colorsDict = [
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
    
    let colorsDict: OrderedDictionary<String, String> = [
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
    var colors = [String]()
    var colorCodes: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    deinit {
        if let colorCodes = colorCodes {
            appDelegate.filterParams.appendContentsOf(colorCodes)
        }
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
        return colorsDict.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ColorCell", forIndexPath: indexPath)
        
        cell.accessoryType = UITableViewCellAccessoryType.None
        cell.textLabel?.text = colorsDict.orderedKeys[indexPath.row]
        
        // Visually checkmark the selected colors.
        if colors.contains((cell.textLabel?.text)!) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let colorName = (cell?.textLabel?.text)!
        
        // Keep track of the colors
        if !colors.contains(colorName) {
            colors.append(colorName)
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            
        } else {
            let removeIndex = colors.indexOf(colorName)!
            colors.removeAtIndex(removeIndex)
            cell?.accessoryType = UITableViewCellAccessoryType.None
        }
        
        // Keep track of the color codes
        if !colors.isEmpty {
            var colorCodesArray = [String]()
            
            for color in colors {
                let colorCode = colorsDict[color]!
                colorCodesArray.append(colorCode)
            }
            
            colorCodes = colorCodesArray
            
        } else {
            colorCodes = nil
        }
        
        print(colors)
        print(colorCodes)
    }

}
