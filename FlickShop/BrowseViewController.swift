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

struct BrowseViewCellIdentifiers {
    static let customProductCell = "CustomPhotoCell"
}

class BrowseViewController: UICollectionViewController {
    
    private(set) var requestingData = false
    private(set) var populatingData = false
    private(set) var productCount = 0
    
    var hideSpinner: (()->())?
    
    weak var delegate: SwipeDelegate?
    var search = Search()
    var scout: PhotoScout
    var brands = Brand.allBrands()
    var productCategory: String!
    var dataModel: DataModel!
    
    deinit {
        print("Deallocating BrowseViewController !!!!!!!!!!!!!!!")
        
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
        
        if !requestingData {
            populateData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindFilterApply(segue: UIStoryboardSegue) {
        search.resetSearch()
        search.filteredSearch = true
        productCount = 0
        
        scout.cancelled = true
        populatingData = false
        scout = PhotoScout(products: search.products)
        
        // Reset content size of the collection view
        if let layout = collectionView!.collectionViewLayout as? TwoColumnLayout {
            layout.reset()
        }
        collectionView!.reloadData()
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
    
    // MARK: - Helper methods
    
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
    
    func populateData() {
        print("Browse PopulateData Count: \(productCount)")
        if dataModel.favoriteProducts.count > 0 && appDelegate.networkManager!.isReachable {
            populatePhotosFromIndex(productCount)
        } else if !appDelegate.networkManager!.isReachable {
            hideSpinner?()
            TSMessage.showNotificationWithTitle("Network Error", subtitle: "Check your internet connection and try again later.", type: .Error)
        } else {
            hideSpinner?()
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
                strongSelf.hideSpinner?()
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
                    strongSelf.hideSpinner?()
                    
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
                    strongSelf.populatePhotosFromIndex(strongSelf.productCount)
                } else {
                    TSMessage.showNotificationWithTitle("No results found.", type: .Warning)
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
            requestDataFromShopStyleForCategory(productCategory)
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
