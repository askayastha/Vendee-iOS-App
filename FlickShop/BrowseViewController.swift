//
//  BrowseCollectionViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 10/23/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import TSMessages
import SwiftyJSON
import Crashlytics

struct BrowseViewCellIdentifiers {
    static let customProductCell = "CustomPhotoCell"
}

class BrowseViewController: UICollectionViewController {
    
    private(set) var requestingData = false
    private(set) var populatingData = false
    private(set) var productCount = 0
    
    var animateSpinner: ((Bool)->())?
    weak var delegate: SwipeDelegate?
    var search = Search()
    let brands = BrandsModel.sharedInstance().brands
    let filtersModel = FiltersModel.sharedInstance()
    var scout: PhotoScout
    var productCategory: String!
    
    deinit {
        print("Deallocating BrowseViewController!")
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.NetworkDidChangeToReachableNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        search = Search()
        scout = PhotoScout(products: search.products)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "populateData", name: CustomNotifications.NetworkDidChangeToReachableNotification, object: nil)
        setupView()
        requestDataFromShopStyleForCategory(productCategory)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("BrowseViewControllerWillAppear")
        
        // Prevent data population when a request is in progress
        if !requestingData { populateData() }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindFilterApply(segue: UIStoryboardSegue) {
        logEventsForFilter()
        
        FiltersModel.synchronizeFiltersModel()
        search.resetSearch()
        productCount = 0
        
        scout.cancelled = true
        populatingData = false
        scout = PhotoScout(products: search.products)
        
        // Reset content size of the collection view
        if let layout = collectionView!.collectionViewLayout as? TwoColumnLayout {
            layout.reset()
        }
        collectionView!.reloadData()
        animateSpinner?(true)
        requestDataFromShopStyleForCategory(productCategory)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FlickCategory" {
            let controller = segue.destinationViewController as! ContainerFlickViewController
            let indexPath = sender as! NSIndexPath
            
            controller.search = search
            controller.indexPath = indexPath
            controller.productCategory = productCategory
            controller.hidesBottomBarWhenPushed = true
        }
    }
    
    // MARK: - Helper methods
    
    private func setupView() {
        
        // Swipe gesture setup
        let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: "swipedUp:")
        swipeUpRecognizer.delegate = self
        swipeUpRecognizer.direction = .Up
        
        let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: "swipedDown:")
        swipeDownRecognizer.delegate = self
        swipeDownRecognizer.direction = .Down
        
        collectionView!.addGestureRecognizer(swipeUpRecognizer)
        collectionView!.addGestureRecognizer(swipeDownRecognizer)
        
        collectionView!.contentInset = UIEdgeInsets(top: 0, left: 4, bottom: 64, right: 4)
//        collectionView!.contentInset = UIEdgeInsets(top: -16, left: 4, bottom: 4, right: 4)
//        collectionView!.contentInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        
        if let layout = collectionView!.collectionViewLayout as? TwoColumnLayout {
            layout.delegate = self
        }
    }
    
    func populateData() {
        print("Browse PopulateData Count: \(productCount)")
        if search.lastItem - productCount > 0 && appDelegate.networkManager!.isReachable {
            populatePhotosFromIndex(productCount)
        } else if !appDelegate.networkManager!.isReachable {
            animateSpinner?(false)
            TSMessage.addCustomDesignFromFileWithName(Files.TSDesignFileName)
            TSMessage.showNotificationWithTitle("Network Error", subtitle: "Check your internet connection and try again later.", type: .Error)
        } else {
            animateSpinner?(false)
        }
    }
    
    private func populatePhotosFromIndex(index: Int) {
        if populatingData { return }
        
        print("populatePhotosFromIndex")
        populatingData = true
        
        scout.populatePhotoSizesFromIndex(index, withLimit: NumericConstants.populateLimit) { [weak self] success, lastIndex in
            guard let strongSelf = self else { return }
            guard success else {
                print("GUARDING SUCCESS")
                strongSelf.animateSpinner?(false)
                strongSelf.populatingData = false
                strongSelf.populatePhotosFromIndex(lastIndex)
                return
            }
            strongSelf.productCount += NumericConstants.populateLimit
            let fromIndex = lastIndex - NumericConstants.populateLimit
            let indexPaths = (fromIndex..<lastIndex).map { NSIndexPath(forItem: $0, inSection: 0) }
            
            strongSelf.collectionView!.performBatchUpdates({
                print("READY FOR INSERTS: \(lastIndex)")
                strongSelf.collectionView!.insertItemsAtIndexPaths(indexPaths)
                }, completion: { success in
                    strongSelf.populatingData = false
                    strongSelf.animateSpinner?(false)
                    
                    if success && lastIndex != strongSelf.search.lastItem {
                        strongSelf.populatePhotosFromIndex(lastIndex)
                    } else {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    }
                    print("INSERTS SUCCESSFUL")
                    
            })
        }
    }
    
    private func requestDataFromShopStyleForCategory(category: String!) {
        if requestingData { return }
        guard let category = category else { return }
        
        requestingData = true
        search.parseShopStyleForItemOffset(search.lastItem, withLimit: NumericConstants.requestLimit, forCategory: category) { [weak self] success, description, lastItem in
            
            guard let strongSelf = self else { return }
            strongSelf.requestingData = false
            print("Products count: \(lastItem)")
            
            if !success {
                if strongSelf.search.retryCount < NumericConstants.retryLimit {
                    strongSelf.requestDataFromShopStyleForCategory(category)
                    strongSelf.search.incrementRetryCount()
                    print("Request Failed. Trying again...")
                    print("Request Count: \(strongSelf.search.retryCount)")
                    
                } else {
                    strongSelf.search.resetRetryCount()
                    strongSelf.animateSpinner?(false)
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    TSMessage.addCustomDesignFromFileWithName(Files.TSDesignFileName)
                    TSMessage.showNotificationWithTitle("Network Error", subtitle: description, type: .Error)
                }
                
            } else {                
                if lastItem > 0 {
                    strongSelf.populatePhotosFromIndex(strongSelf.productCount)
                } else {
                    strongSelf.animateSpinner?(false)
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    TSMessage.addCustomDesignFromFileWithName(Files.TSDesignFileName)
                    TSMessage.showNotificationWithTitle("No results found.", type: .Warning)
                }
            }
        }
    }
}

extension BrowseViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productCount
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(BrowseViewCellIdentifiers.customProductCell, forIndexPath: indexPath) as! CustomPhotoCell
        
        // Configure the cell
        let product = search.products.objectAtIndex(indexPath.item) as! Product
        
        cell.headerImageView.layer.borderColor = UIColor(hexString: "#DFDFDF")?.CGColor
        cell.headerImageView.layer.borderWidth = 0.5
        cell.headerImageView.layer.cornerRadius = 5.0
        cell.headerImageView.layer.masksToBounds = true
        cell.topImageViewLineSeparatorHeightConstraint.constant = 0.5
        cell.product = product
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let brand = product.brand {
                let brandName = JSON(brand)["name"].string
                let brandImageURL = self.brands.filter { $0.nickname == brandName }.first?.picURL
                
                dispatch_async(dispatch_get_main_queue()) {
                    if let imageURL = brandImageURL {
                        cell.headerImageView.pin_setImageFromURL(NSURL(string: imageURL)!)
                    }
                }
            } else if let retailer = product.retailer {
                let retailerName = JSON(retailer)["name"].string
                let retailerImageURL = self.brands.filter { $0.nickname == retailerName }.first?.picURL
                
                dispatch_async(dispatch_get_main_queue()) {
                    if let imageURL = retailerImageURL {
                        cell.headerImageView.pin_setImageFromURL(NSURL(string: imageURL)!)
                    }
                }
            }
        }
        
        return cell
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
//    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let product = search.products.objectAtIndex(indexPath.item) as! Product
        
        // Log custom events
        GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped Product", label: product.id, value: nil)
        Answers.logCustomEventWithName("Tapped Product", customAttributes: getAttributesForProduct(product))
        
        performSegueWithIdentifier("FlickCategory", sender: indexPath)
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        print("Item \(indexPath.item)")
        if search.lastItem - indexPath.item == 5 {
            print("##### WILL DISPLAY CELL: \(indexPath.item) - NEW REQUEST ######")
            requestDataFromShopStyleForCategory(productCategory)
        }
    }}

extension BrowseViewController: TwoColumnLayoutDelegate {
    
    func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        let product = search.products.objectAtIndex(indexPath.item) as! Product
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        var rect = CGRectZero
        
        if let imageSize = product.smallImageSize {
            rect = AVMakeRectWithAspectRatioInsideRect(imageSize, boundingRect)
        }
        
        return ceil(rect.size.height)
        // return rect.size.height
    }
}

extension BrowseViewController: UIGestureRecognizerDelegate {
    
    func swipedUp(recognizer: UISwipeGestureRecognizer) {
        print("swipedUp")
        delegate?.swipedUp()
    }
    
    func swipedDown(recognizer: UISwipeGestureRecognizer) {
        print("swipedDown")
        delegate?.swipedDown()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension BrowseViewController: TSMessageViewProtocol {
    
    func customizeMessageView(messageView: TSMessageView!) {
        messageView.alpha = 0.8
    }
}
