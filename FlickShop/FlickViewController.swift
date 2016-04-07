//
//  FlickCollectionViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 9/12/15.
//  Copyright (c) 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
import SafariServices
import AVFoundation
import TSMessages
import SwiftyJSON
import Crashlytics

//struct FlickViewConstants {
//    static var width = UIScreen.mainScreen().bounds.width
//    static var height = UIScreen.mainScreen().bounds.height
//}

protocol ScrollEventsDelegate: class {
    func didScroll()
    func didEndDecelerating()
}

class FlickViewController: UICollectionViewController {
    
    private(set) var loadingHUDPresent = false
    private(set) var requestingData = false
    private(set) var flickCount = 0
    private var moreRequests: Bool {
        return productCategory != nil
    }
    
    var search: Search!
    var brands = BrandsModel.sharedInstance().brands
    var indexPath: NSIndexPath?
    var productCategory: String!
    weak var delegate: ScrollEventsDelegate?
    let transition = PopAnimationController()
    var selectedImage: UIImageView?
    
    struct FlickViewCellIdentifiers {
        static let flickPageCell = "FlickPageCell"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = indexPath {
            collectionView!.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: false)
        }
    }
    
    deinit {
        print("Deallocating FlickViewController!")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        FlickViewConstants.width = collectionView!.bounds.width
//        FlickViewConstants.height = collectionView!.bounds.height

        // Do any additional setup after loading the view.
        let nib = UINib(nibName: FlickViewCellIdentifiers.flickPageCell, bundle: nil)
        collectionView!.registerNib(nib, forCellWithReuseIdentifier: FlickViewCellIdentifiers.flickPageCell)
        
        collectionView!.backgroundColor = UIColor.lightGrayColor()
//        collectionView!.backgroundColor = UIColor(red: 96/255, green: 99/255, blue: 104/255, alpha: 1.0)
        collectionView!.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Log custom events
        Answers.logCustomEventWithName("Flick Session", customAttributes: ["Count": flickCount])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return search.products.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FlickViewCellIdentifiers.flickPageCell, forIndexPath: indexPath) as! FlickPageCell
        
        // Configure the cell
        let product = search.products.objectAtIndex(indexPath.item) as! Product
        
        cell.favorited = FavoritesModel.sharedInstance().containsProductId(product.id) ? true : false
        cell.scrollViewHeightConstraint.constant = getImageViewHeight()
        cell.bottomImageViewLineSeparatorHeightConstraint.constant = 0.5
        cell.topImageViewLineSeparatorHeightConstraint.constant = 0.5
        
        cell.product = product
        cell.delegate = self
        
        // Update header image view
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let brand = product.brand {
                let brandName = JSON(brand)["name"].string
                let brandImageURL = self.brands.filter { $0.nickname == brandName }.first?.picURL
                
                if let imageURL = brandImageURL {
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.headerImageView.pin_setImageFromURL(NSURL(string: imageURL)!)
                    }
                }
            } else if let retailer = product.retailer {
                let retailerName = JSON(retailer)["name"].string
                let retailerImageURL = self.brands.filter { $0.nickname == retailerName }.first?.picURL
                
                if let imageURL = retailerImageURL {
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.headerImageView.pin_setImageFromURL(NSURL(string: imageURL)!)
                    }
                }
            }
        }
    
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        print("Item \(indexPath.item)")
        if moreRequests && search.lastItem - indexPath.item == 1 {
            print("##### WILL DISPLAY CELL: \(indexPath.item) - NEW REQUEST ######")
            requestDataFromShopStyleForCategory(productCategory)
        }
        
        flickCount += 1
    }
    
    
    // MARK: - Helper Methods
    
    private func requestDataFromShopStyleForCategory(category: String) {
        
        if requestingData { return }

        if !loadingHUDPresent {
            let loadingHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
            loadingHUD.color = UIColor(white: 0.2, alpha: 0.7)
            loadingHUD.userInteractionEnabled = false
        }
        
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
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    MBProgressHUD.hideAllHUDsForView(strongSelf.view, animated: true)
                    strongSelf.loadingHUDPresent = false
                    TSMessage.addCustomDesignFromFileWithName(Files.TSDesignFileName)
                    TSMessage.showNotificationWithTitle("Network Error", subtitle: description, type: .Error)
                    
                    // Log custom events
                    GoogleAnalytics.trackEventWithCategory("Error", action: "Network Error", label: description, value: nil)
                    Answers.logCustomEventWithName("Network Error", customAttributes: ["Description": description])
                }
                
            } else {
                if strongSelf.search.lastItem != strongSelf.search.totalItems {
                    strongSelf.collectionView!.reloadData()
                }
                MBProgressHUD.hideAllHUDsForView(strongSelf.view, animated: true)
                strongSelf.loadingHUDPresent = false
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
        }
    }
    
    private func getImageViewHeight() -> CGFloat {
        print("CollectionView Height: \(collectionView!.bounds.size.height)")
        print("Screen Height: \(ScreenConstants.height)")
        
        let headerView: CGFloat = 60
        let imageViewGap: CGFloat = 20
        let actionView: CGFloat = 52
        
        return ScreenConstants.height - headerView - imageViewGap - actionView
    }
}

extension FlickViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        delegate?.didScroll()
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        delegate?.didEndDecelerating()
    }
}

extension FlickViewController: FlickPageCellDelegate {
    
    func favoriteState(state: FavoriteState, forProduct product: Product) {
        switch state {
        case .Selected:
            FavoritesModel.sharedInstance().addFavoriteProduct(product)
            
            // Show HUD
            let favoritedHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
            favoritedHUD.labelText = "Favorited on Vendee"
            favoritedHUD.labelFont = UIFont(name: "FaktFlipboard-Medium", size: 16.0)!
            favoritedHUD.mode = .CustomView
            favoritedHUD.color = UIColor(white: 0.2, alpha: 0.7)
            favoritedHUD.minShowTime = 1.5
            favoritedHUD.margin = 10.0
            favoritedHUD.userInteractionEnabled = false
            MBProgressHUD.hideHUDForView(view, animated: true)
            
            // Log custom events
            var attributes = getAttributesForProduct(product)
            attributes["State"] = "Selected"
            Answers.logCustomEventWithName("Tapped Favorites", customAttributes: attributes)
            
        case .Unselected:
            FavoritesModel.sharedInstance().removeFavoriteProduct(product)
            
            // Log custom events
            var attributes = getAttributesForProduct(product)
            attributes["State"] = "Unselected"
            Answers.logCustomEventWithName("Tapped Favorites", customAttributes: attributes)
        }        
    }
    
    func openItemInStoreWithProduct(product: Product) {
        guard let clickURL = product.clickURL else { return }
        guard let url = NSURL(string: clickURL) else { return }
        
        // Log custom events
        Answers.logCustomEventWithName("Tapped Buy", customAttributes: getAttributesForProduct(product))
        
        indexPath = collectionView!.indexPathsForVisibleItems().first
            
        let webVC = storyboard!.instantiateViewControllerWithIdentifier("ContainerWebViewController") as? ContainerWebViewController
        
        if let controller = webVC {
            controller.webpageURL = url
            controller.product = product
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func openDetailsForProduct() {
        let product = search.products.objectAtIndex(indexPath!.row) as! Product
        
        // Log custom events
        Answers.logCustomEventWithName("Tapped Info", customAttributes: getAttributesForProduct(product))
        
        indexPath = collectionView!.indexPathsForVisibleItems().first
        let detailsVC = storyboard!.instantiateViewControllerWithIdentifier("ContainerProductDetailsViewController") as? ContainerProductDetailsViewController
        
        if let controller = detailsVC {
            controller.product = product
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func openActivityViewForProduct(product: Product, andImage image: UIImage?) {
        // Log custom events
        Answers.logCustomEventWithName("Tapped Share", customAttributes: getAttributesForProduct(product))
        
        indexPath = collectionView!.indexPathsForVisibleItems().first
        
        let url = "https://vendeeapp.com/item?id=\(product.id)"
        let subjectActivityItem = SubjectActivityItem(subject: "Look at what I found")
//        let promoText = "Download Vendee app for free in the App Store."
        let promoText = "Check out this item on Vendee!"
        
        var items = [AnyObject]()
        items.append(subjectActivityItem)
        items.append(promoText)
        if let image = image { items.append(image) }
        items.append(url)
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func openPhotosViewerForProduct(product: Product, andImageView imageView: UIImageView, onPage page: Int) {
        guard let _ = imageView.image else { return }
        
        // Log custom events
        Answers.logCustomEventWithName("Tapped Photo", customAttributes: getAttributesForProduct(product))
        
        selectedImage = imageView
        indexPath = collectionView!.indexPathsForVisibleItems().first
        let photosVC = storyboard!.instantiateViewControllerWithIdentifier("PhotosViewController") as? PhotosViewController
        
        if let controller = photosVC {
            controller.imageURLs = product.largeImageURLs
            controller.tinyImageURLs = product.tinyImageURLs
            controller.page = page
            controller.transitioningDelegate = self
            presentViewController(controller, animated: true, completion: nil)
        }
    }
}

extension FlickViewController: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.originFrame = selectedImage!.superview!.convertRect(selectedImage!.frame, toView: nil)
        
        let intialBoundingRect = CGRect(x: 0, y: 0, width: ScreenConstants.width, height: getImageViewHeight())
        var initialAspectRect = CGRect.zero
        
        initialAspectRect = AVMakeRectWithAspectRatioInsideRect(selectedImage!.image!.size, intialBoundingRect)
        transition.initialBoundingFrame = initialAspectRect
        
        let finalBoundingRect = CGRect(x: 0, y: 0, width: ScreenConstants.width, height: ScreenConstants.height)
        var finalAspectRect = CGRect.zero
        
        finalAspectRect = AVMakeRectWithAspectRatioInsideRect(selectedImage!.image!.size, finalBoundingRect)
        transition.finalBoundingFrame = finalAspectRect
        
        transition.presenting = true
        
        return transition
    }
    
//    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        transition.presenting = false
//        return transition
//    }
}

extension FlickViewController: TSMessageViewProtocol {
    
    func customizeMessageView(messageView: TSMessageView!) {
        messageView.alpha = 0.8
    }
}
