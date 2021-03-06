//
//  BrowseViewController.swift
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
import FirebaseAnalytics
import NVActivityIndicatorView

class BrowseViewController: UICollectionViewController {
    
    private(set) var requestingData = false
    private(set) var populatingData = false
    private(set) var productCount = 0
    
    let brandsModel = BrandsModel.sharedInstance()
    let filtersModel: FiltersModel
    
    weak var delegate: SwipeDelegate?
    var animateSpinner: ((Bool)->())?
    var search = Search()
    var scout: PhotoScout
    var productCategory: String!
    var searchText: String!
    var itemsCountLabel: UILabel!
    var loadMoreIndicator: NVActivityIndicatorView!
    
    struct BrowseViewCellIdentifiers {
        static let customProductCell = "CustomPhotoCell"
        static let headerCell = "HeaderCell"
        static let footerCell = "FooterCell"
    }
    
    deinit {
        print("Deallocating BrowseViewController!")
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.NetworkDidChangeToReachableNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        filtersModel = (App.selectedTab == .Search) ? SearchFiltersModel.sharedInstance() : FiltersModel.sharedInstance()
        search = Search()
        scout = PhotoScout(products: search.products, totalItems: search.totalItems)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(populateData), name: CustomNotifications.NetworkDidChangeToReachableNotification, object: nil)
        setupView()
        requestData()
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
        CustomNotifications.filterDidApplyNotification()
        logEventsForFilter()
        
        (App.selectedTab == .Search) ? SearchFiltersModel.synchronizeFiltersModel() : FiltersModel.synchronizeFiltersModel()
        search.resetSearch()
        productCount = 0
        
        scout.cancelled = true
        populatingData = false
        scout = PhotoScout(products: search.products, totalItems: 0)
        
        // Reset content size of the collection view
        if let layout = collectionView!.collectionViewLayout as? TwoColumnLayout {
            layout.reset()
        }
        collectionView!.reloadData()
        animateSpinner?(true)
        requestData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FlickCategory" {
            let controller = segue.destinationViewController as! ContainerFlickViewController
            let indexPath = sender as! NSIndexPath
            
            controller.search = search
            controller.indexPath = indexPath
            controller.productCategory = productCategory
            controller.searchText = searchText
            controller.hidesBottomBarWhenPushed = true
        }
    }
    
    // MARK: - Helper methods
    
    private func setupView() {
        
        // Swipe gesture setup
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp(_:)))
        swipeUpGesture.delegate = self
        swipeUpGesture.direction = .Up
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown(_:)))
        swipeDownGesture.delegate = self
        swipeDownGesture.direction = .Down
        
        collectionView!.addGestureRecognizer(swipeUpGesture)
        collectionView!.addGestureRecognizer(swipeDownGesture)
        
        collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: BrowseViewCellIdentifiers.headerCell)
        collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: BrowseViewCellIdentifiers.footerCell)
        collectionView!.contentInset = UIEdgeInsets(top: 0, left: 4, bottom: 64, right: 4)
//        collectionView!.contentInset = UIEdgeInsets(top: -16, left: 4, bottom: 4, right: 4)
//        collectionView!.contentInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        
        if let layout = collectionView!.collectionViewLayout as? TwoColumnLayout {
            layout.delegate = self
            layout.headerReferenceSize = CGSize(width: collectionView!.bounds.size.width, height: 50)
            layout.footerReferenceSize = CGSize(width: collectionView!.bounds.size.width, height: 50)
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
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        scout.populatePhotoSizesFromIndex(index, withLimit: NumericConstants.populateLimit) { [weak self] success, fromIndex, lastIndex in
            guard let strongSelf = self else { return }
            guard success else {
                print("GUARDING SUCCESS")
                strongSelf.animateSpinner?(false)
                strongSelf.populatingData = false
                strongSelf.populatePhotosFromIndex(fromIndex)
                return
            }
            strongSelf.productCount += lastIndex - fromIndex
            let indexPaths = (fromIndex..<lastIndex).map { NSIndexPath(forItem: $0, inSection: 0) }
            strongSelf.loadMoreIndicator.stopAnimation()
            
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
    
    private func requestData() {
        if let searchText = searchText {
            requestDataFromShopStyleForText(searchText)
        } else {
            requestDataFromShopStyleForCategory(productCategory)
        }
    }
    
    private func requestDataFromShopStyleForText(text: String!) {
        if requestingData { return }
        guard let text = text else { return }
        
        requestingData = true
        search.requestShopStyleForText(text, andItemOffset: search.lastItem, withLimit: NumericConstants.requestLimit) { [weak self] success, description, lastItem in
            
            guard let strongSelf = self else { return }
            strongSelf.requestingData = false
            print("Products count: \(lastItem)")
            
            if !success {
                if strongSelf.search.retryCount < NumericConstants.retryLimit {
                    strongSelf.requestDataFromShopStyleForText(text)
                    strongSelf.search.incrementRetryCount()
                    print("Request Failed. Trying again...")
                    print("Request Count: \(strongSelf.search.retryCount)")
                    
                } else {
                    strongSelf.search.resetRetryCount()
                    strongSelf.animateSpinner?(false)
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    TSMessage.addCustomDesignFromFileWithName(Files.TSDesignFileName)
                    TSMessage.showNotificationWithTitle("Network Error", subtitle: description, type: .Error)
                    
                    // Log custom events
                    GoogleAnalytics.trackEventWithCategory("Error", action: "Network Error", label: description, value: nil)
                    FIRAnalytics.logEventWithName("Network_Error", parameters: ["Description": description])
                    Answers.logCustomEventWithName("Network Error", customAttributes: ["Description": description])
                }
                
            } else {
                strongSelf.itemsCountLabel.text = "\(strongSelf.search.totalItems) Items"
                strongSelf.scout.totalItems = strongSelf.search.totalItems
                
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
    
    private func requestDataFromShopStyleForCategory(category: String!) {
        if requestingData { return }
        guard let category = category else { return }
        
        requestingData = true
        search.requestShopStyleForItemOffset(search.lastItem, withLimit: NumericConstants.requestLimit, forCategory: category) { [weak self] success, description, lastItem in
            
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
                    
                    // Log custom events
                    GoogleAnalytics.trackEventWithCategory("Error", action: "Network Error", label: description, value: nil)
                    FIRAnalytics.logEventWithName("Network_Error", parameters: ["Description": description])
                    Answers.logCustomEventWithName("Network Error", customAttributes: ["Description": description])
                }
                
            } else {
                strongSelf.itemsCountLabel.text = "\(strongSelf.search.totalItems) Items"
                strongSelf.scout.totalItems = strongSelf.search.totalItems
                
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
        cell.product = product
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let brand = product.brand {
                let brandName = JSON(brand)["name"].string
                let brandImageURL = self.brandsModel.brands.filter { $0.nickname == brandName }.first?.picURL
                
                dispatch_async(dispatch_get_main_queue()) {
                    if let imageURL = brandImageURL {
                        cell.headerImageView.pin_setImageFromURL(NSURL(string: imageURL)!)
                    }
                }
            } else if let retailer = product.retailer {
                let retailerName = JSON(retailer)["name"].string
                let retailerImageURL = self.brandsModel.brands.filter { $0.nickname == retailerName }.first?.picURL
                
                dispatch_async(dispatch_get_main_queue()) {
                    if let imageURL = retailerImageURL {
                        cell.headerImageView.pin_setImageFromURL(NSURL(string: imageURL)!)
                    }
                }
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: BrowseViewCellIdentifiers.headerCell, forIndexPath: indexPath)
            
            // Reuse views
            if cell.subviews.count == 0 {
                let titleLabel = UILabel()
                titleLabel.font = UIFont(name: "CircularSPUI-Bold", size: 16.0)!
                titleLabel.textColor = UIColor(hexString: "#353535")
                titleLabel.textAlignment = .Center
                
                if let searchText = searchText {
                    titleLabel.text = searchText
                } else {
                    titleLabel.text = filtersModel.productCategory?.componentsSeparatedByString(":").first!
                }
                
                let itemsCountLabel = UILabel()
                itemsCountLabel.font = UIFont(name: "CircularSPUI-Book", size: 12.0)!
                itemsCountLabel.textColor = UIColor(hexString: "#353535")
                itemsCountLabel.textAlignment = .Center
                
                let headerView = UIStackView(arrangedSubviews: [titleLabel, itemsCountLabel])
                headerView.axis = .Vertical
                headerView.spacing = -2.0
                cell.addSubview(headerView)
                
                headerView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activateConstraints([
                    headerView.centerXAnchor.constraintEqualToAnchor(cell.centerXAnchor),
                    headerView.centerYAnchor.constraintEqualToAnchor(cell.centerYAnchor)
                    ])
            }
            
            let headerView = cell.subviews[0] as! UIStackView
            itemsCountLabel = headerView.arrangedSubviews[1] as! UILabel
            itemsCountLabel.text = "\(search.totalItems) Items"
            
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: BrowseViewCellIdentifiers.footerCell, forIndexPath: indexPath)
            
            // Reuse views
            if cell.subviews.count == 0 {
                let spinnerSize = CGFloat(24)
                let frame = CGRect(x: (collectionView.bounds.size.width - spinnerSize) / 2, y: (50 - spinnerSize) / 2, width: spinnerSize, height: spinnerSize)
                loadMoreIndicator = NVActivityIndicatorView(frame: frame, type: .BallPulse, color: UIColor(white: 0.1, alpha: 0.5))
                loadMoreIndicator.hidesWhenStopped = true
                
                cell.addSubview(loadMoreIndicator)
                return cell
            }
            
            // Don't show load more indicator when all the items are loaded.
            if productCount == search.totalItems {
                if let layout = collectionView.collectionViewLayout as? TwoColumnLayout {
                    layout.footerReferenceSize = CGSize(width: 0, height: 0)
                }
            } else {
                loadMoreIndicator.startAnimation()
            }
            
            return cell
        }
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
//    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let product = search.products.objectAtIndex(indexPath.item) as! Product
        
        // Log custom events
        GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped Product", label: product.id, value: nil)
        FIRAnalytics.logEventWithName("Tapped_Product", parameters: getAttributesForProduct(product) as? [String: NSObject])
        Answers.logCustomEventWithName("Tapped Product", customAttributes: getAttributesForProduct(product))
        
        performSegueWithIdentifier("FlickCategory", sender: indexPath)
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        print("Item \(indexPath.item)")
        if search.lastItem - indexPath.item == 5 {
            print("##### WILL DISPLAY CELL: \(indexPath.item) - NEW REQUEST ######")
            requestData()
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
