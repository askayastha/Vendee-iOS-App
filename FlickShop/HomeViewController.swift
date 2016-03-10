//
//  HomeViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 10/23/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let categories = CategoriesModel.sharedInstance().categories

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        GoogleAnalytics.trackScreenForName("Home View")
        Answers.logCustomEventWithName("Home View", customAttributes: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "BrowseCategory" {
            let controller = segue.destinationViewController as! ContainerBrowseViewController
            let indexPath = sender as! NSIndexPath
            
            controller.productCategory = categories[indexPath.item].keyword
        }
    }

}

extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoryCell", forIndexPath: indexPath) as! CategoryCell
        
        cell.category = categories[indexPath.item]
        
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let categoryName = categories[indexPath.item].name
        let categoryId = categories[indexPath.item].keyword
        let oldCategoryName = FiltersModel.sharedInstance().productCategory?.componentsSeparatedByString(":").first!
        
        if categoryName != oldCategoryName {
            FiltersModel.sharedInstance().resetFilters()
            FiltersModel.sharedInstanceCopy().resetFilters()
        }
        FiltersModel.sharedInstance().productCategory = "\(categoryName):\(categoryId)"
        FiltersModel.sharedInstanceCopy().productCategory = "\(categoryName):\(categoryId)"
        
        // Log custom events
        GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped Category", label: categoryName, value: nil)
        Answers.logCustomEventWithName("Tapped Category", customAttributes: ["Category": categoryName])
        
        performSegueWithIdentifier("BrowseCategory", sender: indexPath)
    }
}

extension HomeViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if navigationController?.viewControllers.count > 1 {
            return true
        }
        
        return false
    }
}