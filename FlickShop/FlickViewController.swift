//
//  FlickCollectionViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 9/12/15.
//  Copyright (c) 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
import SafariServices
import AVFoundation

//struct FlickViewConstants {
//    static var width = UIScreen.mainScreen().bounds.width
//    static var height = UIScreen.mainScreen().bounds.height
//}

protocol ScrollEventsDelegate: class {
    func didScroll()
    func didEndDecelerating()
}

class FlickViewController: UICollectionViewController {
    
    private var lastItem = 0
    private var loadingHUDPresent = false
    
    var search: Search!
    var brands: [Brand]!
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
            collectionView!.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.None, animated: false)
        }
    }
    
    deinit {
        print("Deallocating FlickViewController !!!!!!!!!!!!!!!")
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
        
//        cell.layer.shouldRasterize = true
//        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
    
        let product = search.products.objectAtIndex(indexPath.item) as! Product
        
        // Configure the cell
        
        cell.scrollViewHeightConstraint.constant = getImageViewHeight()
        cell.bottomImageViewLineSeparatorHeightConstraint.constant = 0.5
        cell.topImageViewLineSeparatorHeightConstraint.constant = 0.5
//        cell.topLikesCommentsViewLineSeparatorHeightConstraint.constant = 0.5
        
        cell.brandImageView.layer.borderColor = UIColor(red: 223/255, green: 223/255, blue: 223/255, alpha: 1.0).CGColor
        cell.brandImageView.layer.borderWidth = 0.5
        cell.brandImageView.layer.cornerRadius = 5.0
        cell.brandImageView.layer.masksToBounds = true
                
        cell.product = product
        cell.delegate = self
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            if let brandName = product.brandName {
                let brandImageURL = self.brands.filter {$0.nickname == brandName}.first?.picURL
                
                dispatch_async(dispatch_get_main_queue()) {
                    if let imageURL = brandImageURL {
                        cell.brandImageView.pin_setImageFromURL(NSURL(string: imageURL)!)
                    }
                }
            }
        }
        
        if search.lastItem - indexPath.item == 1 && search.lastItem < 1000 {
            print("New request")
            requestDataFromShopStyleForCategory(productCategory)
        }
        print("Page \(indexPath.item)")
    
        return cell
    }
    
    
    // MARK: - Helper Methods
    
    private func requestDataFromShopStyleForCategory(category: String) {

        if !loadingHUDPresent {
            let loadingHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
            loadingHUD.labelText = "Loading..."
            loadingHUD.userInteractionEnabled = false
        }
        
        search.parseShopStyleForItemOffset(search.lastItem, withLimit: NumericConstants.requestLimit, forCategory: category) { [weak self] success, lastItem in
            
            guard let strongSelf = self else { return }
            print("Products count: \(lastItem)")
            if !success {
                if strongSelf.search.retryCount < NumericConstants.retryLimit {
                    print("Request Failed. Trying again...")
                    strongSelf.requestDataFromShopStyleForCategory(category)
                    print("Request Count: \(strongSelf.search.retryCount)")
                    strongSelf.search.incrementRetryCount()
                    
                } else {
                    strongSelf.search.resetRetryCount()
                    MBProgressHUD.hideAllHUDsForView(strongSelf.view, animated: true)
                    strongSelf.loadingHUDPresent = false
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
                
            } else {
                strongSelf.collectionView!.reloadData()
                MBProgressHUD.hideAllHUDsForView(strongSelf.view, animated: true)
                strongSelf.loadingHUDPresent = false
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
        }
    }
    
    private func getImageViewHeight() -> CGFloat {
        let collectionViewHeight = collectionView!.bounds.size.height
        
        print("CollectionView Height: \(collectionViewHeight)")
        print("Screen Height: \(ScreenConstants.height)")
        
        return ScreenConstants.height - (60 + 20 + 52)
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "MoreDetails" {
//            let controller = segue.destinationViewController as! ProductDetailsCollectionViewController
//            controller.product = sender as! Product
//        }
//    }
}

extension FlickViewController: SFSafariViewControllerDelegate {
    
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        dismissViewControllerAnimated(true, completion: nil)
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
    
    func openItemInStoreWithProduct(product: Product) {
        guard let buyURL = product.buyURL else { return }
        guard let url = NSURL(string: buyURL) else { return }
        
        indexPath = collectionView!.indexPathsForVisibleItems().first
            
        let webVC = storyboard!.instantiateViewControllerWithIdentifier("ContainerWebViewController") as? ContainerWebViewController
        
        if let controller = webVC {
            controller.webpageURL = url
            controller.product = product
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func openDetailsForProduct(product: Product) {
        indexPath = collectionView!.indexPathsForVisibleItems().first
        let detailsVC = storyboard!.instantiateViewControllerWithIdentifier("ContainerProductDetailsViewController") as? ContainerProductDetailsViewController
        
        if let controller = detailsVC {
            print("Categories: \(product.categories)")
            controller.product = search.products.objectAtIndex(indexPath!.row) as! Product
            controller.brands = brands
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func openActivityViewForProduct(product: Product, andImage image: UIImage?) {
        indexPath = collectionView!.indexPathsForVisibleItems().first
        
        let url = "https://www.vendeeapp.com/product?id=\(product.id!)"
        let subjectActivityItem = SubjectActivityItem(subject: "Look at what I found on Vendee")
//        let promoText = "Download Vendee app for free in the App Store."
        let promoText = "I found this on the Vendee app!"
        
        var items = [AnyObject]()
        items.append(subjectActivityItem)
        items.append(promoText)
        if let image = image { items.append(image) }
        items.append(url)
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
//    func openPhotosViewerForProduct(product: Product, onPage page: Int) {
//        indexPath = collectionView!.indexPathsForVisibleItems().first
//        let photosVC = storyboard!.instantiateViewControllerWithIdentifier("PhotosViewController") as? PhotosViewController
//        
//        if let controller = photosVC {
//            controller.imageURLs = product.largeImageURLs
//            controller.tinyImageURLs = product.tinyImageURLs
//            controller.page = page
//            controller.transitioningDelegate = self
//            presentViewController(controller, animated: true, completion: nil)
//        }
//    }
    
    func openPhotosViewerForProduct(product: Product, andImageView imageView: UIImageView, onPage page: Int) {
        guard let _ = imageView.image else { return }
        
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
