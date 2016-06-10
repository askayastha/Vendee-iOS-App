//
//  SearchViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 6/8/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics
import FirebaseAnalytics

class SearchViewController: UIViewController {
    
    struct SearchViewCellIdentifiers {
        static let topSearchCell = "TopSearchCell"
        static let headerCell = "HeaderCell"
    }
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var searchController: UISearchController!
    let topSearchesModel = TopSearchesModel.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        SearchFiltersModel.sharedInstance().productCategory = "Women:women"
        SearchFiltersModel.sharedInstanceCopy().productCategory = "Women:women"

        setupView()
        tableView.reloadData()
        
        // Log screen views
        GoogleAnalytics.trackScreenForName("Search View")
        FIRAnalytics.logEventWithName("Search_View", parameters: nil)
        Answers.logCustomEventWithName("Search View", customAttributes: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupView() {
        // SearchController setup
        searchController = UISearchController(searchResultsController: nil)
        
        let searchBar = searchController.searchBar
        searchBar.delegate = self
        searchBar.placeholder = "Search everything on Vendee"
        searchBar.barTintColor = UIColor.whiteColor()
        searchBar.layer.borderWidth = 1.0
        searchBar.layer.borderColor = UIColor.whiteColor().CGColor
        
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).backgroundColor = UIColor(hexString: "#F1F2F3")
        
        headerView.addSubview(searchBar)
        searchController.dimsBackgroundDuringPresentation = false
        
        // TableView setup
        tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: SearchViewCellIdentifiers.headerCell)
    }
}

// MARK: - Table view data source

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topSearchesModel.topSearches.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SearchViewCellIdentifiers.topSearchCell, forIndexPath: indexPath)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.textLabel?.text = "Top Searches:"
            cell.textLabel?.font = UIFont(name: "FunctionPro-Medium", size: 14.0)!
            cell.textLabel?.textColor = UIColor(hexString: "#B0B3C0")
            
        } else {
            cell.textLabel?.text = topSearchesModel.topSearches[indexPath.row - 1].keyword
            cell.textLabel?.font = UIFont(name: "FunctionPro-Medium", size: 16.0)!
            cell.textLabel?.textColor = UIColor(hexString: "#4A4A4A")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier(SearchViewCellIdentifiers.headerCell)
        cell?.backgroundView = UIView()
        cell?.backgroundView?.backgroundColor = UIColor(hexString: "#DFDFDF")
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let topSearchText = (cell?.textLabel?.text)!
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let browseVC = mainStoryboard.instantiateViewControllerWithIdentifier("ContainerBrowseViewController") as? ContainerBrowseViewController
        
        if let controller = browseVC {
            controller.searchText = topSearchText
            resetSearchFilters()
            
            // Log custom events
            GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped Top Search", label: topSearchText, value: nil)
            FIRAnalytics.logEventWithName("Tapped_Top_Search", parameters: ["Keyword": topSearchText])
            Answers.logCustomEventWithName("Tapped Top Search", customAttributes: ["Keyword": topSearchText])
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 && indexPath.row == 0 {
            return nil
        }
        
        return indexPath
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let browseVC = mainStoryboard.instantiateViewControllerWithIdentifier("ContainerBrowseViewController") as? ContainerBrowseViewController
        
        if let controller = browseVC {
            let searchText = searchController.searchBar.text!
            controller.searchText = searchText
            searchController.active = false
            resetSearchFilters()
            
            // Log custom events
            GoogleAnalytics.trackEventWithCategory("UI Action", action: "Searched Text", label: searchText, value: nil)
            FIRAnalytics.logEventWithName("Searched_Text", parameters: ["Keyword": searchText])
            Answers.logCustomEventWithName("Searched Text", customAttributes: ["Keyword": searchText])
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func resetSearchFilters() {
        SearchFiltersModel.sharedInstance().resetFilters()
        SearchFiltersModel.sharedInstanceCopy().resetFilters()
    }
}
