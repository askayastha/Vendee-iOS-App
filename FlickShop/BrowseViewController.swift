//
//  BrowseCollectionViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 10/23/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import TSMessages

class BrowseViewController: UICollectionViewController {
    
    private var requestingData = false
    private var productCount = 0
    
    var hideSpinner: (()->())?
    
    weak var delegate: SwipeDelegate?
    var search = Search()
    var brands = Brand.allBrands()
    var productCategory: String!
    var dataModel: DataModel!
    
    struct BrowseViewCellIdentifiers {
        static let customProductCell = "CustomPhotoCell"
    }
    
    deinit {
        print("Deallocating BrowseViewController !!!!!!!!!!!!!!!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "requestData", name: CustomNotifications.NetworkDidChangeToReachableNotification, object: nil)
        setupView()
        requestData()
    }
    
    func requestData() {
        requestDataFromShopStyleForCategory(productCategory)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindFilterApply(segue: UIStoryboardSegue) {
        search.resetSearch()
        search = Search()
        search.filteredSearch = true
        productCount = 0
        
        // Scroll to top of the collection view
        if let layout = collectionView!.collectionViewLayout as? TwoColumnLayout {
            layout.reset()
        }
        collectionView!.reloadData()
        print("COLLECTION VIEW RELOADED")
        
        requestDataFromShopStyleForCategory(productCategory)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FlickCategory" {
            let controller = segue.destinationViewController as! ContainerFlickViewController
            let indexPath = sender as! NSIndexPath
            
            controller.search = search
            controller.indexPath = indexPath
            controller.brands = brands
            controller.productCategory = productCategory
            controller.dataModel = dataModel
            controller.hidesBottomBarWhenPushed = true
        }
    }
    
    private func setupView() {
//        spinner.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activateConstraints([
//            spinner.centerXAnchor.constraintEqualToAnchor(collectionView!.centerXAnchor),
//            spinner.centerYAnchor.constraintEqualToAnchor(collectionView!.centerYAnchor)
//            ])
        
        // Swipe gesture setup
        let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: "swipedUp:")
        swipeUpRecognizer.delegate = self
        swipeUpRecognizer.direction = .Up
        
        let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: "swipedDown:")
        swipeDownRecognizer.delegate = self
        swipeDownRecognizer.direction = .Down
        
        collectionView!.addGestureRecognizer(swipeUpRecognizer)
        collectionView!.addGestureRecognizer(swipeDownRecognizer)
        
        collectionView!.contentInset = UIEdgeInsets(top: -16, left: 4, bottom: 4, right: 4)
        // collectionView!.contentInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        
        if let layout = collectionView!.collectionViewLayout as? TwoColumnLayout {
            layout.delegate = self
        }
    }
    
    private func requestDataFromShopStyleForCategory(category: String!) {
        if requestingData { return }
        
        func populatePhotosFromIndex(index: Int) {
            
            search.populatePhotoSizesFromIndex(index, withLimit: NumericConstants.populateLimit) { [weak self] success, lastIndex in
                guard let strongSelf = self else { return }
                guard success else {
                    print("GUARDING SUCCESS")
                    strongSelf.hideSpinner?()
                    populatePhotosFromIndex(lastIndex)
                    return
                }
                strongSelf.productCount += NumericConstants.populateLimit
                let fromIndex = lastIndex - NumericConstants.populateLimit
                let indexPaths = (fromIndex..<lastIndex).map { NSIndexPath(forItem: $0, inSection: 0) }
                
                strongSelf.collectionView!.performBatchUpdates({
                    print("READY FOR INSERTS: \(lastIndex)")
                    strongSelf.collectionView!.insertItemsAtIndexPaths(indexPaths)
                    }, completion: { success in
                        print("INSERTS SUCCESSFUL")
                        if success && lastIndex != strongSelf.search.lastItem {
                            strongSelf.hideSpinner?()
                            populatePhotosFromIndex(lastIndex)
                        } else {
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        }
                })
            }
        }
        
        func showNoResultsError() {
//            let alert = UIAlertController(title: nil, message: "No results found.", preferredStyle: .Alert)
//            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
//            alert.addAction(OKAction)
//            
//            presentViewController(alert, animated: true, completion: nil)
            
            TSMessage.showNotificationWithTitle("No results found.", type: .Warning)
        }
        
        requestingData = true
        guard let category = category else {
            return
        }
        
        search.parseShopStyleForItemOffset(search.lastItem, withLimit: NumericConstants.requestLimit, forCategory: category) { [weak self] success, description, lastItem in
            
            guard let strongSelf = self else { return }
            print("Products count: \(lastItem)")
            if !success {
                if strongSelf.search.retryCount < NumericConstants.retryLimit {
                    strongSelf.requestingData = false
                    strongSelf.requestDataFromShopStyleForCategory(category)
                    strongSelf.search.incrementRetryCount()
                    print("Request Failed. Trying again...")
                    print("Request Count: \(strongSelf.search.retryCount)")
                    
                } else {
                    strongSelf.requestingData = false
                    strongSelf.search.resetRetryCount()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    strongSelf.hideSpinner?()
                    TSMessage.showNotificationWithTitle("Network Error", subtitle: description, type: .Error)
                }
                
            } else {
                strongSelf.requestingData = false
                
                if lastItem > 0 {
                    populatePhotosFromIndex(strongSelf.productCount)
                } else {
                    showNoResultsError()
                }
    
                // Algorithm 2
//                    for var i = lastItem - limit; i < lastItem; i++ {
//                        let indexPath = NSIndexPath(forItem: i, inSection: 0)
//
//                        strongSelf.search.populatePhotoSizeForIndexPath(indexPath) { success in
//                            if success {
//                                let newIndexPath = NSIndexPath(forItem: strongSelf.productCount, inSection: 0)
//                                strongSelf.productCount++
//                                
//                                strongSelf.collectionView!.insertItemsAtIndexPaths([newIndexPath])
//                                print("INSERT SUCCESSFULL")
//
////                                    strongSelf.collectionView!.performBatchUpdates({
////                                        strongSelf.collectionView!.insertItemsAtIndexPaths([newIndexPath])
////                                        }, completion: { success in
////                                            print("INSERT SUCCESSFUL")
////                                    })
//                            }
//                        }
//                    }
    
            }
        }
    }
    
    //    override func scrollViewDidScroll(scrollView: UIScrollView) {
    //        // Populate more photos when the scrollbar indicator is at 80%
    //        if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8 {
    //            print("New request")
    //            requestDataFromShopStyleForCategory(productCategory)
    //            print("ScrollView ContentOffset: \(scrollView.contentOffset.y)")
    //            print("ScrollView View Height: \(view.frame.size.height)")
    //            print("ScrollView ContentSize: \(scrollView.contentSize.height)")
    //        }
    //    }
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
        
        cell.brandImageView.layer.borderColor = UIColor(red: 223/255, green: 223/255, blue: 223/255, alpha: 1.0).CGColor
        cell.brandImageView.layer.borderWidth = 0.5
        cell.brandImageView.layer.cornerRadius = 5.0
        cell.brandImageView.layer.masksToBounds = true
        cell.topImageViewLineSeparatorHeightConstraint.constant = 0.5
        cell.product = product
        
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
        
        if search.lastItem - indexPath.item == 5 && search.lastItem < 1000 {
            print("New request")
            requestData()
        }
        
        return cell
    }
    
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
//    }
    
//    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        //        performSegueWithIdentifier("FlickCollectionViewController", sender: indexPath)
//        let feedVC = storyboard!.instantiateViewControllerWithIdentifier("FlickCollectionViewController") as? FlickCollectionViewController
//        
//        if let controller = feedVC {
//            controller.productCategory = productCategory
//            controller.indexPath  = indexPath
//            controller.search = search
//            navigationController?.pushViewController(controller, animated: true)
//        }
//    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("FlickCategory", sender: indexPath)
    }
}

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
