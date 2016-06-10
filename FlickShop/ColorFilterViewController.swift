//
//  ColorFilterViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 11/26/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Foundation
import Crashlytics
import FirebaseAnalytics

class ColorFilterViewController: UITableViewController {
    
    private(set) var requestingData = false
    
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
    let filtersModel: FiltersModel
    
    var colorSearch = ColorSearch()
    var selectedColors: [String: String]
    
    lazy private var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.color = UIColor(white: 0.1, alpha: 0.5)
        spinner.startAnimating()
        
        return spinner
    }()
    
    private func animateSpinner(animate: Bool) {
        if animate {
            self.spinner.startAnimating()
            UIView.animateWithDuration(0.3, animations: {
                self.spinner.transform = CGAffineTransformIdentity
                self.spinner.alpha = 1.0
                }, completion: nil)
            
        } else {
            UIView.animateWithDuration(0.3, animations: {
                self.spinner.transform = CGAffineTransformMakeScale(0.1, 0.1)
                self.spinner.alpha = 0.0
                }, completion: { _ in
                    self.spinner.stopAnimating()
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        filtersModel = (App.selectedTab == .Search) ? SearchFiltersModel.sharedInstanceCopy() : FiltersModel.sharedInstanceCopy()
        selectedColors = filtersModel.filterParams["color"] as! [String: String]
        
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("ColorFilterViewController Deallocating !!!")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.FilterDidChangeNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshTable), name: CustomNotifications.FilterDidClearNotification, object: nil)
        
        // Spinner setup
        tableView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([
            spinner.centerXAnchor.constraintEqualToAnchor(tableView.centerXAnchor),
            spinner.centerYAnchor.constraintEqualToAnchor(tableView.centerYAnchor)
            ])
        
        // Request colors for the first load
//        if displayCategories.count == 0 {
//            requestDataFromShopStyle()
//        } else {
//            animateSpinner(false)
//        }
        requestDataFromShopStyle()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        GoogleAnalytics.trackScreenForName("Color Filter View")
        FIRAnalytics.logEventWithName("Color_Filter_View", parameters: nil)
        Answers.logCustomEventWithName("Color Filter View", customAttributes: nil)
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
        return colorSearch.colors.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ColorCell", forIndexPath: indexPath)
        cell.tintColor = UIColor.vendeeColor()
        
        let colorView = cell.viewWithTag(2000)
        colorView?.layer.cornerRadius = colorView!.bounds.size.width / 2
        
        let colorLabel = cell.viewWithTag(2001) as? UILabel
        let color = colorSearch.colors.objectAtIndex(indexPath.row) as! Color
        
        // Configure the cell
        if let colorHexString = colorHexDict[color.name] {
            if colorHexString == "#FFFFFF" {
                colorView?.layer.borderColor = UIColor.grayColor().CGColor
                colorView?.layer.borderWidth = 1.0
            }
            colorView?.backgroundColor = UIColor(hexString: colorHexString)
        }
        
        colorLabel?.text = color.name
        
        // Visually checkmark the selected colors.
        if selectedColors.keys.contains(color.name) {
            let checkmark = UIImageView(image: UIImage(named: "selection_checkmark"))
            checkmark.tintImageColor(UIColor.vendeeColor())
            cell.accessoryView = checkmark
            
        } else {
            cell.accessoryView = nil
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let color = colorSearch.colors.objectAtIndex(indexPath.row) as! Color
        
        // Keep track of the colors
        if !selectedColors.keys.contains(color.name) {
            let colorCode = "c\(color.id)"
            selectedColors[color.name] = colorCode
            let checkmark = UIImageView(image: UIImage(named: "selection_checkmark"))
            checkmark.tintImageColor(UIColor.vendeeColor())
            cell?.accessoryView = checkmark
            
        } else {
            if let _ = selectedColors.removeValueForKey(color.name) {
                cell?.accessoryView = nil
                cell?.accessoryType = .None
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
    
    private func requestDataFromShopStyle() {
        if requestingData { return }
        requestingData = true
        
        colorSearch.requestShopStyleColors { [weak self] success, description, lastItem in
            guard let strongSelf = self else { return }
            strongSelf.requestingData = false
            
            if !success {
                if strongSelf.colorSearch.retryCount < NumericConstants.retryLimit {
                    strongSelf.requestDataFromShopStyle()
                    strongSelf.colorSearch.incrementRetryCount()
                    print("Request Failed. Trying again...")
                    print("Request Count: \(strongSelf.colorSearch.retryCount)")
                } else {
                    strongSelf.colorSearch.resetRetryCount()
                    strongSelf.animateSpinner(false)
                    
                    // Log custom events
                    GoogleAnalytics.trackEventWithCategory("Error", action: "Network Error", label: description, value: nil)
                    FIRAnalytics.logEventWithName("Network_Error", parameters: ["Description": description])
                    Answers.logCustomEventWithName("Network Error", customAttributes: ["Description": description])
                }
                
            } else {
                strongSelf.animateSpinner(false)
                strongSelf.tableView.reloadData()
            }
        }
    }
}
