//
//  ColorFilterViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 11/26/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Foundation

class ColorFilterViewController: UITableViewController {
    
    let colorHexDict: OrderedDictionary<String, String> = [
        ("Red", "#DA0000"),
        ("Orange", "#E58200"),
        ("Yellow", "#DFD03B"),
        ("Green", "#009C1C"),
        ("Blue", "#40289A"),
        ("Purple", "#A601A9"),
        ("Pink", "#E11683"),
        ("Black", "#000000"),
        ("White", "#FFFFFF"),
        ("Gray", "#565656"),
        ("Beige", "#C1A76F"),
        ("Brown", "#76481E"),
        ("Gold", "#FFC900"),
        ("Silver", "#CCCCCC")
    ]
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
    let filtersModel = FiltersModel.sharedInstance()
    
    var selectedColors: [String: String]!
    
    deinit {
        print("ColorFilterViewController Deallocating !!!")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.FilterDidChangeNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshTable", name: CustomNotifications.FilterDidClearNotification, object: nil)
        
        selectedColors = filtersModel.filterParams["color"] as! [String: String]
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
        
        let colorView = cell.viewWithTag(2000)
        let colorLabel = cell.viewWithTag(2001) as? UILabel
        let colorHexString = colorHexDict.orderedValues[indexPath.row]
        
        if colorHexString == "#FFFFFF" {
            colorView?.layer.borderColor = UIColor.blackColor().CGColor
            colorView?.layer.borderWidth = 1.0
        }
        colorView?.backgroundColor = UIColor(hexString: colorHexString)
        colorLabel?.text = colorsDict.orderedKeys[indexPath.row]
        
        // Visually checkmark the selected colors.
        if selectedColors.keys.contains(colorsDict.orderedKeys[indexPath.row]) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let colorName = colorsDict.orderedKeys[indexPath.row]
        
        // Keep track of the colors
        if !selectedColors.keys.contains(colorName) {
            if let colorCode = colorsDict[colorName] {
                selectedColors[colorName] = colorCode
                cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            
        } else {
            if let _ = selectedColors.removeValueForKey(colorName) {
                cell?.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        print(selectedColors)
        
        // Filter Stuff
        filtersModel.filterParams["color"] = selectedColors
        
        // Refresh Side Tab
        CustomNotifications.filterDidChangeNotification()
    }
    
    func refreshTable() {
        selectedColors.removeAll()
        tableView.reloadData()
    }

}
	