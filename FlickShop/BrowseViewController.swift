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

protocol ScrollEventsDelegate: class {
    func didScroll()
    func didEndDecelerating()
}

class BrowseViewController: UICollectionViewController {
    
    private let cellIdentifier = "CustomPhotoCell"
    private let footerViewIdentifier = "FooterView"
    private let headerViewIdentifier = "HeaderView"
    
    var search = Search()
    
    weak var delegate: ScrollEventsDelegate?
    var requestingData = false
    var productCount = 0
    var productCategory: String!
//    var product: Product!
    var brands: [Brand]!
    
    //    override func preferredStatusBarStyle() -> UIStatusBarStyle {
    //        return .LightContent
    //    }
    
    deinit {
        print("Deallocating BrowseCollectionViewController !!!!!!!!!!!!!!!")
        
        search.dataRequest?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
//        productCategory = product.categories?[0]
        
//        navigationItem.title = product.name
//        navigationController?.navigationBar.translucent = false
//        navigationController?.setNavigationBarHidden(true, animated: false)
//        navigationController?.navigationBar.barStyle = UIBarStyle.Default
//        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        setupView()
        print("MORE REQUESTS")
        requestDataFromShopStyleForCategory(productCategory)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindFilterApply(segue: UIStoryboardSegue) {
        // Cancel existing request
        search.dataRequest?.cancel()
        
        // Scroll to top of the collection view
        collectionView!.setContentOffset(CGPointZero, animated: false)
        collectionView!.contentSize = CGSizeZero
        
        search = Search()
        search.filteredSearch = true
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
        }
    }
    
    private func setupView() {
        collectionView!.contentInset = UIEdgeInsets(top: -16, left: 4, bottom: 4, right: 4)
        //        collectionView!.contentInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        
        if let layout = collectionView!.collectionViewLayout as? TwoColumnLayout {
            layout.delegate = self
        }
    }
    
    private func requestDataFromShopStyleForCategory(category: String!) {
        let limit = 5
        
        if requestingData {
            return
        }
        
        requestingData = true
        
        if let category = category {
            search.parseShopStyleForItemOffset(search.lastItem, withLimit: limit, forCategory: category) { [weak self]
                success, lastItem in
                if let strongSelf = self {
                    if !success {
                        print("Products Count: \(lastItem)")
                        
                        if strongSelf.search.retryCount < limit {
                            print("Request Failed. Trying again...")
                            strongSelf.requestingData = false
                            strongSelf.requestDataFromShopStyleForCategory(category)
                            print("Request Count: \(strongSelf.search.retryCount)")
                            strongSelf.search.retryCount++
                        }
                        
                    } else {
                        strongSelf.requestingData = false
                        print("Product count: \(lastItem)")
                        
                        // Algorithm 1
                        strongSelf.search.populatePhotoSizesForLimit(limit) { success, lastIndex in
                            let fromIndex = lastIndex - limit
                            let indexPaths = (fromIndex..<lastIndex).map { NSIndexPath(forItem: $0, inSection: 0) }
                            
                            strongSelf.collectionView!.performBatchUpdates({
                                strongSelf.collectionView!.insertItemsAtIndexPaths(indexPaths)
                                }, completion: { success in
                                    print("INSERTS SUCCESSFUL")
                            })
                        }
                        
                        // Algorithm 2
//                        for var i = lastItem - limit; i < lastItem; i++ {
//                            let indexPath = NSIndexPath(forItem: i, inSection: 0)
//    
//                            strongSelf.search.populatePhotoSizeForIndexPath(indexPath) { success in
//                                if success {
//                                    let newIndexPath = NSIndexPath(forItem: strongSelf.productCount, inSection: 0)
//                                    strongSelf.productCount++
//                                    
//                                    strongSelf.collectionView!.insertItemsAtIndexPaths([newIndexPath])
//                                    print("INSERT SUCCESSFULL")
//    
////                                    strongSelf.collectionView!.performBatchUpdates({
////                                        strongSelf.collectionView!.insertItemsAtIndexPaths([newIndexPath])
////                                        }, completion: { success in
////                                            print("INSERT SUCCESSFUL")
////                                    })
//                                }
//                            }
//                        }
                    }
                }
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
        return search.lastItem
//        return productCount
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! CustomPhotoCell
//        cell.layer.shouldRasterize = true
//        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
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
        
        if search.products.count - indexPath.item == 5 && search.products.count < 1000 {
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
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        delegate?.didScroll()
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        delegate?.didEndDecelerating()
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
        //        return rect.size.height
    }
}